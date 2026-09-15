"use strict";

process.env.NODE_ENV = "test";

const {test, describe, beforeEach} = require("node:test");
const assert = require("node:assert/strict");
const {FakeFirestore} = require("./fakeFirestore");
const {computeOrderAmount, fulfillOrder, __setTestDeps} =
  require("../index").__testables;

/**
 * Builds a fake fetch that returns a canned JSON response.
 * @param {Object} jsonBody Body to resolve as response.json().
 * @return {Function} fetch-compatible function.
 */
function fakeFetchReturning(jsonBody) {
  return async () => ({json: async () => jsonBody});
}

describe("computeOrderAmount", () => {
  let db;

  beforeEach(() => {
    db = new FakeFirestore();
    __setTestDeps({db});
  });

  test("throws failed-precondition when cart is empty", async () => {
    await assert.rejects(
        () => computeOrderAmount("user1", 500),
        (err) => {
          assert.equal(err.code, "failed-precondition");
          return true;
        },
    );
  });

  test("throws not-found when a cart product no longer exists", async () => {
    db._seedDoc("users/user1/cart/item1", {
      productId: "ghost-product",
      quantity: 1,
      isSelected: true,
    });
    // Note: ghost-product is never seeded under products/.

    await assert.rejects(
        () => computeOrderAmount("user1", 500),
        (err) => {
          assert.equal(err.code, "not-found");
          return true;
        },
    );
  });

  test("throws failed-precondition when stock is insufficient", async () => {
    db._seedDoc("users/user1/cart/item1", {
      productId: "prod1",
      quantity: 5,
      isSelected: true,
    });
    db._seedDoc("products/prod1", {
      name: "Widget",
      price: 1000,
      stock: 2,
    });

    await assert.rejects(
        () => computeOrderAmount("user1", 500),
        (err) => {
          assert.equal(err.code, "failed-precondition");
          assert.match(err.message, /Widget/);
          return true;
        },
    );
  });

  test("ignores unselected cart items", async () => {
    db._seedDoc("users/user1/cart/item1", {
      productId: "prod1",
      quantity: 1,
      isSelected: false,
    });

    await assert.rejects(
        () => computeOrderAmount("user1", 500),
        (err) => {
          // isSelected filter means the cart query sees it as empty.
          assert.equal(err.code, "failed-precondition");
          return true;
        },
    );
  });

  test("computes subtotal, VAT (7.5%), and total correctly", async () => {
    db._seedDoc("users/user1/cart/item1", {
      productId: "prod1",
      quantity: 2,
      isSelected: true,
    });
    db._seedDoc("users/user1/cart/item2", {
      productId: "prod2",
      quantity: 1,
      isSelected: true,
    });
    db._seedDoc("products/prod1", {name: "A", price: 1000, stock: 10});
    db._seedDoc("products/prod2", {name: "B", price: 500, stock: 10});

    const shippingCost = 200;
    const result = await computeOrderAmount("user1", shippingCost);

    // subtotal = 2*1000 + 1*500 = 2500
    assert.equal(result.subtotal, 2500);
    // vatable = subtotal + shipping = 2700; vat = 2700 * 0.075 = 202.5
    assert.equal(result.vat, 202.5);
    assert.equal(result.shippingCost, 200);
    // total = 2500 + 200 + 202.5 = 2902.5
    assert.equal(result.total, 2902.5);
  });
});

describe("fulfillOrder", () => {
  let db;

  beforeEach(() => {
    db = new FakeFirestore();
    __setTestDeps({db});
  });

  test("creates an order and decrements stock", async () => {
    db._seedDoc("users/user1/cart/item1", {
      productId: "prod1",
      quantity: 2,
      isSelected: true,
      cartItemId: "item1",
    });
    db._seedDoc("products/prod1", {name: "Widget", price: 1000, stock: 10});
    db._seedDoc("pendingOrders/ref123", {
      uid: "user1",
      address: {line1: "1 Test St"},
    });

    const orderId = await fulfillOrder("user1", "ref123", 2202.5);
    assert.equal(orderId, "ref123");

    const dump = db._dump();
    assert.equal(dump["products/prod1"].stock, 8);
    assert.equal(dump["orders/ref123"].status, "paid");
    assert.equal(dump["orders/ref123"].items.length, 1);
    assert.equal(dump["orders/ref123"].items[0].quantity, 2);
    assert.deepEqual(dump["orders/ref123"].address, {line1: "1 Test St"});
    // Cart item and pending order should be cleaned up.
    assert.equal(dump["users/user1/cart/item1"], undefined);
    assert.equal(dump["pendingOrders/ref123"], undefined);
  });

  test("is idempotent — second call for same reference is a no-op",
      async () => {
        db._seedDoc("users/user1/cart/item1", {
          productId: "prod1",
          quantity: 1,
          isSelected: true,
          cartItemId: "item1",
        });
        db._seedDoc("products/prod1", {name: "Widget", price: 1000,
          stock: 10});
        db._seedDoc("pendingOrders/ref123", {uid: "user1", address: null});

        const first = await fulfillOrder("user1", "ref123", 1075);
        assert.equal(first, "ref123");

        const stockAfterFirst = db._dump()["products/prod1"].stock;
        assert.equal(stockAfterFirst, 9);

        // Second call: order already exists, should return null and not
        // touch stock again.
        const second = await fulfillOrder("user1", "ref123", 1075);
        assert.equal(second, null);
        assert.equal(db._dump()["products/prod1"].stock, 9);
      });

  test("aborts without writing anything if stock is insufficient",
      async () => {
        db._seedDoc("users/user1/cart/item1", {
          productId: "prod1",
          quantity: 5,
          isSelected: true,
          cartItemId: "item1",
        });
        db._seedDoc("products/prod1", {name: "Widget", price: 1000,
          stock: 1});
        db._seedDoc("pendingOrders/ref123", {uid: "user1", address: null});

        await assert.rejects(
            () => fulfillOrder("user1", "ref123", 5375),
            (err) => {
              assert.match(err.message, /INSUFFICIENT_STOCK/);
              return true;
            },
        );

        const dump = db._dump();
        // Nothing should have been written: no order, stock untouched,
        // cart item still present.
        assert.equal(dump["orders/ref123"], undefined);
        assert.equal(dump["products/prod1"].stock, 1);
        assert.notEqual(dump["users/user1/cart/item1"], undefined);
      });

  test("handles an already-cleared cart by recording a zero-item order",
      async () => {
        // No cart items seeded — cart is empty at fulfillment time.
        db._seedDoc("pendingOrders/ref123", {uid: "user1", address: null});

        const orderId = await fulfillOrder("user1", "ref123", 1075);
        assert.equal(orderId, "ref123");

        const order = db._dump()["orders/ref123"];
        assert.equal(order.items.length, 0);
        assert.equal(order.status, "paid");
        assert.equal(order.totalPrice, 1075);
      });

  test("throws not-found if a cart product was deleted before fulfillment",
      async () => {
        db._seedDoc("users/user1/cart/item1", {
          productId: "ghost-product",
          quantity: 1,
          isSelected: true,
          cartItemId: "item1",
        });
        db._seedDoc("pendingOrders/ref123", {uid: "user1", address: null});

        await assert.rejects(
            () => fulfillOrder("user1", "ref123", 1000),
            (err) => {
              assert.match(err.message, /INSUFFICIENT_STOCK/);
              assert.match(err.message, /no longer exists/);
              return true;
            },
        );
      });
});

describe("computeOrderAmount + fetch interplay (sanity check)", () => {
  test("fakeFetchReturning helper resolves the expected JSON", async () => {
    const fetch = fakeFetchReturning({status: true, data: {foo: "bar"}});
    const res = await fetch();
    const json = await res.json();
    assert.equal(json.status, true);
    assert.equal(json.data.foo, "bar");
  });
});