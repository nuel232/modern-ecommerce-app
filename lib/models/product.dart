class ProductModel {
  final String productId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imagePath;
  final String? categoryId;
  final String? createdAt;

  ProductModel({
    required this.productId,
    required this.description,
    required this.name,
    required this.price,
    required this.stock,
    required this.imagePath,
    this.categoryId,
    this.createdAt,
  });

  //convert the productModel to a map for storing in firestore
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imagePath': imagePath,
      'categoryId': categoryId,
      'createdAt': createdAt,
    };
  }

  //create ProductModel from a map (when reading from Firestore)
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'] ?? '',
      description: map['description'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      imagePath: map['imagePath'] ?? '',
      categoryId: map['categoryId'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }
}
