import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/component/my_textfield.dart';
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
          SliverAppBar(
            pinned: true, // Keeps the app bar fixed
            floating: false,
            expandedHeight: 100, // Height when expanded
            backgroundColor: colorScheme.surface,
            elevation: 0,
            // The "Shop" title that scrolls away
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 16, bottom: 16),
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

          // Fixed search bar and cart icon (pinned below the app bar)
          SliverPersistentHeader(
            pinned: true, // This keeps it fixed
            delegate: _SearchBarDelegate(
              colorScheme: colorScheme,
              searchController: searchController,
              minHeight: 70,
              maxHeight: 70,
            ),
          ),

          // Hot Picks Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 24,
                      ),
                      SizedBox(width: 8),
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
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        width: 180,
                        margin: EdgeInsets.only(right: 16),
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
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
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
            padding: EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = products[index % products.length];
                return ShopTile(product: product);
              }, childCount: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom delegate for the search bar that stays pinned
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final ColorScheme colorScheme;
  final TextEditingController searchController;
  final double minHeight;
  final double maxHeight;

  _SearchBarDelegate({
    required this.colorScheme,
    required this.searchController,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.tertiary),
                  ),
                  fillColor: colorScheme.primary,
                  filled: true,
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.clear, size: 18),
                          onPressed: () => searchController.clear(),
                        ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: colorScheme.onSurface,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) {
    return oldDelegate.searchController.text != searchController.text ||
        oldDelegate.colorScheme != colorScheme;
  }
}
