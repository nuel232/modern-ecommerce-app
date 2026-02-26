import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:morden_ecommerce_app/component/cart_items_tile.dart';
import 'package:morden_ecommerce_app/component/my_button.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/checkout_page.dart';
import 'package:morden_ecommerce_app/providers/cart_provider.dart';
import 'package:morden_ecommerce_app/providers/product_provider.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();
    final cartItems = cart.cart;
    final total = cart.getCartTotal(productProvider.products);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Clear Cart?'),
                    content: Text('Are you sure you want to remove all items?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            cart.clearCart();
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.2),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Add items to get started'),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];
                        final product = productProvider.getProductById(
                          cartItem.productId,
                        );

                        if (product == null) return SizedBox();

                        return CartItemsTile(
                              product: product,
                              cartItem: cartItem,
                            )
                            .animate()
                            .fadeIn(
                              delay: 200.ms,
                              duration: 600.ms,
                              curve: Curves.fastEaseInToSlowEaseOut,
                            )
                            .moveY(begin: 100);
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Checkbox(
                                value: cart.areAllSelected(),
                                onChanged: (_) => cart.toggleSelectAll(),
                              ),
                              Text(
                                'Select All',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  '${cart.selectedCount()} / ${cartItems.length} selected',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondary.withOpacity(0.6),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        MyButton(
                          borderRadius: BorderRadius.circular(18),
                          text: 'Checkout (₦${total.toStringAsFixed(0)})',
                          padding: EdgeInsetsGeometry.all(15),
                          margin: EdgeInsetsGeometry.only(right: 15, left: 10),
                          onTap: () {
                            final currentUser =
                                FirebaseAuth.instance.currentUser;

                            if (currentUser == null) {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (context) => Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        size: 60,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                      SizedBox(height: 20),
                                      Text('Login Required'),
                                      Text(
                                        'Please login or create an account to checkout',
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 20),
                                      MyButton(
                                        text: 'Login / Sign Up',
                                        onTap: () => Navigator.pop(context),
                                      ),
                                      SizedBox(height: 10),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Continue Shopping'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              if (cart.selectedItems.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please select items to checkout',
                                    ),
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutPage(),
                                ),
                              );
                            }
                          },
                        ).animate().fadeIn(
                          delay: 200.ms,
                          duration: 600.ms,
                          curve: Curves.fastEaseInToSlowEaseOut,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
