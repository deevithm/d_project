import 'package:flutter/foundation.dart';
import '../../core/models/grocery_store.dart';
import '../../core/models/product.dart';
import '../../core/constants.dart';

/// Demo Mode Service - Provides mock data when backend is unavailable
/// This allows the app to function in offline/demo mode for testing
class DemoModeService {
  static final DemoModeService _instance = DemoModeService._internal();
  factory DemoModeService() => _instance;
  DemoModeService._internal();

  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  /// Enable demo mode
  void enable() {
    _isEnabled = true;
    debugPrint('🎭 Demo mode enabled - using mock data');
  }

  /// Disable demo mode
  void disable() {
    _isEnabled = false;
    debugPrint('🌐 Demo mode disabled - using live data');
  }

  /// Get mock stores for demo mode
  List<GroceryStore> getMockStores() {
    return [
      GroceryStore(
        id: 'demo-store-1',
        name: 'Snackly Express - Downtown',
        location: '123 Main Street, Downtown',
        latitude: 12.9716,
        longitude: 77.5946,
        timezone: 'Asia/Kolkata',
        status: StoreStatus.open,
        lastUpdated: DateTime.now(),
        distance: '0.5 km',
        productCount: 150,
        averageRating: 4.5,
        operatingHours: '8:00 AM - 10:00 PM',
        description: 'Your neighborhood grocery store with fresh produce',
      ),
      GroceryStore(
        id: 'demo-store-2',
        name: 'Snackly Mart - City Center',
        location: '456 MG Road, City Center',
        latitude: 12.9756,
        longitude: 77.6010,
        timezone: 'Asia/Kolkata',
        status: StoreStatus.open,
        lastUpdated: DateTime.now(),
        distance: '1.2 km',
        productCount: 200,
        averageRating: 4.3,
        operatingHours: '9:00 AM - 9:00 PM',
        description: 'Wide variety of products at great prices',
      ),
      GroceryStore(
        id: 'demo-store-3',
        name: 'Snackly Fresh - Tech Park',
        location: '789 Outer Ring Road, Tech Park',
        latitude: 12.9350,
        longitude: 77.6240,
        timezone: 'Asia/Kolkata',
        status: StoreStatus.open,
        lastUpdated: DateTime.now(),
        distance: '2.5 km',
        productCount: 300,
        averageRating: 4.7,
        operatingHours: '7:00 AM - 11:00 PM',
        description: 'Premium quality groceries and fresh bakery',
      ),
    ];
  }

  /// Get mock products for demo mode
  List<Product> getMockProducts() {
    return [
      // Fruits
      Product(
        id: 'demo-prod-1',
        name: 'Fresh Bananas',
        category: ProductCategory.fruits,
        imageUrl: 'assets/images/products/banana.jpg',
        basePrice: 45.0,
        cost: 35.0,
        description: 'Ripe and sweet bananas, perfect for smoothies or snacking',
        nutritionTags: const ['Fresh', 'Organic', 'Popular'],
        isPerishable: true,
        expiryDays: 5,
        price: 40.0,
        discount: 11,
      ),
      Product(
        id: 'demo-prod-2',
        name: 'Red Apples',
        category: ProductCategory.fruits,
        imageUrl: 'assets/images/products/apple.jpg',
        basePrice: 180.0,
        cost: 140.0,
        description: 'Crispy red apples, rich in antioxidants',
        nutritionTags: const ['Fresh', 'Imported', 'Healthy'],
        isPerishable: true,
        expiryDays: 14,
        price: 150.0,
        discount: 17,
      ),

      // Dairy Products
      Product(
        id: 'demo-prod-3',
        name: 'Amul Milk (1L)',
        category: ProductCategory.dairy,
        imageUrl: 'assets/images/products/milk.jpg',
        basePrice: 60.0,
        cost: 50.0,
        description: 'Fresh toned milk, rich in calcium',
        nutritionTags: const ['Fresh', 'Daily Essential'],
        isPerishable: true,
        expiryDays: 3,
        price: 58.0,
        discount: 3,
      ),
      Product(
        id: 'demo-prod-4',
        name: 'Greek Yogurt',
        category: ProductCategory.dairy,
        imageUrl: 'assets/images/products/yogurt.jpg',
        basePrice: 120.0,
        cost: 90.0,
        description: 'Creamy Greek yogurt, high in protein',
        nutritionTags: const ['Protein Rich', 'Healthy', 'Probiotic'],
        isPerishable: true,
        expiryDays: 7,
        price: 99.0,
        discount: 18,
      ),

      // Snacks
      Product(
        id: 'demo-prod-5',
        name: 'Lays Classic Chips',
        category: ProductCategory.snacks,
        imageUrl: 'assets/images/products/chips.jpg',
        basePrice: 20.0,
        cost: 15.0,
        description: 'Crispy potato chips with classic salted flavor',
        nutritionTags: const ['Snack', 'Party', 'Popular'],
        isPerishable: false,
        expiryDays: 90,
        price: 20.0,
        discount: 0,
      ),
      Product(
        id: 'demo-prod-6',
        name: 'Dark Chocolate Bar',
        category: ProductCategory.snacks,
        imageUrl: 'assets/images/products/chocolate.jpg',
        basePrice: 150.0,
        cost: 110.0,
        description: '70% dark chocolate, rich in antioxidants',
        nutritionTags: const ['Premium', 'Gift', 'Healthy'],
        isPerishable: false,
        expiryDays: 180,
        price: 135.0,
        discount: 10,
      ),

      // Beverages
      Product(
        id: 'demo-prod-7',
        name: 'Coca Cola (2L)',
        category: ProductCategory.beverages,
        imageUrl: 'assets/images/products/cola.jpg',
        basePrice: 95.0,
        cost: 75.0,
        description: 'Refreshing cola drink for the whole family',
        nutritionTags: const ['Cold Drink', 'Party', 'Popular'],
        isPerishable: false,
        expiryDays: 180,
        price: 85.0,
        discount: 11,
      ),
      Product(
        id: 'demo-prod-8',
        name: 'Orange Juice (1L)',
        category: ProductCategory.beverages,
        imageUrl: 'assets/images/products/orange_juice.jpg',
        basePrice: 120.0,
        cost: 90.0,
        description: '100% natural orange juice, no added sugar',
        nutritionTags: const ['Natural', 'Healthy', 'Vitamin C'],
        isPerishable: true,
        expiryDays: 14,
        price: 110.0,
        discount: 8,
      ),

      // Bakery
      Product(
        id: 'demo-prod-9',
        name: 'Whole Wheat Bread',
        category: ProductCategory.bakery,
        imageUrl: 'assets/images/products/bread.jpg',
        basePrice: 45.0,
        cost: 30.0,
        description: 'Freshly baked whole wheat bread',
        nutritionTags: const ['Fresh', 'Whole Grain', 'Daily'],
        isPerishable: true,
        expiryDays: 3,
        price: 42.0,
        discount: 7,
      ),
      Product(
        id: 'demo-prod-10',
        name: 'Butter Croissant',
        category: ProductCategory.bakery,
        imageUrl: 'assets/images/products/croissant.jpg',
        basePrice: 65.0,
        cost: 45.0,
        description: 'Flaky, buttery French croissant',
        nutritionTags: const ['Fresh', 'Premium', 'Breakfast'],
        isPerishable: true,
        expiryDays: 2,
        price: 60.0,
        discount: 8,
      ),

      // Pantry
      Product(
        id: 'demo-prod-11',
        name: 'Basmati Rice (5kg)',
        category: ProductCategory.pantry,
        imageUrl: 'assets/images/products/rice.jpg',
        basePrice: 450.0,
        cost: 380.0,
        description: 'Premium aged basmati rice, long grain',
        nutritionTags: const ['Staple', 'Premium', 'Value Pack'],
        isPerishable: false,
        expiryDays: 365,
        price: 420.0,
        discount: 7,
      ),
      Product(
        id: 'demo-prod-12',
        name: 'Olive Oil (1L)',
        category: ProductCategory.pantry,
        imageUrl: 'assets/images/products/olive_oil.jpg',
        basePrice: 650.0,
        cost: 520.0,
        description: 'Extra virgin olive oil, cold pressed',
        nutritionTags: const ['Healthy', 'Premium', 'Cooking'],
        isPerishable: false,
        expiryDays: 365,
        price: 599.0,
        discount: 8,
      ),
    ];
  }

  /// Get products by category for demo mode
  List<Product> getProductsByCategory(ProductCategory category) {
    return getMockProducts().where((p) => p.category == category).toList();
  }

  /// Get demo user credentials
  Map<String, String> getDemoCredentials() {
    return {
      'email': 'demo@snackly.com',
      'password': 'demo123',
      'name': 'Demo User',
    };
  }

  /// Search products
  List<Product> searchProducts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getMockProducts().where((p) => 
      p.name.toLowerCase().contains(lowercaseQuery) ||
      p.description.toLowerCase().contains(lowercaseQuery) ||
      p.nutritionTags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  /// Get store by ID
  GroceryStore? getStoreById(String id) {
    try {
      return getMockStores().firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get product by ID
  Product? getProductById(String id) {
    try {
      return getMockProducts().firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
