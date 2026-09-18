"use strict";

process.env.NODE_ENV = "test";

const {test, describe, beforeEach} = require("node:test");
const assert = require("node:assert/strict");
const {FakeFirestore} = require("./fakeFirestore");
const {fakeRes, fakeWebhookReq} = require("./fakeHttp");
const {handlePaystackWebhook, __setTestDeps} =
  require("../index").__testables;

const SECRET = "test-secret-key";

describe("handlePaystackWebhook", () => {
  let db;

  beforeEach(() => {
    db = new FakeFirestore();
    __setTestDeps({db});
  });

  test("rejects non-POST requests with 405", async () => {
    const req = fakeWebhookReq({
      event: {event: "charge.success", data: {}},
      secret: SECRET,
      method: "GET",
    });
    const res = fakeRes();

    await handlePaystackWebhook(req, res, SECRET);

    assert.equal(res.statusCode, 405);
  });

  test("rejects a request with no signature header", async () => {
    const req = fakeWebhookReq({
      event: {event: "charge.success", data: {}},
      secret: SECRET,
      omitSignature: true,
    });
    const res = fakeRes();

    await handlePaystackWebhook(req, res, SECRET);

    assert.equal(res.statusCode, 401);
    assert.equal(res.body, "Invalid signature");
  });

  test("rejects a request with a tampered/incorrect signature", async () => {
    const req = fakeWebhookReq({
      event: {event: "charge.success", data: {}},
      secret: SECRET,
      signature: "0000000000deadbeef",
    });
    const res = fakeRes();

    await handlePaystackWebhook(req, res, SECRET);

    assert.equal(res.statusCode, 401);
  });

  test("rejects a request signed with the wrong secret", async () => {
    const req = fakeWebhookReq({
      event: {event: "charge.success", data: {}},
      secret: "some-other-secret",
    });
    const res = fakeRes();

    // Verifying against SECRET, but the request was signed with a
    // different key — signatures won't match.
    await handlePaystackWebhook(req, res, SECRET);

    assert.equal(res.statusCode, 401);
  });

  test("accepts a correctly signed non-charge.success event and no-ops",
      async () => {
        const req = fakeWebhookReq({
          event: {event: "transfer.success", data: {}},
          secret: SECRET,
        });
        const res = fakeRes();

        await handlePaystackWebhook(req, res, SECRET);

        assert.equal(res.statusCode, 200);
        assert.equal(res.body, "ok");
        // Nothing should have been written — event type isn't handled.
        assert.deepEqual(db._dump(), {});
      });

  test("fulfills the order on a valid charge.success event", async () => {
    db._seedDoc("users/user1/cart/item1", {
      productId: "prod1",
      quantity: 1,
      isSelected: true,
      cartItemId: "item1",
    });
    db._seedDoc("products/prod1", {name: "Widget", price: 1000, stock: 5});
    db._seedDoc("pendingOrders/ref123", {uid: "user1", address: null});

    const req = fakeWebhookReq({
      event: {
        event: "charge.success",
        data: {
          reference: "ref123",
          amount: 107500, // kobo
          metadata: {uid: "user1"},
        },
      },
      secret: SECRET,
    });
    const res = fakeRes();

    await handlePaystackWebhook(req, res, SECRET);

    assert.equal(res.statusCode, 200);
    const dump = db._dump();
    assert.equal(dump["orders/ref123"].status, "paid");
    assert.equal(dump["products/prod1"].stock, 4);
  });

  test("still returns 200 if fulfillment fails (e.g. stock ran out)",
      async () => {
        db._seedDoc("users/user1/cart/item1", {
          productId: "prod1",
          quantity: 10,
          isSelected: true,
          cartItemId: "item1",
        });
        db._seedDoc("products/prod1", {name: "Widget", price: 1000,
          stock: 1});
        db._seedDoc("pendingOrders/ref123", {uid: "user1", address: null});

        const req = fakeWebhookReq({
          event: {
            event: "charge.success",
            data: {
              reference: "ref123",
              amount: 10750000,
              metadata: {uid: "user1"},
            },
          },
          secret: SECRET,
        });
        const res = fakeRes();

        // Must not throw — webhook always 200s once signature is valid,
        // even if fulfillment fails downstream, so Paystack doesn't retry.
        await handlePaystackWebhook(req, res, SECRET);

        assert.equal(res.statusCode, 200);
        assert.equal(res.body, "ok");
        // No order should have been created since stock was insufficient.
        assert.equal(db._dump()["orders/ref123"], undefined);
      });

  test("upgrades a cancelled order on a late charge.success", async () => {
    db._seedDoc("users/user1/cart/item1", {
      productId: "prod1",
      quantity: 1,
      isSelected: true,
      cartItemId: "item1",
    });
    db._seedDoc("products/prod1", {name: "Widget", price: 1000, stock: 5});
    db._seedDoc("pendingOrders/ref123", {
      uid: "user1",
      address: null,
      items: [{productId: "prod1", quantity: 1, price: 1000, name: "Widget"}],
      total: 1075,
    });
    db._seedDoc("orders/ref123", {
      uid: "user1",
      reference: "ref123",
      status: "cancelled",
      items: [{productId: "prod1", quantity: 1, price: 1000, name: "Widget"}],
      totalPrice: 1075,
    });

    const req = fakeWebhookReq({
      event: {
        event: "charge.success",
        data: {
          reference: "ref123",
          amount: 107500,
          metadata: {uid: "user1"},
        },
      },
      secret: SECRET,
    });
    const res = fakeRes();

    await handlePaystackWebhook(req, res, SECRET);

    assert.equal(res.statusCode, 200);
    const dump = db._dump();
    assert.equal(dump["orders/ref123"].status, "paid");
    assert.equal(dump["products/prod1"].stock, 4);
  });

  test("returns 200 and does not throw when metadata.uid is missing",
      async () => {
        const req = fakeWebhookReq({
          event: {
            event: "charge.success",
            data: {
              reference: "ref999",
              amount: 5000,
              metadata: {},
            },
          },
          secret: SECRET,
        });
        const res = fakeRes();

        await handlePaystackWebhook(req, res, SECRET);

        assert.equal(res.statusCode, 200);
        assert.deepEqual(db._dump(), {});
      });
});