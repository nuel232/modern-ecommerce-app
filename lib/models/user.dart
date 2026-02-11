// Create this file at: lib/models/user_model.dart

import 'package:morden_ecommerce_app/models/address_model.dart';
import 'package:morden_ecommerce_app/models/cart_item.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'user' or 'admin'
  final List<AddressModel> addresses;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    required this.addresses,
  });

  // Convert UserModel to a Map (for storing in Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'addresses': addresses.map((addr) => addr.toMap()).toList(),
    };
  }

  // Create UserModel from a Map (when reading from Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user', // Default to 'user' if no role
      addresses:
          (map['addresses'] as List<dynamic>?)
              ?.map(
                (item) => AddressModel.fromMap(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
