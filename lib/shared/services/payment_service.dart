import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/models/order.dart';

/// Mock Payment Service for Academic Project
/// Simulates payment processing without actual gateway integration
class PaymentService with ChangeNotifier {
  bool _isInitialized = false;

  PaymentService() {
    // Mock initialization for development/academic project
    _isInitialized = true;
  }

  /// Process payment for grocery store order
  /// Mock implementation for development/academic project
  Future<void> processGroceryStorePayment({
    required Order order,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) async {
    // Mock payment processing - simulate success after delay
    await Future.delayed(const Duration(seconds: 2));
    
    final mockResponse = PaymentSuccessResponse(
      paymentId: 'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    onSuccess(mockResponse);
  }

  /// Process general payment
  /// Mock implementation for development/academic project
  Future<void> processPayment({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required Function(String) onSuccess,
    required Function(String) onError,
    Function(String)? onExternalWallet,
  }) async {
    // Mock payment processing - simulate success after delay
    await Future.delayed(const Duration(seconds: 2));
    onSuccess('pay_mock_${DateTime.now().millisecondsSinceEpoch}');
  }

  /// Process UPI payment
  /// Mock implementation for development/academic project
  Future<void> processUPIPayment({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    // Mock UPI payment processing - simulate success after delay
    await Future.delayed(const Duration(seconds: 1));
    onSuccess('upi_mock_${DateTime.now().millisecondsSinceEpoch}');
  }

  /// Process wallet payment
  /// Mock implementation for development/academic project
  Future<void> processWalletPayment({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    // Mock wallet payment processing - simulate success after delay
    await Future.delayed(const Duration(seconds: 1));
    onSuccess('wallet_mock_${DateTime.now().millisecondsSinceEpoch}');
  }

  /// Create order ID for payment
  /// Mock implementation for development/academic project
  Future<String> createOrderId(double amount) async {
    // Mock order creation - simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    return 'order_mock_${DateTime.now().millisecondsSinceEpoch}';
  }

  bool get isInitialized => _isInitialized;

  @override
  void dispose() {
    // Mock cleanup for development/academic project
    _isInitialized = false;
    super.dispose();
  }
}

/// Payment success response
/// Mock response class for development/academic project
class PaymentSuccessResponse {
  final String paymentId;
  
  PaymentSuccessResponse({required this.paymentId});
}

/// Payment failure response
/// Mock response class for development/academic project
class PaymentFailureResponse {
  final String message;
  
  PaymentFailureResponse({required this.message});
}

/// External wallet response
/// Mock response class for development/academic project
class ExternalWalletResponse {
  final String walletName;
  
  ExternalWalletResponse({required this.walletName});
}