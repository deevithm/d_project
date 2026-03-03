import '../constants.dart';
import 'product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final double currentPrice;
  final double? discountApplied;
  final String? discountReason;
  
  CartItem({
    required this.product,
    required this.quantity,
    required this.currentPrice,
    this.discountApplied,
    this.discountReason,
  });
  
  double get totalPrice => currentPrice * quantity;
  double get totalSavings => discountApplied != null ? 
    (product.basePrice - currentPrice) * quantity : 0.0;
  
  CartItem copyWith({
    Product? product,
    int? quantity,
    double? currentPrice,
    double? discountApplied,
    String? discountReason,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      currentPrice: currentPrice ?? this.currentPrice,
      discountApplied: discountApplied ?? this.discountApplied,
      discountReason: discountReason ?? this.discountReason,
    );
  }
}

class Order {
  final String id;
  final String storeId;
  final String? userId;
  final List<CartItem> items;
  final double totalAmount;
  final double totalSavings;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? qrCode;
  final String? otp;
  final String? failureReason;
  final String? paymentId; // Razorpay payment ID
  final double? taxAmount;  // Supabase field
  final double? discountAmount;  // Supabase field
  final String? paymentStatus;  // Supabase field
  final String? deliveryAddress;  // Supabase field
  final String? notes;  // Supabase field
  
  Order({
    required this.id,
    required this.storeId,
    this.userId,
    required this.items,
    required this.totalAmount,
    this.totalSavings = 0.0,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.qrCode,
    this.otp,
    this.failureReason,
    this.paymentId,
    this.taxAmount,
    this.discountAmount,
    this.paymentStatus,
    this.deliveryAddress,
    this.notes,
  });
  
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      storeId: json['store_id'] ?? json['machine_id'] ?? '', // Support both new and old format
      userId: json['user_id'],
      items: [], // Would need to populate from separate endpoint
      totalAmount: (json['total_amount'] ?? 0.0).toDouble(),
      totalSavings: (json['discount_amount'] ?? json['total_savings'] ?? 0.0).toDouble(), // Support both schemas
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['payment_method'],
        orElse: () => PaymentMethod.upi,
      ),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null 
        ? DateTime.parse(json['completed_at']) 
        : null,
      qrCode: json['qr_code'],
      otp: json['otp'],
      failureReason: json['failure_reason'],
      paymentId: json['payment_id'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'machine_id': storeId, // For backward compatibility
      'user_id': userId,
      'total_amount': totalAmount,
      'total_savings': totalSavings,
      'payment_method': paymentMethod.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'qr_code': qrCode,
      'otp': otp,
      'failure_reason': failureReason,
      'payment_id': paymentId,
    };
  }
  
  Order copyWith({
    String? id,
    String? storeId,
    String? userId,
    List<CartItem>? items,
    double? totalAmount,
    double? totalSavings,
    PaymentMethod? paymentMethod,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? qrCode,
    String? otp,
    String? failureReason,
    String? paymentId,
  }) {
    return Order(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      totalSavings: totalSavings ?? this.totalSavings,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      qrCode: qrCode ?? this.qrCode,
      otp: otp ?? this.otp,
      failureReason: failureReason ?? this.failureReason,
      paymentId: paymentId ?? this.paymentId,
    );
  }
  
  bool get isCompleted => status == OrderStatus.dispensed;
  bool get isFailed => status == OrderStatus.failed || status == OrderStatus.cancelled;
  bool get isPending => status == OrderStatus.pending || status == OrderStatus.confirmed;
  
  // For backward compatibility
  String get machineId => storeId;
}