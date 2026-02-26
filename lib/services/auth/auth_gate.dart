import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/pages/admin/admin_page.dart';
import 'package:morden_ecommerce_app/pages/user/home_page.dart';
import 'package:morden_ecommerce_app/providers/cart_provider.dart';
import 'package:morden_ecommerce_app/providers/product_provider.dart';
import 'package:morden_ecommerce_app/services/auth/auth_service.dart';
import 'package:morden_ecommerce_app/services/auth/login_or_register.dart';
import 'package:morden_ecommerce_app/services/shop/seed_service.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _cachedRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialRole();
    SeedService().seedProductsIfEmpty();
  }

  Future<void> _loadInitialRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _cachedRole = await AuthService().getUserRole(user.uid);
      _startProviders(user.uid);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _startProviders(String uid) {
    context.read<ProductProvider>().listenToProducts();
    context.read<CartProvider>().listenToCart(uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!;

          if (_cachedRole != null) {
            return _cachedRole == 'admin'
                ? const AdminPage()
                : const HomePage();
          }

          return FutureBuilder<String?>(
            future: AuthService().getUserRole(user.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }

              if (roleSnapshot.hasData) {
                _cachedRole = roleSnapshot.data;
                _startProviders(user.uid);
                return _cachedRole == 'admin'
                    ? const AdminPage()
                    : const HomePage();
              }

              return const HomePage();
            },
          );
        }

        return const LoginOrRegister();
      },
    );
  }
}
