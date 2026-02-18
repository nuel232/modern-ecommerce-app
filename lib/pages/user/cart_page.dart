import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:morden_ecommerce_app/component/cart_items_tile.dart';
import 'package:morden_ecommerce_app/component/my_button.dart';
import 'package:morden_ecommerce_app/models/cart_item.dart';
import 'package:morden_ecommerce_app/pages/user/chekout_page/checkout_page.dart';
import 'package:morden_ecommerce_app/models/shop.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<Shop>();
    final CartItems = shop.cart;
    final total = shop.getCartTotal();

    return Scaffold(
      appBar: AppBar(
        title: Container(child: Text('Cart')),
        actions: [
          if (CartItems.isNotEmpty)
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
                            shop.clearCart();
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
      body: CartItems.isEmpty
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
                      itemCount: CartItems.length,
                      itemBuilder: (context, index) {
                        final CartItem = CartItems[index];
                        final product = shop.getProductById(CartItem.productId);

                        if (product == null) {
                          return SizedBox();
                        }

                        return CartItemsTile(
                              product: product,
                              cartItem: CartItem,
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
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  // Checkbox
                                  Checkbox(
                                    value: shop.areAllItemsSelected(),
                                    onChanged: (value) {
                                      shop.toggleSelectAll();
                                    },
                                  ),

                                  Text(
                                    'Select All',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(width: 10),

                              Flexible(
                                child: Text(
                                  '${shop.getSelectedItemsCount()} / ${CartItems.length} selected',
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
                          text: 'Checkout (${shop.getCartTotal()})',
                          padding: EdgeInsetsGeometry.all(15),
                          margin: EdgeInsetsGeometry.only(right: 15, left: 10),

                          onTap: () {
                            //check if the user is logged in
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
                                      Text('login Required'),
                                      Text(
                                        'Please login or create an account to checkout',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      MyButton(
                                        text: 'Login / Sign Up',
                                        onTap: () {
                                          Navigator.pop(
                                            context,
                                          ); // Close bottom sheet
                                          // Note: AuthGate will automatically show login
                                          // when user signs out and tries to access
                                        },
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
                              // User is logged in, proceed to checkout
                              final selectedItems = shop.cart
                                  .where((item) => item.isSelected)
                                  .toList();

                              if (selectedItems.isEmpty) {
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
                                  builder: (context) => CheckoutPage(),
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
