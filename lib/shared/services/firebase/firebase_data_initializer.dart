import 'package:flutter/foundation.dart';
import '../firebase_service.dart';
import '../../../core/models/grocery_store.dart';
import '../../../core/models/product.dart';
import '../../../core/constants.dart';

class FirebaseDataInitializer {
  static final FirebaseService _firebaseService = FirebaseService();

  /// Initialize Firebase with sample grocery store data
  static Future<void> initializeSampleData() async {
    try {
      // Create sample stores
      await _createSampleStores();
      
      // Add products to each store
      await _addProductsToStores();
      
      debugPrint('Firebase sample data initialized successfully!');
    } catch (e) {
      debugPrint('Error initializing Firebase data: $e');
    }
  }

  static Future<void> _createSampleStores() async {
    final stores = [
      GroceryStore(
        id: 'store_001',
        name: 'FreshMart Chennai Central',
        location: 'Anna Salai, Chennai - 600002',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 'Asia/Kolkata',
        status: StoreStatus.open,
        lastUpdated: DateTime.now(),
        currentStock: {},
      ),
      GroceryStore(
        id: 'store_002',
        name: 'Campus Quick Mart',
        location: 'University Library Main Floor, Koramangala',
        latitude: 12.9734,
        longitude: 77.5950,
        timezone: 'Asia/Kolkata',
        status: StoreStatus.open,
        lastUpdated: DateTime.now(),
        currentStock: {},
      ),
      GroceryStore(
        id: 'store_003',
        name: 'Express Grocery Hub',
        location: 'Mall Food Court, Brigade Road',
        latitude: 12.9748,
        longitude: 77.5952,
        timezone: 'Asia/Kolkata',
        status: StoreStatus.temporarilyClosed,
        lastUpdated: DateTime.now(),
        currentStock: {},
      ),
    ];

    for (final store in stores) {
      await _firebaseService.addStore(store);
    }
  }

  static Future<void> _addProductsToStores() async {
    final products = [
      Product(
        id: 'prod_001',
        name: 'Basmati Rice 5kg',
        category: ProductCategory.food,
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=600&fit=crop&crop=center',
        basePrice: 450.0,
        cost: 350.0,
        description: 'Premium quality basmati rice',
        nutritionTags: ['Gluten Free', 'Low Fat'],
        isPerishable: false,
      ),
      Product(
        id: 'prod_002',
        name: 'Fresh Bananas 1kg',
        category: ProductCategory.food,
        imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=600&fit=crop&crop=center',
        basePrice: 60.0,
        cost: 40.0,
        description: 'Fresh ripe bananas',
        nutritionTags: ['Rich in Potassium', 'Natural'],
        isPerishable: true,
      ),
      Product(
        id: 'prod_003',
        name: 'Whole Wheat Bread',
        category: ProductCategory.food,
        imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=600&fit=crop&crop=center',
        basePrice: 45.0,
        cost: 30.0,
        description: 'Fresh whole wheat bread loaf',
        nutritionTags: ['Whole Grain', 'High Fiber'],
        isPerishable: true,
      ),
      Product(
        id: 'prod_004',
        name: 'Milk 1L',
        category: ProductCategory.beverages,
        imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&h=600&fit=crop&crop=center',
        basePrice: 55.0,
        cost: 40.0,
        description: 'Fresh full cream milk',
        nutritionTags: ['High Calcium', 'Protein Rich'],
        isPerishable: true,
      ),
      Product(
        id: 'prod_005',
        name: 'Eggs 12 pieces',
        category: ProductCategory.food,
        imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&h=600&fit=crop&crop=center',
        basePrice: 75.0,
        cost: 55.0,
        description: 'Fresh farm eggs',
        nutritionTags: ['High Protein', 'Vitamin D'],
        isPerishable: true,
      ),
      Product(
        id: 'prod_006',
        name: 'Tomatoes 500g',
        category: ProductCategory.food,
        imageUrl: 'https://images.unsplash.com/photo-1546470427-e212b9d56085?w=400&h=600&fit=crop&crop=center',
        basePrice: 35.0,
        cost: 25.0,
        description: 'Fresh red tomatoes',
        nutritionTags: ['Vitamin C', 'Lycopene'],
        isPerishable: true,
      ),
      Product(
        id: 'prod_007',
        name: 'Onions 1kg',
        category: ProductCategory.food,
        imageUrl: 'https://images.unsplash.com/photo-1508747703725-719777637510?w=400&h=600&fit=crop&crop=center',
        basePrice: 40.0,
        cost: 30.0,
        description: 'Fresh white onions',
        nutritionTags: ['Antioxidants', 'Natural'],
        isPerishable: true,
      ),
      Product(
        id: 'prod_008',
        name: 'Green Tea Bags',
        category: ProductCategory.beverages,
        imageUrl: 'https://images.unsplash.com/photo-1627435601361-ec25f5b1d0e5?w=400&h=600&fit=crop&crop=center',
        basePrice: 120.0,
        cost: 85.0,
        description: 'Premium green tea - 25 bags',
        nutritionTags: ['Antioxidants', 'Natural'],
        isPerishable: false,
      ),
    ];

    final storeIds = ['store_001', 'store_002', 'store_003'];

    for (final storeId in storeIds) {
      for (final product in products) {
        await _firebaseService.addProductToStore(storeId, product);
      }
    }
  }
}