const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const fetch = require("node-fetch");

initializeApp();
const db = getFirestore();

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
      const {shippingCost, email} = request.data;

      if (typeof shippingCost !== "number" || shippingCost < 0) {
        throw new HttpsError("invalid-argument", "Invalid shipping cost");
      }
      if (!email) {
        throw new HttpsError("invalid-argument", "Email is required");
      }

      const {subtotal, vat, total} = await computeOrderAmount(
          uid,
          shippingCost,
      );

      const amountInKobo = Math.round(total * 100);

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
              metadata: {uid},
              callback_url: "https://ecommerce-app-4f158.web.app/payment-complete",
            }),
          },
      );

      const data = await response.json();

      if (!data.status) {
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
 * @param {Object|null} address Shipping address, snapshotted from the
 *   client at checkout time (so later edits to the saved address don't
 *   retroactively change this order's shipping destination).
 * @return {Promise<string|null>} The order ID, or null if already processed
 */
async function fulfillOrder(uid, reference, amountPaid, address) {
  const orderRef = db.collection("orders").doc(reference);

  return db.runTransaction(async (tx) => {
    const existingOrder = await tx.get(orderRef);
    if (existingOrder.exists) {
      // Already fulfilled by a previous verify call — don't double-process.
      return null;
    }

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
      const {reference, address} = request.data;
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

      if (paystackStatus !== "success") {
        return {
          verified: false,
          status: paystackStatus,
          reference,
        };
      }

      const amountPaid = data.data.amount / 100;

      let orderId;
      try {
        orderId = await fulfillOrder(uid, reference, amountPaid, address);
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
