import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/pages/admin/admin_page.dart';
import 'package:morden_ecommerce_app/pages/user/home_page.dart';
import 'package:morden_ecommerce_app/services/auth/auth_service.dart';
import 'package:morden_ecommerce_app/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //get the current user
            User? user = snapshot.data;

            //FutureBuilder to get the user's role
            return FutureBuilder<String?>(
              future: AuthService().getUserRole(user!.uid),
              builder: (context, roleSnapshot) {
                //while loading the role
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                }

                //if we have the role data
                if (roleSnapshot.hasData) {
                  String? role = roleSnapshot.data;

                  if (role == 'admin') {
                    return AdminPage();
                  } else {
                    return HomePage();
                  }
                }
                return HomePage();
              },
            );
          } else {
            return LoginOrRegister();
          }
        },
      ),
    );
  }
}
