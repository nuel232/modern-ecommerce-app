import 'package:flutter/cupertino.dart';
import 'package:morden_ecommerce_app/models/product.dart';

class Shop extends ChangeNotifier {
  List<Product> _shop = [
    Product(description: 'hey', name: 'jordan', price: 500),
    Product(description: 'hey', name: 'jordan', price: 500),
    Product(description: 'hey', name: 'jordan', price: 500),
    Product(description: 'hey', name: 'jordan', price: 500),
    Product(description: 'hey', name: 'jordan', price: 500),
    Product(description: 'hey', name: 'jordan', price: 500),
  ];

  //user cart
  List<Product> _cart = [];

  //get the the products and the cart
  List<Product> get shop => _shop;

  //get the products int t  he cart
  List<Product> get cart => _cart;

  //add to cart
  void addToCart(Product item) {
    _cart.add(item);
  }

  //remove from cart
  void removeFromCart(Product item) {
    _cart.remove(item);
  }
}
