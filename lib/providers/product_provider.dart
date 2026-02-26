import 'dart:async';
import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/models/product.dart';
import 'package:morden_ecommerce_app/services/shop/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  String _selectedCategory = 'Cat_000';
  StreamSubscription? _subscription;

  List<ProductModel> get products => _products;
  String get selectedCategory => _selectedCategory;

  List<ProductModel> get filteredProducts {
    if (_selectedCategory == 'Cat_000') return _products;
    return _products.where((p) => p.categoryId == _selectedCategory).toList();
  }

  void listenToProducts() {
    // Cancel any existing subscription before starting a new one
    _subscription?.cancel();

    _subscription = _productService.getProductsStream().listen((products) {
      _products = products;
      notifyListeners();
    }, onError: (e) => print('ProductProvider stream error: $e'));
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
