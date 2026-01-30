import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:morden_ecommerce_app/component/cart_items_tile.dart';
import 'package:morden_ecommerce_app/component/my_button.dart';
import 'package:morden_ecommerce_app/models/cart_item.dart';
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
        title: Text('Cart'),
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
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          shop.clearCart();
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Text('Clear'),
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
                    ).colorScheme.onSurface.withOpacity(0.3),
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
                    child:
                        MyButton(
                          text: 'Checkout (${shop.getCartTotal()})',
                          onTap: () {},
                        ).animate().fadeIn(
                          delay: 200.ms,
                          duration: 600.ms,
                          curve: Curves.fastEaseInToSlowEaseOut,
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}
