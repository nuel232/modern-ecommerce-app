import 'package:flutter/material.dart';

class SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final ColorScheme colorScheme;
  final TextEditingController searchController;
  final VoidCallback onCartPressed;

  SearchBarDelegate({
    required this.colorScheme,
    required this.searchController,
    required this.onCartPressed,
  });

  @override
  double get minExtent => 64.0;

  @override
  double get maxExtent => 64.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: 64.0,
      color: colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: colorScheme.onPrimary),
                  prefixIcon: Icon(Icons.search, size: 20),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: colorScheme.onPrimary,
              ),
              onPressed: onCartPressed,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SearchBarDelegate oldDelegate) {
    return oldDelegate.colorScheme != colorScheme ||
        oldDelegate.searchController != searchController;
  }
}
