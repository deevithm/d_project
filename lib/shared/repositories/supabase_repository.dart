import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/grocery_store.dart';
import '../../core/models/product.dart';
import '../../core/models/order.dart';
import '../services/supabase_service.dart';
import '../services/demo_mode_service.dart';

/// Base repository class for Supabase operations
abstract class SupabaseRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final DemoModeService _demoService = DemoModeService();

  SupabaseClient get client => _supabaseService.client;
  bool get isDemoMode => _supabaseService.isDemoMode;
}

/// Store Repository - Handles all store-related database operations
class StoreRepository extends SupabaseRepository {
  /// Get all stores
  Future<List<GroceryStore>> getAllStores() async {
    // Return mock data if in demo mode
    if (isDemoMode) {
      debugPrint('🎭 StoreRepository: Returning demo stores');
      return _demoService.getMockStores();
    }

    try {
      final response = await client
          .from('stores')
          .select()
          .order('name');

      return (response as List)
          .map((json) => GroceryStore.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch stores, falling back to demo data: $e');
      // Fallback to demo data on error
      return _demoService.getMockStores();
    }
  }

  /// Find nearby stores using the SQL function
  Future<List<GroceryStore>> findNearbyStores({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    // Return mock data if in demo mode
    if (isDemoMode) {
      return _demoService.getMockStores();
    }

    try {
      final response = await client.rpc(
        'find_nearby_stores',
        params: {
          'user_lat': latitude,
          'user_lon': longitude,
          'radius_km': radiusKm,
        },
      );

      return (response as List)
          .map((json) => GroceryStore.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Failed to find nearby stores: $e');
      return _demoService.getMockStores();
    }
  }

  /// Get store by ID
  Future<GroceryStore?> getStoreById(String id) async {
    // Return mock data if in demo mode
    if (isDemoMode) {
      return _demoService.getStoreById(id);
    }

    try {
      final response = await client
          .from('stores')
          .select()
          .eq('id', id)
          .single();

      return GroceryStore.fromJson(response);
    } catch (e) {
      debugPrint('❌ Failed to fetch store: $e');
      return _demoService.getStoreById(id);
    }
  }

  /// Update store rating
  Future<void> updateStoreRating(String storeId, double newRating, int totalRatings) async {
    try {
      await client
          .from('stores')
          .update({
            'rating': newRating,
            'total_ratings': totalRatings,
          })
          .eq('id', storeId);
    } catch (e) {
      throw Exception('Failed to update rating: $e');
    }
  }
}

/// Product Repository - Handles product and inventory operations
class ProductRepository extends SupabaseRepository {
  /// Get all products
  Future<List<Product>> getAllProducts() async {
    // Return mock data if in demo mode
    if (isDemoMode) {
      debugPrint('🎭 ProductRepository: Returning demo products');
      return _demoService.getMockProducts();
    }

    try {
      final response = await client
          .from('products')
          .select()
          .eq('is_available', true)
          .order('name');

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch products, falling back to demo data: $e');
      return _demoService.getMockProducts();
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    // Return mock data if in demo mode
    if (isDemoMode) {
      return _demoService.getMockProducts().where((p) => 
        p.category.name.toLowerCase() == category.toLowerCase()
      ).toList();
    }

    try {
      final response = await client
          .from('products')
          .select()
          .eq('category', category)
          .eq('is_available', true)
          .order('name');

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch products by category: $e');
      return _demoService.getMockProducts().where((p) => 
        p.category.name.toLowerCase() == category.toLowerCase()
      ).toList();
    }
  }

  /// Get store inventory (products available at a specific store)
  Future<List<Product>> getStoreInventory(String storeId) async {
    // Return mock data if in demo mode
    if (isDemoMode) {
      debugPrint('🎭 ProductRepository: Returning demo inventory for store $storeId');
      return _demoService.getMockProducts();
    }

    try {
      final response = await client
          .from('store_products')
          .select('''
            current_price,
            discount,
            stock,
            product:products(*)
          ''')
          .eq('store_id', storeId)
          .eq('is_available', true)
          .gt('stock', 0);

      return (response as List).map((json) {
        final productData = json['product'] as Map<String, dynamic>;
        // Create product with store-specific pricing
        return Product.fromJson({
          ...productData,
          'current_price': json['current_price'],
          'discount': json['discount'],
        });
      }).toList();
    } catch (e) {
      debugPrint('❌ Failed to fetch store inventory, falling back to demo data: $e');
      return _demoService.getMockProducts();
    }
  }

  /// Search products by name
  Future<List<Product>> searchProducts(String query) async {
    // Return mock data if in demo mode
    if (isDemoMode) {
      return _demoService.searchProducts(query);
    }

    try {
      final response = await client
          .from('products')
          .select()
          .textSearch('name', query, config: 'english')
          .eq('is_available', true);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Failed to search products: $e');
      return _demoService.searchProducts(query);
    }
  }

  /// Get product by barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    if (isDemoMode) {
      return null; // No barcode support in demo mode
    }

    try {
      final response = await client
          .from('products')
          .select()
          .eq('barcode', barcode)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get product by ID
  Future<Product?> getProductById(String id) async {
    if (isDemoMode) {
      return _demoService.getProductById(id);
    }

    try {
      final response = await client
          .from('products')
          .select()
          .eq('id', id)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}

/// Order Repository - Handles order operations
class OrderRepository extends SupabaseRepository {
  /// Create new order
  Future<Order> createOrder(Order order, String userId) async {
    try {
      // Generate order number
      final orderNumber = await client.rpc('generate_order_number');

      // Insert order
      final orderResponse = await client
          .from('orders')
          .insert({
            'user_id': userId,
            'store_id': order.storeId,
            'order_number': orderNumber,
            'total_amount': order.totalAmount,
            'tax_amount': order.taxAmount ?? 0,
            'discount_amount': order.discountAmount ?? 0,
            'payment_method': order.paymentMethod.name,
            'payment_id': order.paymentId,
            'payment_status': order.paymentStatus ?? 'pending',
            'status': order.status.name,
            'delivery_address': order.deliveryAddress,
            'notes': order.notes,
          })
          .select()
          .single();

      final orderId = orderResponse['id'];

      // Insert order items
      final items = order.items.map((item) => {
        'order_id': orderId,
        'product_id': item.product.id,
        'product_name': item.product.name,
        'quantity': item.quantity,
        'unit_price': item.currentPrice,
        'total_price': item.totalPrice,
        'discount': item.discountApplied ?? 0,
      }).toList();

      await client.from('order_items').insert(items);

      // Fetch and return complete order
      final completeOrder = await getOrderById(orderId);
      if (completeOrder == null) {
        throw Exception('Failed to fetch created order');
      }
      return completeOrder;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get user orders
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final response = await client
          .from('orders')
          .select('''
            *,
            items:order_items(*),
            store:stores(name, address)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await client
          .from('orders')
          .select('''
            *,
            items:order_items(*),
            store:stores(*)
          ''')
          .eq('id', orderId)
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await client
          .from('orders')
          .update({
            'status': status,
            if (status == 'dispensed') 'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Subscribe to order updates (realtime)
  Stream<Order> subscribeToOrder(String orderId) {
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((data) => Order.fromJson(data.first));
  }

  /// Get all orders for admin
  Future<List<Order>> getAllOrders({String? storeId}) async {
    try {
      final baseQuery = client
          .from('orders')
          .select('''
            *,
            items:order_items(*),
            store:stores(name, address)
          ''');

      final query = storeId != null 
        ? baseQuery.eq('store_id', storeId)
        : baseQuery;

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }
}

/// Favorites Repository
class FavoritesRepository extends SupabaseRepository {
  /// Get user favorites
  Future<List<Product>> getUserFavorites(String userId) async {
    try {
      final response = await client
          .from('favorites')
          .select('product:products(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Product.fromJson(json['product']))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorites: $e');
    }
  }

  /// Add to favorites
  Future<void> addFavorite(String userId, String productId) async {
    try {
      await client.from('favorites').insert({
        'user_id': userId,
        'product_id': productId,
      });
    } catch (e) {
      throw Exception('Failed to add favorite: $e');
    }
  }

  /// Remove from favorites
  Future<void> removeFavorite(String userId, String productId) async {
    try {
      await client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }

  /// Check if product is favorited
  Future<bool> isFavorite(String userId, String productId) async {
    try {
      final response = await client
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('product_id', productId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}

/// Cart Repository
class CartRepository extends SupabaseRepository {
  /// Get user cart
  Future<List<Map<String, dynamic>>> getUserCart(String userId) async {
    try {
      final response = await client
          .from('cart_items')
          .select('''
            *,
            product:products(*),
            store:stores(name)
          ''')
          .eq('user_id', userId);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  /// Add to cart
  Future<void> addToCart({
    required String userId,
    required String storeId,
    required String productId,
    required int quantity,
  }) async {
    try {
      await client.from('cart_items').upsert({
        'user_id': userId,
        'store_id': storeId,
        'product_id': productId,
        'quantity': quantity,
      });
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  /// Update cart item quantity
  Future<void> updateCartItemQuantity({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(userId, productId);
      } else {
        await client
            .from('cart_items')
            .update({'quantity': quantity})
            .eq('user_id', userId)
            .eq('product_id', productId);
      }
    } catch (e) {
      throw Exception('Failed to update cart: $e');
    }
  }

  /// Remove from cart
  Future<void> removeFromCart(String userId, String productId) async {
    try {
      await client
          .from('cart_items')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  /// Clear cart
  Future<void> clearCart(String userId) async {
    try {
      await client
          .from('cart_items')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}

/// Notifications Repository
class NotificationsRepository extends SupabaseRepository {
  /// Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final response = await client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  /// Subscribe to notifications (realtime)
  Stream<List<Map<String, dynamic>>> subscribeToNotifications(String userId) {
    return client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  /// Create notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'info',
    String? actionUrl,
  }) async {
    try {
      await client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'action_url': actionUrl,
      });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }
}
