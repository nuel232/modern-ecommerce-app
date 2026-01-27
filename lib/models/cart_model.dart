import 'package:morden_ecommerce_app/models/cart_item.dart';

class CartModel {
  final String cartId;
  final String userId;
  final List<CartItem> items; // All the cart items
  final double totalPrice;

  CartModel({
    required this.cartId,
    required this.userId,
    required this.totalPrice,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {'cartId': cartId, 'userId': userId, 'totalPrice': totalPrice};
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      cartId: map['cartId'] ?? '',
      userId: map['userId'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      items: List<CartItem>.from(map['items'] ?? []),
    );
  }
}
