import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/models/product.dart';

class ShopTile extends StatelessWidget {
  final ProductModel product;
  const ShopTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //Product picture
              Icon(Icons.favorite_rounded),

              //product name
              Text(product.name),

              //description
              Text(product.description),
            ],
          ),

          //price
          Text(product.price.toStringAsFixed(2)),
        ],
      ),
    );
  }
}
