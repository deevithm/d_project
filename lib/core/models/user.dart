import '../constants.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final List<String> paymentMethods;
  final int loyaltyPoints;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.paymentMethods = const [],
    this.loyaltyPoints = 0,
    this.preferences = const {},
    required this.createdAt,
    required this.lastActiveAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.buyer,
      ),
      paymentMethods: List<String>.from(json['payment_methods'] ?? []),
      loyaltyPoints: json['loyalty_points'] ?? 0,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      lastActiveAt: DateTime.parse(json['last_active_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'payment_methods': paymentMethods,
      'loyalty_points': loyaltyPoints,
      'preferences': preferences,
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt.toIso8601String(),
    };
  }
  
  bool get isAdmin => role == UserRole.admin;
  bool get isOperator => role == UserRole.operator || role == UserRole.admin;
  bool get isBuyer => role == UserRole.buyer;
  bool get isRestocker => role == UserRole.restocker;
  bool get isAnalyst => role == UserRole.analyst;
}