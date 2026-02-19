import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/models/cart_item.dart';
import 'package:morden_ecommerce_app/models/shop.dart';
import 'package:provider/provider.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.read<Shop>();
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Product Image
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(8),
          //   child: Image.asset(
          //     product.imagePath,
          //     width: 60,
          //     height: 60,
          //     fit: BoxFit.cover,
          //     errorBuilder: (context, error, stackTrace) {
          //       return Container(
          //         width: 60,
          //         height: 60,
          //         color: colorScheme.onPrimary,
          //         child: Icon(Icons.broken_image),
          //       );
          //     },
          //   ),
          // ),
          SizedBox(width: 12),
        ],
      ),
    );
  }
}
