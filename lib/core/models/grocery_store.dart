import '../constants.dart';

class GroceryStore {
  final String id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final String timezone;
  final StoreStatus status;
  final DateTime lastUpdated;
  final Map<String, int> currentStock; // productId -> quantity
  final String distance;
  final int productCount;
  final double averageRating;
  final String estimatedDeliveryTime;
  final String description;
  final String operatingHours;
  final String phone;
  final String email;
  
  GroceryStore({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.status,
    required this.lastUpdated,
    this.currentStock = const {},
    this.distance = '0.0 km',
    this.productCount = 0,
    this.averageRating = 0.0,
    this.estimatedDeliveryTime = '15-20 min',
    this.description = '',
    this.operatingHours = '9:00 AM - 9:00 PM',
    this.phone = '',
    this.email = '',
  });
  
  factory GroceryStore.fromJson(Map<String, dynamic> json) {
    // Support both Supabase schema and legacy format
    return GroceryStore(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['store_name'] ?? '',
      location: json['address'] ?? json['location'] ?? '',
      latitude: (json['latitude'] ?? json['lat'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? json['lon'] ?? 0.0).toDouble(),
      timezone: json['timezone'] ?? 'UTC',
      status: _parseStoreStatus(json['status'] ?? json['store_status'] ?? 'open'),
      lastUpdated: DateTime.parse(
        json['updated_at'] ?? json['last_updated'] ?? DateTime.now().toIso8601String()
      ),
      currentStock: Map<String, int>.from(json['current_stock'] ?? {}),
      distance: _parseDistance(json),
      productCount: json['product_count'] ?? 0,
      averageRating: (json['rating'] ?? json['average_rating'] ?? 0.0).toDouble(),
      estimatedDeliveryTime: json['estimated_delivery_time'] ?? '15-20 min',
      description: json['description'] ?? '',
      operatingHours: _parseOperatingHours(json),
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
  
  static StoreStatus _parseStoreStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return StoreStatus.open;
      case 'closed':
        return StoreStatus.closed;
      case 'temporarily_closed':
        return StoreStatus.temporarilyClosed;
      default:
        return StoreStatus.closed;
    }
  }
  
  static String _parseDistance(Map<String, dynamic> json) {
    if (json.containsKey('distance_km')) {
      final distKm = (json['distance_km'] as num).toDouble();
      return '${distKm.toStringAsFixed(1)} km';
    }
    return json['distance'] ?? '0.0 km';
  }
  
  static String _parseOperatingHours(Map<String, dynamic> json) {
    if (json.containsKey('opening_time') && json.containsKey('closing_time')) {
      return '${json['opening_time']} - ${json['closing_time']}';
    }
    return json['operating_hours'] ?? '9:00 AM - 9:00 PM';
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'store_name': name, // For backward compatibility
      'location': location,
      'address': location, // For backward compatibility
      'lat': latitude,
      'latitude': latitude,
      'lon': longitude,
      'longitude': longitude,
      'timezone': timezone,
      'status': status.name,
      'last_updated': lastUpdated.toIso8601String(),
      'current_stock': currentStock,
      'distance': distance,
      'product_count': productCount,
      'average_rating': averageRating,
      'estimated_delivery_time': estimatedDeliveryTime,
      'description': description,
      'operating_hours': operatingHours,
      'phone': phone,
      'email': email,
    };
  }
  
  // Helper methods
  bool get isOpen => status == StoreStatus.open;
  bool get isClosed => status == StoreStatus.closed;
  bool get isTemporarilyClosed => status == StoreStatus.temporarilyClosed;
  
  int getStockForProduct(String productId) {
    return currentStock[productId] ?? 0;
  }
  
  bool hasStock(String productId) {
    return getStockForProduct(productId) > 0;
  }
  
  double get distanceFromUser => 0.0; // Implement based on user location
  bool get hasLowStock => currentStock.values.any((quantity) => quantity < 5);
  
  // For backward compatibility
  String get storeName => name;
  String get address => location;
}