"use strict";

/**
 * Minimal fake Express response — captures status code and sent body.
 * @return {Object} fake res with status/send and inspection fields.
 */
function fakeRes() {
  const res = {
    statusCode: null,
    body: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    send(body) {
      this.body = body;
      return this;
    },
  };
  return res;
}

/**
 * Builds a fake Paystack webhook request with a correctly computed
 * signature, or a deliberately wrong one if `signature` is passed.
 * @param {Object} opts Options.
 * @param {Object} opts.event Parsed event body (req.body).
 * @param {string} opts.secret Secret key to sign with (or verify against).
 * @param {string} [opts.method] HTTP method, defaults to POST.
 * @param {string} [opts.signature] Override signature (for tamper tests).
 * @param {boolean} [opts.omitSignature] If true, no signature header at all.
 * @return {Object} fake req.
 */
function fakeWebhookReq({event, secret, method = "POST", signature,
  omitSignature = false}) {
  const crypto = require("crypto");
  const rawBody = Buffer.from(JSON.stringify(event));
  const computedSig = crypto
      .createHmac("sha512", secret)
      .update(rawBody)
      .digest("hex");

  const headers = {};
  if (!omitSignature) {
    headers["x-paystack-signature"] = signature || computedSig;
  }

  return {
    method,
    headers,
    rawBody,
    body: event,
  };
}

module.exports = {fakeRes, fakeWebhookReq};