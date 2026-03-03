import 'user.dart';

/// Authentication request and response models for the grocery store app
class LoginRequest {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequest({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'remember_me': rememberMe,
    };
  }

  bool get isValid => email.isNotEmpty && password.isNotEmpty && _isValidEmail(email);

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool acceptTerms;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.acceptTerms = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'accept_terms': acceptTerms,
    };
  }

  bool get isValid {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword &&
        password.length >= 6 &&
        acceptTerms &&
        _isValidEmail(email);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? get passwordValidationError {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }
}

class AuthResponse {
  final bool success;
  final String? token;
  final String? refreshToken;
  final User? user;
  final String? message;
  final Map<String, dynamic>? errors;
  final DateTime? expiresAt;

  AuthResponse({
    required this.success,
    this.token,
    this.refreshToken,
    this.user,
    this.message,
    this.errors,
    this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      token: json['token'],
      refreshToken: json['refresh_token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message'],
      errors: json['errors'],
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
    );
  }

  factory AuthResponse.success({
    required String token,
    required User user,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthResponse(
      success: true,
      token: token,
      refreshToken: refreshToken,
      user: user,
      expiresAt: expiresAt,
    );
  }

  factory AuthResponse.error({
    required String message,
    Map<String, dynamic>? errors,
  }) {
    return AuthResponse(
      success: false,
      message: message,
      errors: errors,
    );
  }
}

class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final DateTime issuedAt;

  AuthToken({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    required this.issuedAt,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresAt: DateTime.parse(json['expires_at']),
      issuedAt: DateTime.parse(json['issued_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
      'issued_at': issuedAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isNearExpiry => DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));
}

/// Password reset request model
class PasswordResetRequest {
  final String email;

  PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }

  bool get isValid => email.isNotEmpty && _isValidEmail(email);

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

/// Change password request model
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
    };
  }

  bool get isValid {
    return currentPassword.isNotEmpty &&
        newPassword.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        newPassword == confirmPassword &&
        newPassword.length >= 6;
  }

  String? get passwordValidationError {
    if (newPassword.isEmpty) return 'New password is required';
    if (newPassword.length < 6) return 'Password must be at least 6 characters';
    if (newPassword != confirmPassword) return 'Passwords do not match';
    return null;
  }
}