class CategoryModel {
  final String categoryId;
  final String name;
  final String? description;
  final String? imagePath;

  CategoryModel({
    required this.categoryId,
    required this.name,
    this.description,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'imagePath': imagePath,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      categoryId: map['categoryId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'] ?? '',
    );
  }
}

final List<CategoryModel> categories = [
  CategoryModel(categoryId: 'Cat_000', name: "All"),
  CategoryModel(categoryId: 'Cat_001', name: "Shoe"),
  CategoryModel(categoryId: 'Cat_002', name: "Accessories"),
  CategoryModel(categoryId: 'Cat_003', name: "Shirt"),
];
