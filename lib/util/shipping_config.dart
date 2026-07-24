import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ShippingConfig {
  static Future<Map<String, double>> fetchRates() async {
    final doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('shipping_rates')
        .get();
    return {
      'basefee': (doc['basefee'] ?? 500).toDouble(),
      'ratePerKm': (doc['ratePerKm'] ?? 150).toDouble(),
      'expressMultiplier': (doc['expressMultiplier'] ?? 1.5).toDouble(),
    };
  }
}
