import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/component/shop_tile.dart';
import 'package:morden_ecommerce_app/models/category_model.dart';
import 'package:morden_ecommerce_app/providers/product_provider.dart';
import 'package:morden_ecommerce_app/pages/user/Product_page/widgets/category_chip_widgets.dart';
import 'package:morden_ecommerce_app/pages/user/Product_page/widgets/search_bar_delegate.dart';
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
    final productProvider = context.watch<ProductProvider>();
    final allProducts = productProvider.products;
    final filteredProducts = productProvider.filteredProducts;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body:
          CustomScrollView(
                slivers: [
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
                          color: colorScheme.onPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      centerTitle: false,
                    ),
                  ),

                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SearchBarDelegate(
                      colorScheme: colorScheme,
                      searchController: searchController,
                      onCartPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartPage()),
                        );
                      },
                    ),
                  ),

                  // Hot Picks
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: allProducts.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 180,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: ShopTile(
                                      product: allProducts[index],
                                    ),
                                  );
                                },
                              ),
                            )
                            .animate(target: 1)
                            .moveX(
                              begin: 1000,
                              delay: 200.ms,
                              duration: 600.ms,
                              curve: Curves.fastLinearToSlowEaseIn,
                            ),
                      ],
                    ),
                  ),

                  // All Products header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Text(
                        'All Products',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),

                  // Category Chips
                  SliverToBoxAdapter(
                    child: Container(
                      height: 28,
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        children: categories.map((category) {
                          return CategoryChipWidgets(
                            categoryId: category.categoryId,
                            categoryName: category.name,
                            isSelected:
                                productProvider.selectedCategory ==
                                category.categoryId,
                            onTap: () => productProvider.setCategory(
                              category.categoryId,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Products Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            ShopTile(product: filteredProducts[index]),
                        childCount: filteredProducts.length,
                      ),
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(
                delay: 200.ms,
                duration: 600.ms,
                curve: Curves.fastEaseInToSlowEaseOut,
              )
              .moveY(begin: 100),
    );
  }
}
