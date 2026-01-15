import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/models/shop.dart';
import 'package:provider/provider.dart';

class CartItemsTile extends StatelessWidget {
  const CartItemsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Shop>().cart;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          //cart list
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                //get inidiviual items in cart and

                final item = cart[index];

                // return as a list tile
                return ListTile(
                  leading: Row(
                    children: [
                      Checkbox(value: item.isSelected, onChanged: (value) {}),

                      const SizedBox(width: 4),
                      Image.asset(
                        item.imagePath,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),

                  //name and price
                  title: Text(item.name),
                  subtitle: Text(
                    '₦${item.price.toStringAsFixed(2)}',
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              // decrease quantity
                            },
                          ),
                          Text(item.quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              // increase quantity
                            },
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // remove from cart
                        },
                      ),
                    ],
                  ),
                );
                //
              },
            ),
          ),
        ],
      ),
    );
  }
}
