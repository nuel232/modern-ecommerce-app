import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/component/my_button.dart';
import 'package:morden_ecommerce_app/services/auth/auth_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  //logout
  void logout() async {
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: MyButton(text: 'logout', onTap: logout),
          ),
        ],
      ),
    );
  }
}
