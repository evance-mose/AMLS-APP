import 'package:flutter/foundation.dart';

enum UserRole { admin, technician, custodian }
enum UserStatus { active, inactive }

class User {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final String password;
  final String? rememberToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserRole role;
  final UserStatus status;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.password,
    this.rememberToken,
    required this.createdAt,
    required this.updatedAt,
    this.role = UserRole.admin,
    this.status = UserStatus.active,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      password: json['password'] as String? ?? '',
      rememberToken: json['remember_token'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == (json['role'] as String? ?? 'admin'),
        orElse: () => UserRole.admin,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] as String? ?? 'active'),
        orElse: () => UserStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'password': password,
      'remember_token': rememberToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, status: $status)';
  }
}
