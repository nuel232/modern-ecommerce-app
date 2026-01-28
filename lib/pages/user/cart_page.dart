import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/component/cart_items_tile.dart';
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
            TextButton(onPressed: () {}, child: Text('Clear')),
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
          : Column(
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
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
