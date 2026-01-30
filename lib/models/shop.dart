import 'package:flutter/cupertino.dart';
import 'package:morden_ecommerce_app/models/cart_item.dart';

import 'package:morden_ecommerce_app/models/product.dart';
import 'package:uuid/uuid.dart';

class Shop extends ChangeNotifier {
  final List<ProductModel> _shop = [
    // ===== SHOES (Cat_001) =====
    ProductModel(
      productId: '1',
      categoryId: 'Cat_001',
      name: 'Air Deldon',
      description: 'Built to break barriers, made for all athletes.',
      price: 160000,
      stock: 5,
      imagePath: 'lib/Images/Air-deldon.png',
    ),

    ProductModel(
      productId: '2',
      categoryId: 'Cat_001',
      name: 'G.T. Cut 3',
      description: 'Engineered for explosive guards.',
      price: 115000,
      stock: 5,
      imagePath: 'lib/Images/GT.png',
    ),

    ProductModel(
      productId: '3',
      categoryId: 'Cat_001',
      name: 'Tatum 3 Tie-Dye',
      description: 'Unleash your creativity with the Tatum 3.',
      price: 110000,
      stock: 5,
      imagePath: 'lib/Images/Tatum-3-tie-dye.png',
    ),

    ProductModel(
      productId: '4',
      categoryId: 'Cat_001',
      name: 'Tatum 3 Tie-Dye (Alt)',
      description: 'Bold colors meet elite performance.',
      price: 110000,
      stock: 5,
      imagePath: 'lib/Images/Tatum-3-tie-dye2.png',
    ),

    ProductModel(
      productId: '5',
      categoryId: 'Cat_001',
      name: 'Zoom Freak 4',
      description: 'Dominate like Giannis in the Nike Zoom Freak 4.',
      price: 130000,
      stock: 5,
      imagePath: 'lib/Images/Zoom-freek-4.jpg',
    ),

    ProductModel(
      productId: '6',
      categoryId: 'Cat_001',
      name: 'Black Shoe Air',
      description: 'Clean black design with everyday comfort.',
      price: 95000,
      stock: 8,
      imagePath: 'lib/Images/Black-shoe.jpeg',
    ),

    ProductModel(
      productId: '7',
      categoryId: 'Cat_001',
      name: 'H-Penny Sneakers',
      description: 'Classic street-style sneakers with comfort.',
      price: 105000,
      stock: 6,
      imagePath: 'lib/Images/HP-envy.jpg',
    ),

    ProductModel(
      productId: '8',
      categoryId: 'Cat_001',
      name: 'Brandon Step Loafer',
      description: 'Premium loafers for smart and casual wear.',
      price: 85000,
      stock: 7,
      imagePath: 'lib/Images/Brandon-Step-Loafer.jpeg',
    ),

    ProductModel(
      productId: '9',
      categoryId: 'Cat_001',
      name: 'Craft Arlo Lace',
      description: 'Handcrafted lace shoes with modern elegance.',
      price: 98000,
      stock: 6,
      imagePath: 'lib/Images/Craft-Arlo-Lace.jpeg',
    ),

    ProductModel(
      productId: '10',
      categoryId: 'Cat_002',
      name: 'Adwin Cap',
      description: 'Stylish cap for casual and sporty outfits.',
      price: 18000,
      stock: 15,
      imagePath: 'lib/Images/Aldwin-Cap.jpg',
    ),

    // ===== ACCESSORIES (Cat_002) =====
    ProductModel(
      productId: '11',
      categoryId: 'Cat_002',
      name: 'Classic Glasses',
      description: 'Fashion-forward glasses for daily wear.',
      price: 25000,
      stock: 12,
      imagePath: 'lib/Images/Glasses.jpg',
    ),

    // ===== SHIRTS / CLOTHING (Cat_003) =====
    ProductModel(
      productId: '12',
      categoryId: 'Cat_003',
      name: 'Poplin Classic Fit Shirt',
      description: 'Comfortable classic-fit shirt for all occasions.',
      price: 42000,
      stock: 10,
      imagePath: 'lib/Images/POPLIN-CLASSIC-FIT-SHIRT.jpg',
    ),

    ProductModel(
      productId: '13',
      categoryId: 'Cat_003',
      name: 'Silk Cotton Blend Shirt',
      description: 'Soft silk-cotton blend for premium comfort.',
      price: 48000,
      stock: 9,
      imagePath: 'lib/Images/SILK-COTTON-BLEND-SHIRT.png',
    ),

    ProductModel(
      productId: '14',
      categoryId: 'Cat_003',
      name: 'Silk Cotton Blend Shirt',
      description: 'Soft silk-cotton blend for premium comfort.',
      price: 48000,
      stock: 9,
      imagePath: 'lib/Images/SILK-COTTON-BLEND-SHIRT.png',
    ),
  ];

  //user cart
  final List<CartItem> _cart = [];

  //get the the ProductModels and the cart
  List<ProductModel> get shop => _shop;

  //get the ProductModels int t  he cart
  List<CartItem> get cart => _cart;

  //add to cart - Create a CartItem
  void addToCart(ProductModel product) {
    //check if product already exists in cart
    final existingIndex = _cart.indexWhere(
      (item) => item.productId == product.productId,
    );

    if (existingIndex != -1) {
      //Products  exists, increase quantity
      final existing = _cart[existingIndex];
      _cart[existingIndex] = CartItem(
        cartItemId: existing.cartItemId,
        isSelected: existing.isSelected,
        productId: existing.productId,
        quantity: existing.quantity + 1,
      );
      notifyListeners();
    } else {
      _cart.add(
        CartItem(
          cartItemId: Uuid().v4(),
          isSelected: true,
          productId: product.productId,
          quantity: 1,
        ),
      );
      notifyListeners();
    }
  }

  //remove from cart
  void removeFromCart(CartItem cartItem) {
    _cart.removeWhere((item) => item.cartItemId == cartItem.cartItemId);
    notifyListeners();
  }

  //clear the whole cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  //update quantity
  void updateCartItemQuantity(String cartItemId, newQuantity) {
    final index = _cart.indexWhere((item) => item.cartItemId == cartItemId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _cart.removeAt(index);
      } else {
        final item = _cart[index];
        _cart[index] = CartItem(
          cartItemId: item.cartItemId,
          isSelected: item.isSelected,
          productId: item.productId,
          quantity: newQuantity,
        );
      }
      notifyListeners();
    }
  }

  //toggle cart item selection
  void toggleCartItemSelection(String cartItemId) {
    final index = _cart.indexWhere((item) => item.cartItemId == cartItemId);
    if (index != -1) {
      final item = _cart[index];
      _cart[index] = CartItem(
        cartItemId: item.cartItemId,
        isSelected: !item.isSelected,
        productId: item.productId,
        quantity: item.quantity,
      );
      notifyListeners();
    }
  }

  //Get product by ID (helper method for cart page)
  ProductModel? getProductById(String productId) {
    try {
      return _shop.firstWhere((product) => product.productId == productId);
    } catch (e) {
      return null;
    }
  }

  //calculate total price of selected items
  double getCartTotal() {
    double total = 0.0;
    for (var cartItem in _cart) {
      if (cartItem.isSelected) {
        final product = getProductById(cartItem.productId);
        if (product != null) {
          total += product.price * cartItem.quantity;
        }
      }
    }
    return total;
  }
}
