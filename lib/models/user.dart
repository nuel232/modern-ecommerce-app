// Create this file at: lib/models/user_model.dart

class UserModel {
  final String uid;
  final String email;
  final String role; // 'user' or 'admin'

  UserModel({required this.uid, required this.email, required this.role});

  // Convert UserModel to a Map (for storing in Firestore)
  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email, 'role': role};
  }

  // Create UserModel from a Map (when reading from Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user', // Default to 'user' if no role
    );
  }
}
