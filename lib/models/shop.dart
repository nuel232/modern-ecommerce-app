import 'package:flutter/cupertino.dart';

import 'package:morden_ecommerce_app/models/product.dart';

class Shop extends ChangeNotifier {
  final List<ProductModel> _shop = [
    // ===== SHOES =====
    ProductModel(
      productId: '1',
      name: 'Air Deldon',
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
      name: 'Tatum 3 Tie-Dye',
      description: 'Unleash your creativity with the Tatum 3.',
      price: 110000,
      stock: 5,
      imagePath: 'lib/Images/Tatum-3-tie-dye.png',
    ),

    ProductModel(
      productId: '4',
      name: 'Tatum 3 Tie-Dye (Alt)',
      description: 'Bold colors meet elite performance.',
      price: 110000,
      stock: 5,
      imagePath: 'lib/Images/Tatum-3-tie-dye2.png',
    ),

    ProductModel(
      productId: '5',
      name: 'Zoom Freak 4',
      description: 'Dominate like Giannis in the Nike Zoom Freak 4.',
      price: 130000,
      stock: 5,
      imagePath: 'lib/Images/Zoom-freek-4.jpg',
    ),

    ProductModel(
      productId: '6',
      name: 'Black Shoe Air',
      description: 'Clean black design with everyday comfort.',
      price: 95000,
      stock: 8,
      imagePath: 'lib/Images/Black-shoe-air.webp',
    ),

    ProductModel(
      productId: '7',
      name: 'H-Penny Sneakers',
      description: 'Classic street-style sneakers with comfort.',
      price: 105000,
      stock: 6,
      imagePath: 'lib/Images/H-Penny.jpg',
    ),

    ProductModel(
      productId: '8',
      name: 'Nike Casual Sneakers',
      description: 'Lightweight everyday Nike sneakers.',
      price: 90000,
      stock: 10,
      imagePath: 'lib/Images/nike.png',
    ),

    ProductModel(
      productId: '9',
      name: 'Brandon Step Loafer',
      description: 'Premium loafers for smart and casual wear.',
      price: 85000,
      stock: 7,
      imagePath: 'lib/Images/Brandon Step Loafer.webp',
    ),

    ProductModel(
      productId: '10',
      name: 'Craft Arlo Lace',
      description: 'Handcrafted lace shoes with modern elegance.',
      price: 98000,
      stock: 6,
      imagePath: 'lib/Images/Craft Arlo Lace.webp',
    ),

    // ===== ACCESSORIES =====
    ProductModel(
      productId: '11',
      name: 'Adwin Cap',
      description: 'Stylish cap for casual and sporty outfits.',
      price: 18000,
      stock: 15,
      imagePath: 'lib/Images/Adwin Cap.webp',
    ),

    ProductModel(
      productId: '12',
      name: 'Classic Glasses',
      description: 'Fashion-forward glasses for daily wear.',
      price: 25000,
      stock: 12,
      imagePath: 'lib/Images/Glasses.jpg',
    ),

    ProductModel(
      productId: '13',
      name: 'Poplin Classic Fit Shirt',
      description: 'Comfortable classic-fit shirt for all occasions.',
      price: 42000,
      stock: 10,
      imagePath: 'lib/Images/POPIN CLASSIC FIT.webp',
    ),

    ProductModel(
      productId: '14',
      name: 'Silk Cotton Blend Shirt',
      description: 'Soft silk-cotton blend for premium comfort.',
      price: 48000,
      stock: 9,
      imagePath: 'lib/Images/SILK COTTON BLEND.webp',
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
