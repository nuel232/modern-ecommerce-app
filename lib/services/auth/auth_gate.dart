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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().listenToProducts();
      SeedService().seedProductsIfEmpty();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<CartProvider>().listenToCart(user.uid);
        _fetchRole(user.uid);
      }
    });
  }

  Future<void> _fetchRole(String uid) async {
    final role = await AuthService().getUserRole(uid);
    if (mounted) setState(() => _cachedRole = role);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data!;

          // Schedule cart start after build — never call notifyListeners during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<CartProvider>().listenToCart(user.uid);
          });

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
              _cachedRole = roleSnapshot.data;
              return _cachedRole == 'admin'
                  ? const AdminPage()
                  : const HomePage();
            },
          );
        }

        // Logged out — schedule reset after build to avoid setState-during-build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<CartProvider>().reset();
        });
        return const LoginOrRegister();
      },
    );
  }
}
