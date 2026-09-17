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
import 'package:shared_preferences/shared_preferences.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  static const _minDisplayDuration = Duration(milliseconds: 1800);
  static const _sessionExpiry = Duration(days: 60);
  static const _lastActiveKey = 'last_active_epoch';

  late final Future<void> _bootstrap = _runBootstrap();

  String? _cachedRole;
  String? _roleUid;

  Future<void> _runBootstrap() async {
    final minDelay = Future.delayed(_minDisplayDuration);
    await _checkSessionExpiry();
    await minDelay;
  }

  Future<void> _checkSessionExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getInt(_lastActiveKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastActive != null &&
        now - lastActive > _sessionExpiry.inMilliseconds) {
      await FirebaseAuth.instance.signOut();
    }

    await prefs.setInt(_lastActiveKey, now);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().listenToProducts();
      SeedService().seedProductsIfEmpty();
    });
  }

  Future<void> _fetchRole(String uid) async {
    final role = await AuthService().getUserRole(uid);
    if (mounted) {
      setState(() {
        _cachedRole = role;
        _roleUid = uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _bootstrap,
      builder: (context, bootstrapSnapshot) {
        if (bootstrapSnapshot.connectionState != ConnectionState.done) {
          return const _AppLoader(key: ValueKey('loader'));
        }

        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            Widget content;

            if (snapshot.connectionState == ConnectionState.waiting) {
              content = const _AppLoader(key: ValueKey('loader'));
            } else if (snapshot.hasData) {
              final user = snapshot.data!;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<CartProvider>().listenToCart(user.uid);
              });

              if (_roleUid == user.uid && _cachedRole != null) {
                content = _cachedRole == 'admin'
                    ? const AdminPage(key: ValueKey('admin'))
                    : const HomePage(key: ValueKey('home'));
              } else {
                if (_roleUid != user.uid) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _fetchRole(user.uid);
                  });
                }
                content = const _AppLoader(key: ValueKey('loader'));
              }
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<CartProvider>().reset();
              });
              content = const LoginOrRegister(key: ValueKey('login'));
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: content,
            );
          },
        );
      },
    );
  }
}

class _AppLoader extends StatefulWidget {
  const _AppLoader({super.key});

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.shopping_bag_rounded,
                  size: 56,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'QuickBuy NG',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Shop smarter, right here in Abuja',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary.withOpacity(0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
