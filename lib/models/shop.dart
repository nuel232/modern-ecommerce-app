import 'package:flutter/cupertino.dart';

import 'package:morden_ecommerce_app/models/product.dart';

class Shop extends ChangeNotifier {
  final List<ProductModel> _shop = [
    ProductModel(
      productId: '1',
      name: 'Air Deledon',
      description: 'Built to break barriers, made for all athletes.',
      price: 160000,
      stock: 5,
      imagePath: 'lib/Images/Air-deldon.png',
    ),

    ProductModel(
      productId: '2',
      name: 'G.T. Cut 3',
      description: 'Engineered for explosive guards.',
      price: 115000,
      stock: 5,
      imagePath: 'lib/Images/GT.png',
    ),

    ProductModel(
      productId: '3',
      name: 'Tatum 3 “Tie-Dye”',
      description: 'Unleash your creativity with the Tatum 3',
      price: 110000,
      stock: 5,
      imagePath: 'lib/Images/Tatum-3-tie-dye2.png',
    ),

    ProductModel(
      productId: '4',
      name: 'Tatum 3',
      description: 'Minimal, clean and powerful... The Jordan Tatum 3.',
      price: 110000,
      stock: 5,
      imagePath: 'lib/Images/Tatum-3-white.png',
    ),

    ProductModel(
      productId: '5',
      name: 'Zoom Freak 4',
      description: 'Dominate like Giannis in the Nike Zoom Freak 4.',
      price: 130000,
      stock: 5,
      imagePath: 'lib/Images/Zoom-freek-4.jpg',
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
