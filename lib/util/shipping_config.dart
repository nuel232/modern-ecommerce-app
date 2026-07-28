import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ShopConfig {
  static const String originAddress = '9.001478419374612, 7.466733395897482';
}

class ShippingConfig {
  static Future<Map<String, double>> fetchRates() async {
    final doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('shipping_rates')
        .get();
    return {
      'baseFee': (doc['baseFee'] ?? 500).toDouble(),
      'ratePerKm': (doc['ratePerKm'] ?? 150).toDouble(),
      'expressMultiplier': (doc['expressMultiplier'] ?? 1.5).toDouble(),
    };
  }
}
