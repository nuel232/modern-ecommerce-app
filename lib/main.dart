import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/firebase_options.dart';
import 'package:morden_ecommerce_app/models/shop.dart';
import 'package:morden_ecommerce_app/providers/cart_provider.dart';
import 'package:morden_ecommerce_app/providers/product_provider.dart';
import 'package:morden_ecommerce_app/services/auth/auth_gate.dart';
import 'package:morden_ecommerce_app/services/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with the generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => Shop()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
