import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/component/my_nav_bar.dart';
import 'package:morden_ecommerce_app/pages/user/cart_page.dart';
import 'package:morden_ecommerce_app/pages/user/Product_page/product_page.dart';
import 'package:morden_ecommerce_app/pages/user/profile_page.dart';
import 'package:morden_ecommerce_app/pages/user/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //this is to control the bottom bar
  int _selectedIndex = 0;

  //this method will update our index
  //when the user taps on the navbar
  void navigateButtomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    ProductPage(),
    //home page
    CartPage(),

    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: MyNavBar(
          onTabChange: (index) => navigateButtomBar(index),
          text: 'Shop',
          icon: Icons.shopping_bag,
          text2: "cart",
          icon2: Icons.shopping_cart_outlined,
          text3: "Profile",
          icon3: Icons.person,
        ),
      ),

      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _pages[_selectedIndex],
    );
  }
}
