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
              callback_url: 'myapp://payment-complete',
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

exports.verifyTransaction = onCall(
    {secrets: [paystackSecretKey]},
    async (request) => {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "You must be logged in");
      }

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

      if (!data.status || data.data.status !== "success") {
        return {verified: false};
      }

      return {
        verified: true,
        amount: data.data.amount / 100,
        reference: data.data.reference,
      };
    },
);
