import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/component/shop_tile.dart';
import 'package:morden_ecommerce_app/models/shop.dart';
import 'package:morden_ecommerce_app/pages/user/cart_page.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final products = context.watch<Shop>().shop;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // App bar with "Shop" title that scrolls away
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 100,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 10),
              title: Text(
                'Shop',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
            ),
          ),

          // Fixed search bar and cart icon
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              colorScheme: colorScheme,
              searchController: searchController,
              onCartPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
            ),
          ),

          // Hot Picks Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hot Picks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 16),
                        child: ShopTile(product: product),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // All Products Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'All Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          // All Products Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                try {
                  final product = products[index];
                  return ShopTile(product: product);
                } catch (e) {
                  print('Error rendering product at index $index: $e');
                  return Container(
                    color: Colors.red[100],
                    child: Center(child: Text('Error loading product')),
                  );
                }
              }, childCount: products.length),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom delegate for the search bar
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final ColorScheme colorScheme;
  final TextEditingController searchController;
  final VoidCallback onCartPressed;

  _SearchBarDelegate({
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
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search...',
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
                color: colorScheme.onSurface,
              ),
              onPressed: onCartPressed,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return oldDelegate.colorScheme != colorScheme ||
        oldDelegate.searchController != searchController;
  }
}
