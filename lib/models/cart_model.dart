class CartModel {
  final String cartId;
  final String userId;
  final List<String> productIds;
  final double totalPrice;
  final double quantity;

  CartModel({
    required this.cartId,
    required this.userId,
    required this.productIds,
    required this.totalPrice,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'cartId': cartId,
      'userId': userId,
      'productIds': productIds,
      'totalPrice': totalPrice,
      'quantity': quantity,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      cartId: map['cartId'] ?? '',
      userId: map['userId'] ?? '',
      productIds: List<String>.from(map['productIds'] ?? []),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 0).toDouble(),
    );
  }
}
