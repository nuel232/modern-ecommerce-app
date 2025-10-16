import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/component/my_nav_bar.dart';
import 'package:morden_ecommerce_app/pages/admin/admin_product_page.dart';
import 'package:morden_ecommerce_app/pages/admin/dashboard_page.dart';
import 'package:morden_ecommerce_app/pages/admin/order_page.dart';

class AdminPage extends StatefulWidget {
  AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  //this is to control the bottom bar
  int _selectedIndex = 0;

  //this method will update our index
  void navigateButtomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    DashboardPage(),
    AdminProductPage(),
    OrderPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyNavBar(
        onTabChange: (index) => navigateButtomBar(index),
        text: 'Dashboard',
        icon: Icons.dashboard,

        text2: "product",
        icon2: Icons.production_quantity_limits,
        text3: "orders",
        icon3: Icons.shopping_bag,
      ),

      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _pages[_selectedIndex],
    );
  }
}
