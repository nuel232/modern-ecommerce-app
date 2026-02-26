import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/models/cart_item.dart';
import 'package:morden_ecommerce_app/models/product.dart';
import 'package:morden_ecommerce_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartItemsTile extends StatelessWidget {
  final ProductModel product;
  final CartItem cartItem;

  const CartItemsTile({
    super.key,
    required this.product,
    required this.cartItem,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cart = context.read<CartProvider>();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Checkbox(
            value: cartItem.isSelected,
            onChanged: (_) => cart.toggleSelection(cartItem),
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              product.imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: colorScheme.onPrimary,
                child: Icon(Icons.broken_image),
              ),
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '₦${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, size: 20),
                    onPressed: () => cart.updateQuantity(
                      cartItem.cartItemId,
                      cartItem.quantity - 1,
                    ),
                  ),
                  Text(
                    '${cartItem.quantity}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 20),
                    onPressed: () => cart.updateQuantity(
                      cartItem.cartItemId,
                      cartItem.quantity + 1,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => cart.removeFromCart(cartItem),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
