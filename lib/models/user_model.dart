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
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      password: json['password'] as String,
      rememberToken: json['remember_token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.admin,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
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
