const {onCall, onRequest, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const nodeFetch = require("node-fetch");
const crypto = require("crypto");

// Injectable seams for testing. Production code paths are unchanged —
// these just default to the real Firestore/fetch when not overridden.
let db;
let fetch = nodeFetch;

/**
 * Test-only hook: lets unit tests swap in fakes for Firestore and fetch
 * without touching the real Firebase Admin SDK or network.
 * @param {Object} overrides Object with optional db/fetch fakes.
 */
function __setTestDeps({db: fakeDb, fetch: fakeFetch} = {}) {
  if (fakeDb) db = fakeDb;
  if (fakeFetch) fetch = fakeFetch;
}

if (process.env.NODE_ENV !== "test") {
  initializeApp();
  db = getFirestore();
}

const paystackSecretKey = defineSecret("PAYSTACK_SECRET_KEY");

/**
 * Recomputes subtotal + VAT server-side from Firestore data.
 * Never trusts a client-supplied total.
 * @param {string} uid User ID
 * @param {number} shippingCost Shipping cost
 * @return {Promise<Object>} Calculated amounts
 */
async function computeOrderAmount(uid, shippingCost) {
  const cartSnap = await db
      .collection("users")
      .doc(uid)
      .collection("cart")
      .where("isSelected", "==", true)
      .get();

  if (cartSnap.empty) {
    throw new HttpsError("failed-precondition", "Cart is empty");
  }

  const cartItems = cartSnap.docs.map((doc) => doc.data());

  let subtotal = 0;
  for (const item of cartItems) {
    const productSnap = await db
        .collection("products")
        .doc(item.productId)
        .get();

    if (!productSnap.exists) {
      throw new HttpsError(
          "not-found",
          `Product ${item.productId} no longer exists`,
      );
    }

    const product = productSnap.data();

    if (product.stock < item.quantity) {
      throw new HttpsError(
          "failed-precondition",
          `Not enough stock for ${product.name}`,
      );
    }

    subtotal += product.price * item.quantity;
  }

  const vatableAmount = subtotal + shippingCost;
  const vat = vatableAmount * 0.075;
  const total = subtotal + shippingCost + vat;

  return {subtotal, vat, shippingCost, total};
}

exports.initializeTransaction = onCall(
    {secrets: [paystackSecretKey]},
    async (request) => {
      if (!request.auth) {
        throw new HttpsError(
            "unauthenticated",
            "You must be logged in to checkout",
        );
      }

      const uid = request.auth.uid;
      const {shippingCost, email, address, channels} = request.data;

      if (typeof shippingCost !== "number" || shippingCost < 0) {
        throw new HttpsError("invalid-argument", "Invalid shipping cost");
      }
      if (!email) {
        throw new HttpsError("invalid-argument", "Email is required");
      }

      // Whitelist channels rather than passing the client's array straight
      // through — this field goes directly into the Paystack request body,
      // so an unvalidated value here is an injection point.
      const allowedChannels = ["card", "bank_transfer"];
      let paystackChannels;
      if (channels !== undefined && channels !== null) {
        if (
          !Array.isArray(channels) ||
          channels.length === 0 ||
          !channels.every((c) => allowedChannels.includes(c))
        ) {
          throw new HttpsError("invalid-argument", "Invalid payment channel");
        }
        paystackChannels = channels;
      }

      const {subtotal, vat, total} = await computeOrderAmount(
          uid,
          shippingCost,
      );

      const amountInKobo = Math.round(total * 100);

      // Paystack generates the reference for us, but we need somewhere to
      // stash the shipping address *before* the payment starts, keyed to
      // that reference — neither the webhook nor a client that comes back
      // after losing connection can be trusted to supply it later.
      // Paystack lets us request a reference upfront by passing our own,
      // so we mint one here instead of waiting for their response.
      const reference = `${uid}_${Date.now()}_${
        crypto.randomBytes(4).toString("hex")
      }`;

      await db.collection("pendingOrders").doc(reference).set({
        uid,
        address: address || null,
        createdAt: new Date().toISOString(),
      });

      const response = await fetch(
          "https://api.paystack.co/transaction/initialize",
          {
            method: "POST",
            headers: {
              "Authorization": `Bearer ${paystackSecretKey.value()}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              email,
              amount: amountInKobo,
              reference,
              metadata: {uid},
              ...(paystackChannels ? {channels: paystackChannels} : {}),
              callback_url: "https://ecommerce-app-4f158.web.app/payment-complete",
            }),
          },
      );

      const data = await response.json();

      if (!data.status) {
        // Initialization failed — clean up the pending doc we just wrote
        // so it doesn't linger with no matching transaction.
        await db.collection("pendingOrders").doc(reference).delete();
        throw new HttpsError(
            "internal",
            `Paystack error: ${data.message || "unknown error"}`,
        );
      }

      return {
        authorizationUrl: data.data.authorization_url,
        accessCode: data.data.access_code,
        reference: data.data.reference,
        subtotal,
        vat,
        shippingCost,
        total,
      };
    },
);

/**
 * Atomically creates the order and decrements stock for the selected
 * cart items. Uses the payment reference as the order doc ID so calling
 * this twice for the same payment is a no-op (idempotent).
 *
 * Rejects (aborts the transaction, no order, no stock touched) if any
 * item no longer has enough stock at fulfillment time — this can differ
 * from the check at initializeTransaction time if two people bought the
 * last unit around the same moment.
 * @param {string} uid User ID
 * @param {string} reference Paystack transaction reference
 * @param {number} amountPaid Amount actually paid (in Naira), from Paystack
 * @return {Promise<string|null>} The order ID, or null if already processed
 */
async function fulfillOrder(uid, reference, amountPaid) {
  const orderRef = db.collection("orders").doc(reference);
  const pendingRef = db.collection("pendingOrders").doc(reference);

  return db.runTransaction(async (tx) => {
    const existingOrder = await tx.get(orderRef);
    if (existingOrder.exists) {
      // Already fulfilled — either the webhook and the client's verify
      // call raced, or verify was retried. Don't double-process.
      return null;
    }

    // Shipping address was snapshotted server-side at initializeTransaction
    // time, before payment started, so this works whether fulfillment is
    // triggered by the client (verifyTransaction) or by Paystack's webhook
    // with no client involved at all.
    const pendingSnap = await tx.get(pendingRef);
    const address = pendingSnap.exists ?
      (pendingSnap.data().address || null) :
      null;

    const cartSnap = await tx.get(
        db.collection("users")
            .doc(uid)
            .collection("cart")
            .where("isSelected", "==", true),
    );

    if (cartSnap.empty) {
      // Cart already cleared (e.g. verify retried after success) — nothing
      // left to fulfill, but we still record the order for the receipt.
      tx.set(orderRef, {
        uid,
        reference,
        items: [],
        address: address || null,
        totalPrice: amountPaid,
        status: "paid",
        createdAt: new Date().toISOString(),
      });
      tx.delete(pendingRef);
      return orderRef.id;
    }

    const productRefs = cartSnap.docs.map((doc) =>
      db.collection("products").doc(doc.data().productId),
    );
    const productSnaps = await Promise.all(
        productRefs.map((ref) => tx.get(ref)),
    );

    // Validate stock BEFORE writing anything. If any item is short, abort
    // the whole transaction rather than silently clamping to zero — the
    // payment already succeeded, so this needs to surface as a distinct,
    // reviewable state rather than a quietly-oversold order.
    productSnaps.forEach((productSnap, i) => {
      const cartDoc = cartSnap.docs[i];
      const {quantity} = cartDoc.data();

      if (!productSnap.exists) {
        throw new HttpsError(
            "not-found",
            `INSUFFICIENT_STOCK: product ${cartDoc.data().productId} ` +
            "no longer exists",
        );
      }
      const product = productSnap.data();
      if ((product.stock || 0) < quantity) {
        throw new HttpsError(
            "failed-precondition",
            `INSUFFICIENT_STOCK: ${product.name} — only ` +
            `${product.stock || 0} left, ${quantity} requested`,
        );
      }
    });

    const items = [];
    productSnaps.forEach((productSnap, i) => {
      const cartDoc = cartSnap.docs[i];
      const {productId, quantity} = cartDoc.data();
      const product = productSnap.data();
      const newStock = (product.stock || 0) - quantity;

      tx.update(productSnap.ref, {stock: newStock});
      items.push({
        productId,
        quantity,
        price: product.price,
        name: product.name,
      });
    });

    tx.set(orderRef, {
      uid,
      reference,
      items,
      address: address || null,
      totalPrice: amountPaid,
      status: "paid",
      createdAt: new Date().toISOString(),
    });

    cartSnap.docs.forEach((doc) => tx.delete(doc.ref));
    tx.delete(pendingRef);

    return orderRef.id;
  });
}

/**
 * Records a terminal non-success payment attempt (cancelled/abandoned or
 * failed) as a real order doc, instead of letting it vanish. Mirrors
 * fulfillOrder's idempotency (keyed by reference) but never touches stock
 * or the cart — the customer didn't pay, so nothing was actually fulfilled
 * and they should still be able to retry with the same cart.
 * @param {string} uid User ID
 * @param {string} reference Paystack transaction reference
 * @param {string} orderStatus "cancelled" or "failed"
 * @return {Promise<string|null>} The order ID, or null if already recorded
 */
async function recordUnsuccessfulAttempt(uid, reference, orderStatus) {
  const orderRef = db.collection("orders").doc(reference);
  const pendingRef = db.collection("pendingOrders").doc(reference);

  return db.runTransaction(async (tx) => {
    const existingOrder = await tx.get(orderRef);
    if (existingOrder.exists) {
      // Already recorded — verify was retried (e.g. user tapped "Check
      // again") or raced with something else. Don't overwrite.
      return null;
    }

    const pendingSnap = await tx.get(pendingRef);
    const address = pendingSnap.exists ?
      (pendingSnap.data().address || null) :
      null;

    tx.set(orderRef, {
      uid,
      reference,
      items: [],
      address: address || null,
      totalPrice: 0,
      status: orderStatus,
      createdAt: new Date().toISOString(),
    });

    if (pendingSnap.exists) {
      tx.delete(pendingRef);
    }

    return orderRef.id;
  });
}

exports.verifyTransaction = onCall(
    {secrets: [paystackSecretKey]},
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "You must be logged in");
      }

      const uid = request.auth.uid;
      const {reference} = request.data;
      if (!reference) {
        throw new HttpsError("invalid-argument", "Reference is required");
      }

      const response = await fetch(
          `https://api.paystack.co/transaction/verify/${reference}`,
          {
            headers: {
              Authorization: `Bearer ${paystackSecretKey.value()}`,
            },
          },
      );

      const data = await response.json();

      if (!data.status) {
        throw new HttpsError(
            "internal",
            `Paystack error: ${data.message || "unknown error"}`,
        );
      }

      // Paystack transaction statuses: success | abandoned | failed | pending
      const paystackStatus = data.data.status;

      if (paystackStatus === "pending") {
        // Not terminal yet — the bank may still confirm it. Don't record
        // anything; the client will call verify again later.
        return {
          verified: false,
          status: paystackStatus,
          reference,
        };
      }

      if (paystackStatus !== "success") {
        // Terminal, non-success outcome (abandoned/cancelled or failed).
        // Record it so it shows up in the customer's order history instead
        // of silently disappearing.
        const orderStatus = paystackStatus === "abandoned" ?
          "cancelled" :
          "failed";
        await recordUnsuccessfulAttempt(uid, reference, orderStatus);
        return {
          verified: false,
          status: paystackStatus,
          reference,
        };
      }

      const amountPaid = data.data.amount / 100;

      let orderId;
      try {
        orderId = await fulfillOrder(uid, reference, amountPaid);
      } catch (err) {
        // Payment succeeded but fulfillment failed (most likely stock ran
        // out between initialize and now). Don't throw — the client needs
        // a clear "we took your money but couldn't fulfill it" state, not
        // a generic function error. This case needs manual/refund handling
        // on your side; it's flagged distinctly so it isn't confused with
        // a normal decline.
        return {
          verified: false,
          status: "fulfillment_failed",
          reference,
          message: err.message || "Could not create order",
        };
      }

      return {
        verified: true,
        status: "success",
        amount: amountPaid,
        reference: data.data.reference,
        orderId: orderId || reference,
      };
    },
);

/**
 * Server-to-server webhook. Register this URL in the Paystack dashboard
 * under Settings > API Keys & Webhooks. Paystack calls this directly on
 * charge.success, independent of the app — so an order still gets
 * fulfilled and stock still decrements even if the customer's connection
 * drops or the app is killed right after paying.
 *
 * fulfillOrder is idempotent (keyed by reference), so it's safe for this
 * and verifyTransaction to both fire for the same payment — whichever
 * runs first does the work, the other is a no-op.
 */
/**
 * Pure webhook handler logic, decoupled from the onRequest wrapper and
 * secret-manager plumbing so it can be unit tested with a fake req/res
 * and a plain string secret.
 * @param {Object} req Express-like request (method, headers, rawBody, body)
 * @param {Object} res Express-like response (status().send())
 * @param {string} secretValue The Paystack secret key value to verify with
 * @return {Promise<void>}
 */
async function handlePaystackWebhook(req, res, secretValue) {
  if (req.method !== "POST") {
    res.status(405).send("Method not allowed");
    return;
  }

  // Verify this request actually came from Paystack before trusting
  // anything in the body — without this, anyone who finds this URL
  // could fabricate a "payment successful" event and get free orders.
  const signature = req.headers["x-paystack-signature"];
  const expectedHash = crypto
      .createHmac("sha512", secretValue)
      .update(req.rawBody)
      .digest("hex");

  if (!signature || signature !== expectedHash) {
    res.status(401).send("Invalid signature");
    return;
  }

  const event = req.body;

  if (event.event === "charge.success") {
    const {reference, amount, metadata} = event.data;
    const uid = metadata && metadata.uid;

    if (!uid) {
      console.error(`Webhook: no uid in metadata for ${reference}`);
    } else {
      try {
        await fulfillOrder(uid, reference, amount / 100);
      } catch (err) {
        // Same "paid but couldn't fulfill" case as verifyTransaction —
        // most likely stock ran out. Nothing to return to a webhook
        // caller, so just log it for manual follow-up (refund/restock).
        console.error(
            `Webhook fulfillment failed for ${reference}:`,
            err.message || err,
        );
      }
    }
  }

  // Always 200 once the signature checks out, even if fulfillment
  // logged an error above — a non-200 makes Paystack retry the same
  // event repeatedly, which won't fix a stock-out.
  res.status(200).send("ok");
}

// Exported for unit testing only — not part of the public Cloud Functions
// surface (those are the onCall/onRequest exports below).
exports.__testables = {
  computeOrderAmount,
  fulfillOrder,
  handlePaystackWebhook,
  __setTestDeps,
};

exports.paystackWebhook = onRequest(
    {secrets: [paystackSecretKey]},
    async (req, res) => {
      await handlePaystackWebhook(req, res, paystackSecretKey.value());
    },
);