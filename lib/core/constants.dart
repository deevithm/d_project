import 'package:flutter/material.dart';

// Core constants for the grocery store app
class AppConstants {
  // API Endpoints
  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const String storesEndpoint = '/stores';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  static const String mlPredictionsEndpoint = '/ml/predictions';
  static const String authEndpoint = '/auth';
  
  // Payment - Razorpay Configuration
  static const String razorpayKeyId = 'rzp_test_AvJHGftolKjdYJ'; // Your actual test key
  static const String razorpayKeySecret = 'YOUR_RAZORPAY_KEY_SECRET'; // Keep secret secure
  
  // Payment options
  static const String companyName = 'Snackly';
  static const String companyLogo = 'assets/images/snackly_logo.png';
  static const String currency = 'INR';
  
  // App Settings
  static const int cacheExpiryDurationInHours = 6;
  static const double defaultDiscountThreshold = 0.2;
  static const int maxCartItems = 10;
  
  // ML Model Settings
  static const double stockoutProbabilityThreshold = 0.8;
  static const int forecastDaysAhead = 7;
  
  // UI Constants
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
}

// App color scheme
class AppColors {
  // Primary colors from Figma design
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  
  // Background colors
  static const Color background = Color(0xFFF8FAFC); // Light gray
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1E293B); // Dark slate
  static const Color textSecondary = Color(0xFF64748B); // Gray
  static const Color textTertiary = Color(0xFF94A3B8);
  
  // Accent colors
  static const Color accent = Color(0xFF10B981); // Emerald green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color success = Color(0xFF10B981); // Green
  
  // UI colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color shadow = Color(0x0A000000);
  
  // Status colors
  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFF64748B);
  static const Color maintenance = Color(0xFFF59E0B);
  static const Color lowStock = Color(0xFFEF4444);
}

// User roles
enum UserRole {
  buyer,
  operator,
  admin,
  restocker,
  analyst
}

// Order status
enum OrderStatus {
  pending,
  confirmed,
  dispensed,
  failed,
  cancelled
}

// Payment methods
enum PaymentMethod {
  upi,
  card,
  wallet,
  qr
}

// Store status for grocery stores  
enum MachineStatus {
  online,
  offline,
  maintenance,
  lowStock
}

// Store status for grocery stores
enum StoreStatus {
  open,
  closed,
  temporarilyClosed
}

// Product categories
enum ProductCategory {
  beverages,
  snacks,
  food,
  healthyOptions,
  dairy,
  bakery,
  fruits,
  babycare,
  household,
  personalcare,
  health,
  frozen,
  pantry,
  other
}

// Route constants
class AppRoutes {
  static const String root = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String stores = '/stores';
  static const String orders = '/orders';
  static const String favorites = '/favorites';
  static const String products = '/products';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
}