import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/models/order.dart';
import '../../core/constants.dart';
import '../services/supabase_service.dart';

/// Repository for managing orders with real-time Supabase integration
class OrderRepository extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  
  List<Order> _orders = [];
  List<Order> get orders => _orders;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;
  
  StreamSubscription? _ordersSubscription;
  bool _disposed = false;
  
  /// Initialize real-time order subscription
  Future<void> initialize() async {
    await fetchOrders();
    _setupRealtimeSubscription();
  }
  
  /// Fetch all orders from Supabase
  Future<void> fetchOrders() async {
    if (_disposed) return; // Skip if already disposed
    
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();
    
    try {
      // Try simple query first without complex joins
      final response = await _supabase.client
          .from('orders')
          .select('*')
          .order('created_at', ascending: false);
      
      if (_disposed) return; // Check again after async call
      
      _orders = (response as List)
          .map((json) => Order.fromJson(json))
          .toList();
      
      debugPrint('✅ Fetched ${_orders.length} orders from Supabase');
    } catch (e) {
      if (_disposed) return; // Check again after async call
      
      debugPrint('❌ Error fetching orders: $e');
      // Return empty list if Supabase fails - demo mode
      _orders = [];
      debugPrint('📦 Using empty orders list (demo mode)');
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }
  
  /// Safely notify listeners only if not disposed
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }
  
  /// Set up real-time subscription for order updates
  void _setupRealtimeSubscription() {
    debugPrint('📡 Setting up real-time order subscription...');
    
    _ordersSubscription = _supabase.client
        .from('orders')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          if (_disposed) return; // Skip if already disposed
          
          debugPrint('🔔 Real-time order update received: ${data.length} orders');
          
          _orders = data
              .map((json) => Order.fromJson(json))
              .toList();
          
          // Sort by created_at descending
          _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          _safeNotifyListeners();
        }, onError: (error) {
          if (_disposed) return; // Skip if already disposed
          
          debugPrint('❌ Real-time subscription error: $error');
          _error = 'Real-time sync error: $error';
          _safeNotifyListeners();
        });
  }
  
  /// Create a new order
  Future<Order?> createOrder({
    required String storeId,
    required String userId,
    required List<CartItem> items,
    required double totalAmount,
    required String paymentMethod,
    String? paymentId,
  }) async {
    try {
      debugPrint('📝 Creating new order for user: $userId');
      
      // Calculate totals
      double totalSavings = items.fold(0.0, (sum, item) => sum + item.totalSavings);
      
      // Generate unique order number
      final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      
      // Check if storeId is a valid UUID (Supabase expects UUID for store_id)
      // If not a valid UUID, set to null to avoid foreign key constraint error
      String? validStoreId;
      final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
      if (uuidRegex.hasMatch(storeId)) {
        validStoreId = storeId;
      } else {
        debugPrint('⚠️ Store ID "$storeId" is not a valid UUID, setting to null');
        validStoreId = null;
      }
      
      // Insert order - matching Supabase schema columns
      final orderData = {
        'store_id': validStoreId,
        'user_id': userId,
        'order_number': orderNumber,
        'total_amount': totalAmount,
        'discount_amount': totalSavings, // Map savings to discount_amount
        'tax_amount': 0.0,
        'payment_method': paymentMethod.toLowerCase(),
        'payment_id': paymentId,
        'payment_status': 'completed',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final orderResponse = await _supabase.client
          .from('orders')
          .insert(orderData)
          .select()
          .single();
      
      final orderId = orderResponse['id'];
      debugPrint('✅ Order created with ID: $orderId');
      
      // Insert order items - matching Supabase schema columns
      // Note: product_id is set to null because the app uses custom product IDs (like 'fresh_bev_001')
      // instead of UUIDs. We store the product name for reference.
      final orderItems = items.map((item) => {
        'order_id': orderId,
        'product_id': null, // App uses custom IDs, not UUID - store product name instead
        'product_name': item.product.name,
        'quantity': item.quantity,
        'unit_price': item.currentPrice,
        'total_price': item.totalPrice,
        'discount': item.totalSavings,
        'created_at': DateTime.now().toIso8601String(),
      }).toList();
      
      await _supabase.client
          .from('order_items')
          .insert(orderItems);
      
      debugPrint('✅ Order items inserted');
      
      // Create Order object
      final order = Order(
        id: orderId,
        storeId: storeId,
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        totalSavings: totalSavings,
        paymentMethod: _parsePaymentMethod(paymentMethod),
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        paymentId: paymentId,
      );
      
      return order;
    } catch (e) {
      debugPrint('❌ Error creating order: $e');
      _error = 'Failed to create order: $e';
      _safeNotifyListeners();
      return null;
    }
  }
  
  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      debugPrint('🔄 Updating order $orderId status to: $status');
      
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Add completed_at if status is dispensed
      if (status == 'dispensed') {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }
      
      await _supabase.client
          .from('orders')
          .update(updateData)
          .eq('id', orderId);
      
      debugPrint('✅ Order status updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating order status: $e');
      _error = 'Failed to update order: $e';
      _safeNotifyListeners();
      return false;
    }
  }
  
  /// Get orders by user ID
  List<Order> getOrdersByUser(String userId) {
    return _orders.where((order) => order.userId == userId).toList();
  }
  
  /// Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }
  
  /// Get pending orders count
  int get pendingOrdersCount {
    return _orders.where((order) => order.status == OrderStatus.pending).length;
  }
  
  /// Dispose and clean up subscriptions
  @override
  void dispose() {
    _disposed = true;
    _ordersSubscription?.cancel();
    super.dispose();
  }
}

/// Extension to convert string to PaymentMethod
PaymentMethod _parsePaymentMethod(String method) {
  switch (method.toLowerCase()) {
    case 'upi':
      return PaymentMethod.upi;
    case 'card':
      return PaymentMethod.card;
    case 'wallet':
      return PaymentMethod.wallet;
    case 'qr':
      return PaymentMethod.qr;
    default:
      return PaymentMethod.upi;
  }
}
