import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/models/cart_item.dart';
import 'package:morden_ecommerce_app/models/product.dart';
import 'package:morden_ecommerce_app/services/shop/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItem> _cart = [];
  String? _uid;

  List<CartItem> get cart => _cart;

  // Start listening to Firestore cart stream for this user
  void listenToCart(String uid) {
    _uid = uid;
    _cartService.getCartStream(uid).listen((items) {
      _cart = items;
      notifyListeners();
    });
  }

  // --- Cart actions (all delegate to CartService) ---

  Future<void> addToCart(String productId) async {
    if (_uid == null) return;
    await _cartService.addToCart(_uid!, productId);
  }

  Future<void> removeFromCart(CartItem item) async {
    if (_uid == null) return;
    await _cartService.removeFromCart(_uid!, item.cartItemId);
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (_uid == null) return;
    await _cartService.updateQuantity(_uid!, cartItemId, quantity);
  }

  Future<void> toggleSelection(CartItem item) async {
    if (_uid == null) return;
    await _cartService.toggleSelection(_uid!, item.cartItemId, item.isSelected);
  }

  Future<void> toggleSelectAll() async {
    if (_uid == null) return;
    final allSelected = areAllSelected();
    await _cartService.toggleSelectAll(_uid!, _cart, !allSelected);
  }

  Future<void> clearCart() async {
    if (_uid == null) return;
    await _cartService.clearCart(_uid!);
  }

  // --- Helpers ---

  bool areAllSelected() {
    if (_cart.isEmpty) return false;
    return _cart.every((item) => item.isSelected);
  }

  int selectedCount() => _cart.where((item) => item.isSelected).length;

  List<CartItem> get selectedItems => _cart.where((i) => i.isSelected).toList();

  double getCartTotal(List<ProductModel> products) {
    double total = 0;
    for (final item in _cart) {
      if (!item.isSelected) continue;
      final product = products.firstWhere(
        (p) => p.productId == item.productId,
        orElse: () => ProductModel(
          productId: '',
          name: '',
          description: '',
          price: 0,
          stock: 0,
          imagePath: '',
        ),
      );
      total += product.price * item.quantity;
    }
    return total;
  }
}
