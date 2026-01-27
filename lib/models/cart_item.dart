class CartItem {
  final String cartItemId;
  final String productId; // Reference to the product
  final int quantity; // How many user wants to buy
  final bool isSelected; // Checkbox state

  CartItem({
    required this.cartItemId,
    required this.isSelected,
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'cartItemId': cartItemId,
      'productId': productId,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      cartItemId: map['cartItemId'] ?? '',
      productId: map['productId'] ?? '',
      quantity: map['quantity'] ?? 1,
      isSelected: map['isSelected'] ?? false,
    );
  }
}
