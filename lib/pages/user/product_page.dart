import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/component/my_textfield.dart';
import 'package:morden_ecommerce_app/component/shop_tile.dart';
import 'package:morden_ecommerce_app/models/shop.dart';
import 'package:morden_ecommerce_app/pages/user/cart_page.dart';
import 'package:provider/provider.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final TextEditingController searchController = TextEditingController();
    final products = context.watch<Shop>().shop;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 120,
            collapsedHeight: kToolbarHeight, // Standard toolbar height

            backgroundColor: colorScheme.surface,
            elevation: 1,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              centerTitle: false,
              // This shows "Shop" text when expanded, scrolls away when collapsed
              title: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Shop',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Search bar and cart icon stay fixed at the bottom
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: MyTextfield(
                          padding: EdgeInsets.all(10),
                          controller: searchController,
                          hintText: 'Search...',
                          obscureText: false,
                          borderRadius: 8,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          prefixIcon: Icon(Icons.search, size: 18),
                          suffixIcon: searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.clear, size: 18),
                                  onPressed: () => searchController.clear(),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
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
                  ],
                ),
              ),
            ),
            // Remove the old actions since cart icon is now in bottom
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
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text('Product $index')),
                );
              }, childCount: 20),
            ),
          ),
        ],
      ),
    );
  }
}
