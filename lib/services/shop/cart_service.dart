import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:morden_ecommerce_app/models/cart_item.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _cartRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('cart');

  // Stream all cart items for a user
  Stream<List<CartItem>> getCartStream(String uid) {
    return _cartRef(uid).snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList(),
    );
  }

  // Add or increment quantity if product already in cart
  Future<void> addToCart(String uid, String productId) async {
    try {
      final query = await _cartRef(
        uid,
      ).where('productId', isEqualTo: productId).limit(1).get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final current = CartItem.fromMap(doc.data());
        await doc.reference.update({'quantity': current.quantity + 1});
      } else {
        // Generate a new doc reference first, then use its id
        final docRef = _cartRef(uid).doc();
        final newItem = CartItem(
          cartItemId: docRef.id,
          productId: productId,
          quantity: 1,
          isSelected: true,
        );
        await docRef.set(newItem.toMap());
      }
    } catch (e) {
      print('CartService addToCart error: $e');
      rethrow;
    }
  }

  // Remove a cart item
  Future<void> removeFromCart(String uid, String cartItemId) async {
    await _cartRef(uid).doc(cartItemId).delete();
  }

  // Update quantity — removes if quantity <= 0
  Future<void> updateQuantity(
    String uid,
    String cartItemId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      await removeFromCart(uid, cartItemId);
    } else {
      await _cartRef(uid).doc(cartItemId).update({'quantity': quantity});
    }
  }

  // Toggle selection for a single item
  Future<void> toggleSelection(
    String uid,
    String cartItemId,
    bool current,
  ) async {
    await _cartRef(uid).doc(cartItemId).update({'isSelected': !current});
  }

  // Select or deselect all items
  Future<void> toggleSelectAll(
    String uid,
    List<CartItem> items,
    bool selectAll,
  ) async {
    final batch = _firestore.batch();
    for (final item in items) {
      batch.update(_cartRef(uid).doc(item.cartItemId), {
        'isSelected': selectAll,
      });
    }
    await batch.commit();
  }

  // Clear all cart items
  Future<void> clearCart(String uid) async {
    final snapshot = await _cartRef(uid).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
