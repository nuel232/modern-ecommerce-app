class ProductModel {
  final String uid;

  final String name;
  final String description;
  final double price;
  final int stock;
  final String imagePath;

  ProductModel({
    required this.uid,
    required this.description,
    required this.name,
    required this.price,
    required this.stock,
    required this.imagePath,
  });

  //convert the productModel to a map for storing in firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imagePath': imagePath,
    };
  }

  //create ProductModel from a map (when reading from Firestore)
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      uid: map['uid'] ?? '',
      description: map['description'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      stock: map['stock'] ?? '',
      imagePath: map['imagePath'] ?? '',
    );
  }
}
