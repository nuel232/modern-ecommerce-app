import 'dart:async';
import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/models/cart_item.dart';
import 'package:morden_ecommerce_app/models/product.dart';
import 'package:morden_ecommerce_app/services/shop/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItem> _cart = [];
  String? _uid;
  StreamSubscription? _subscription;

  List<CartItem> get cart => _cart;

  void listenToCart(String uid) {
    // Cancel any existing subscription before starting a new one
    _subscription?.cancel();

    _uid = uid;
    _subscription = _cartService.getCartStream(uid).listen((items) {
      _cart = items;
      notifyListeners();
    }, onError: (e) => print('CartProvider stream error: $e'));
  }

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
    await _cartService.toggleSelectAll(_uid!, _cart, !areAllSelected());
  }

  Future<void> clearCart() async {
    if (_uid == null) return;
    await _cartService.clearCart(_uid!);
  }

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

  // Called on logout — clears local cart state and stops listening
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _uid = null;
    _cart = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
