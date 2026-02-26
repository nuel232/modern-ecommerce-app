import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/component/my_nav_bar.dart';
import 'package:morden_ecommerce_app/pages/user/cart_page.dart';
import 'package:morden_ecommerce_app/pages/user/Product_page/product_page.dart';
import 'package:morden_ecommerce_app/pages/user/profile_page.dart';
import 'package:morden_ecommerce_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void navigateButtomBar(int index) {
    setState(() => _selectedIndex = index);
  }

  final List<Widget> _pages = [ProductPage(), CartPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    final cartItemCount = context.watch<CartProvider>().cart.length;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: MyNavBar(
          onTabChange: navigateButtomBar,
          text: 'Shop',
          icon: Icons.shopping_bag,
          text2: 'Cart',
          icon2: Icons.shopping_cart_outlined,
          cartItemCount: cartItemCount,
          text3: 'Profile',
          icon3: Icons.person,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _pages[_selectedIndex],
    );
  }
}
