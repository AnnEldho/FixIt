import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.role = UserRole.user,
    this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  String get initial => name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      uid: doc.id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      role: data['role']?.toString() ?? UserRole.user,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Map used when creating a new user document.
  ///
  /// [asAdmin] is only used for the built-in admin account; the Firestore rules
  /// reject `role: admin` for any other email.
  Map<String, dynamic> toCreateMap({bool asAdmin = false}) => {
        'name': name,
        'email': email,
        'phone': phone,
        'role': asAdmin ? UserRole.admin : UserRole.user,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
