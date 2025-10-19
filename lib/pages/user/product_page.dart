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
            backgroundColor: colorScheme.surface,
            elevation: 1,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              centerTitle: false,
              title: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 50,
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
                                padding:
                                    EdgeInsets.zero, // Remove button padding
                                icon: Icon(Icons.clear, size: 18),
                                onPressed: () => searchController.clear(),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(bottom: 8),
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

          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return ShopTile(product: product);
            }, childCount: products.length),
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
