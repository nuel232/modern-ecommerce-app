import 'package:flutter/cupertino.dart';

import 'package:morden_ecommerce_app/models/product.dart';

class Shop extends ChangeNotifier {
  final List<ProductModel> _shop = [
    ProductModel(
      productId: '1',
      description: 'hey',
      name: 'jordan',
      price: 500,
      stock: 2,
      imagePath: '',
    ),
    ProductModel(
      productId: '2',
      description: 'hey',
      name: 'jordan',
      price: 500,
      stock: 2,
      imagePath: '',
    ),
    ProductModel(
      productId: '3',
      description: 'hey',
      name: 'jordan',
      price: 500,
      stock: 2,
      imagePath: '',
    ),
    ProductModel(
      productId: '4',
      description: 'hey',
      name: 'jordan',
      price: 500,
      stock: 2,
      imagePath: '',
    ),
    ProductModel(
      productId: '5',
      description: 'hey',
      name: 'jordan',
      price: 500,
      stock: 2,
      imagePath: '',
    ),
    ProductModel(
      productId: '6',
      description: 'hey',
      name: 'jordan',
      price: 500,
      stock: 2,
      imagePath: '',
    ),
  ];

  //user cart
  final List<ProductModel> _cart = [];

  //get the the ProductModels and the cart
  List<ProductModel> get shop => _shop;

  //get the ProductModels int t  he cart
  List<ProductModel> get cart => _cart;

  //add to cart
  void addToCart(ProductModel item) {
    _cart.add(item);
  }

  //remove from cart
  void removeFromCart(ProductModel item) {
    _cart.remove(item);
  }
}
