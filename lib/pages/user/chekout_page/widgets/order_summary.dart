import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/providers/cart_provider.dart';
import 'package:morden_ecommerce_app/providers/product_provider.dart';
import 'package:provider/provider.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();
    final selectedItems = cart.selectedItems;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            Color.alphaBlend(
              colorScheme.secondary.withOpacity(0.05),
              colorScheme.primary,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.secondary.withOpacity(0.15),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 16,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Order Summary',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${selectedItems.length} item${selectedItems.length == 1 ? '' : 's'}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cartItem = selectedItems[index];
              final product = productProvider.getProductById(
                cartItem.productId,
              );

              if (product == null) return const SizedBox();

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: colorScheme.onPrimary.withOpacity(0.04),
                  border: Border.all(
                    color: colorScheme.onPrimary.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  children: [
                    // Product image with quantity badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(
                            product.imagePath,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: colorScheme.secondary,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              '×${cartItem.quantity}',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    // Name + price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '₦${product.price.toStringAsFixed(0)} each',
                            style: GoogleFonts.dmSans(
                              color: colorScheme.onPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Line total
                    Text(
                      '₦${(product.price * cartItem.quantity).toStringAsFixed(0)}',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
