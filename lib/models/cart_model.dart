import 'package:morden_ecommerce_app/models/cart_item.dart';

class CartModel {
  final String cartId;
  final String userId;
  final List<CartItem> items; // All the cart items

  CartModel({required this.cartId, required this.userId, required this.items});

  double get totalPrice {
    return items.fold(0.0, (sum, item) {
      // We'll need to multiply by product price, but we don't have it here
      // So this will be calculated in the UI where we have access to products
      return sum;
    });
  }

  Map<String, dynamic> toMap() {
    return {'cartId': cartId, 'userId': userId};
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      cartId: map['cartId'] ?? '',
      userId: map['userId'] ?? '',
      items: List<CartItem>.from(map['items'] ?? []),
    );
  }
}
