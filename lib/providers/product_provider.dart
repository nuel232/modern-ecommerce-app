import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/models/product.dart';
import 'package:morden_ecommerce_app/services/shop/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  //list of products
  List<ProductModel> _products = [];
  String _selectedCategory = 'Cat_000';

  List<ProductModel> get products => _products;
  String get selectedCategory => _selectedCategory;

  // Filtered products based on selected category
  List<ProductModel> get filteredProducts {
    if (_selectedCategory == 'Cat_000') return _products;
    return _products.where((p) => p.categoryId == _selectedCategory).toList();
  }

  // Start listening to Firestore products stream
  void listenToProducts() {
    _productService.getProductsStream().listen((products) {
      _products = products;
      notifyListeners();
    });
  }

  void setCategory(String categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  ProductModel? getProductById(String productId) {
    try {
      return _products.firstWhere((p) => p.productId == productId);
    } catch (_) {
      return null;
    }
  }
}
