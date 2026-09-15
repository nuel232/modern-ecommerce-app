"use strict";

/**
 * A minimal in-memory fake of the Firestore surface used by index.js:
 * .collection().doc().get()/.set()/.update()/.delete()
 * .collection().doc().collection().where().get()
 * .runTransaction(async (tx) => { tx.get/set/update/delete })
 *
 * Good enough to exercise real branching logic (empty cart, missing
 * product, insufficient stock, idempotency, transaction races) without
 * needing the Firestore emulator.
 */
class FakeDoc {
  constructor(id, data, ref) {
    this.id = id;
    this._data = data;
    this.ref = ref;
  }
  get exists() {
    return this._data !== undefined;
  }
  data() {
    return this._data;
  }
}

class FakeDocRef {
  constructor(store, path) {
    this._store = store;
    this.path = path;
    this.id = path.split("/").pop();
  }
  collection(name) {
    return new FakeCollectionRef(this._store, `${this.path}/${name}`);
  }
  async get() {
    const data = this._store.get(this.path);
    return new FakeDoc(this.path.split("/").pop(), data, this);
  }
  async set(data) {
    this._store.set(this.path, {...data});
  }
  async update(data) {
    const existing = this._store.get(this.path) || {};
    this._store.set(this.path, {...existing, ...data});
  }
  async delete() {
    this._store.delete(this.path);
  }
}

class FakeQuerySnap {
  constructor(docs) {
    this.docs = docs;
    this.empty = docs.length === 0;
  }
}

class FakeCollectionRef {
  constructor(store, path, filters = []) {
    this._store = store;
    this.path = path;
    this._filters = filters;
  }
  doc(id) {
    const docId = id || `auto_${Math.random().toString(36).slice(2)}`;
    return new FakeDocRef(this._store, `${this.path}/${docId}`);
  }
  where(field, op, value) {
    if (op !== "==") throw new Error(`FakeFirestore: unsupported op ${op}`);
    return new FakeCollectionRef(
        this._store, this.path, [...this._filters, {field, value}],
    );
  }
  async get() {
    const prefix = `${this.path}/`;
    const docs = [];
    for (const [path, data] of this._store.entries()) {
      if (!path.startsWith(prefix)) continue;
      const rest = path.slice(prefix.length);
      if (rest.includes("/")) continue; // not a direct child
      const matches = this._filters.every((f) => data[f.field] === f.value);
      if (matches) {
        const ref = new FakeDocRef(this._store, path);
        docs.push(new FakeDoc(path.split("/").pop(), data, ref));
      }
    }
    return new FakeQuerySnap(docs);
  }
}

class FakeTransaction {
  constructor(store) {
    this._store = store;
  }
  async get(refOrQuery) {
    return refOrQuery.get();
  }
  set(ref, data) {
    this._store.set(ref.path, {...data});
  }
  update(ref, data) {
    const existing = this._store.get(ref.path) || {};
    this._store.set(ref.path, {...existing, ...data});
  }
  delete(ref) {
    this._store.delete(ref.path);
  }
}

class FakeFirestore {
  constructor(seed = {}) {
    this._store = new Map(Object.entries(seed));
  }
  collection(name) {
    return new FakeCollectionRef(this._store, name);
  }
  async runTransaction(fn) {
    // Simplified: no real optimistic-concurrency retry, just runs once
    // against the shared store. Sufficient for testing the branching
    // logic; concurrency ordering is tested explicitly where it matters.
    const tx = new FakeTransaction(this._store);
    return fn(tx);
  }
  // Test helper — not part of the real Firestore API.
  _dump() {
    return Object.fromEntries(this._store.entries());
  }
  _seedDoc(path, data) {
    this._store.set(path, data);
  }
}

module.exports = {FakeFirestore};