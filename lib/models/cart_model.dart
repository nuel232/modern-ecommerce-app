import 'package:morden_ecommerce_app/models/cart_item.dart';

class CartModel {
  final String cartId;
  final String userId;
  final List<CartItem> items; // All the cart items

  CartModel({required this.cartId, required this.userId, required this.items});

  Map<String, dynamic> toMap() {
    return {'cartId': cartId, 'userId': userId, 'items': items};
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      cartId: map['cartId'] ?? '',
      userId: map['userId'] ?? '',
      items: List<CartItem>.from(map['items'] ?? []),
    );
  }
}
