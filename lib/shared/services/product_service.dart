import '../../core/models/product.dart';
import '../../core/constants.dart';
import 'image_url_helper.dart';

class ProductService {
  static ProductService? _instance;
  static ProductService get instance => _instance ??= ProductService._();
  ProductService._();

  // Cache for products to avoid recreating them
  static List<Product>? _cachedProducts;

  /// Get all products with caching for better performance
  List<Product> getAllProducts() {
    _cachedProducts ??= _createAllProducts();
    return _cachedProducts!;
  }

  /// Get products for a specific store
  List<Product> getProductsForStore(String storeId) {
    final allProducts = getAllProducts();
    
    // Filter and modify products based on storeId
    List<Product> storeProducts = [];
    
    for (var product in allProducts) {
      // Apply store-specific filtering and modification
      final customizedProduct = _customizeProductForStore(product, storeId);
      
      // Store-specific product availability
      bool shouldInclude = _shouldIncludeProductInStore(product, storeId);
      
      if (shouldInclude) {
        storeProducts.add(customizedProduct);
      }
    }
    
    return storeProducts;
  }

  /// Determine if a product should be available in a specific store
  bool _shouldIncludeProductInStore(Product product, String storeId) {
    switch (storeId) {
      case 'store_001':
        // Premium store - all products available
        return true;
      case 'store_002':
        // Budget store - exclude very expensive items
        return product.basePrice <= 250.0;
      case 'store_003':
        // Local store - focus on essential items, exclude some categories
        return product.category != ProductCategory.snacks || product.basePrice <= 200.0;
      default:
        return true;
    }
  }

  /// Customize product properties based on store
  Product _customizeProductForStore(Product product, String storeId) {
    // Create different pricing based on store
    double priceMultiplier = 1.0;
    String namePrefix = '';
    
    // Store-specific modifications
    switch (storeId) {
      case 'store_001':
        // Premium store - higher prices
        priceMultiplier = 1.2;
        namePrefix = '';
        break;
      case 'store_002':
        // Budget store - lower prices, different selection
        priceMultiplier = 0.85;
        namePrefix = '';
        // Skip some premium products for budget store
        if (product.name.contains('Premium') && product.basePrice > 200) {
          return product; // Return original expensive products unchanged
        }
        break;
      case 'store_003':
        // Local store - moderate prices
        priceMultiplier = 1.05;
        namePrefix = '';
        break;
      default:
        // Default store
        priceMultiplier = 1.0;
        namePrefix = '';
    }

    // Apply store-specific changes
    return Product(
      id: '${product.id}_$storeId',
      name: '$namePrefix${product.name}',
      category: product.category,
      imageUrl: product.imageUrl,
      basePrice: (product.basePrice * priceMultiplier).roundToDouble(),
      cost: (product.cost * priceMultiplier).roundToDouble(),
      description: product.description,
      nutritionTags: product.nutritionTags,
      expiryDays: product.expiryDays,
      isPerishable: product.isPerishable,
    );
  }

  /// Clear cache to refresh products
  void clearCache() {
    _cachedProducts = null;
  }

  /// Create all products - moved from ProductBrowsingScreen
  List<Product> _createAllProducts() {
    return [
      // PREMIUM BEVERAGES
      Product(
        id: 'fresh_bev_001',
        name: 'Premium Fresh Orange Juice',
        category: ProductCategory.beverages,
        imageUrl: ImageUrlHelper.getImageUrl('fresh_bev_001'),
        basePrice: 120.0,
        cost: 90.0,
        description: 'Freshly squeezed orange juice - 500ml',
        nutritionTags: ['Vitamin C', 'Fresh', 'No Preservatives'],
      ),
      Product(
        id: 'fresh_bev_002',
        name: 'Coca Cola',
        category: ProductCategory.beverages,
        imageUrl: ImageUrlHelper.getImageUrl('fresh_bev_002'),
        basePrice: 180.0,
        cost: 140.0,
        description: 'Classic Coca Cola - 500ml',
        nutritionTags: ['Refreshing', 'Classic', 'Carbonated'],
      ),
      Product(
        id: 'fresh_bev_003',
        name: 'Pepsi',
        category: ProductCategory.beverages,
        imageUrl: ImageUrlHelper.getImageUrl('fresh_bev_003'),
        basePrice: 250.0,
        cost: 190.0,
        description: 'Premium Pepsi Cola - 500ml',
        nutritionTags: ['Refreshing', 'Cola', 'Carbonated'],
      ),
      
      // FRESH DAIRY
      Product(
        id: 'fresh_dairy_001',
        name: 'Organic Whole Milk',
        category: ProductCategory.dairy,
        imageUrl: 'https://picsum.photos/400/400?random=10',
        basePrice: 65.0,
        cost: 50.0,
        description: 'Fresh organic whole milk - 1 liter',
        nutritionTags: ['Organic', 'Protein', 'Calcium'],
      ),
      Product(
        id: 'fresh_dairy_002',
        name: 'Greek Yogurt',
        category: ProductCategory.dairy,
        imageUrl: 'https://picsum.photos/400/400?random=11',
        basePrice: 120.0,
        cost: 95.0,
        description: 'Thick Greek yogurt - 200g',
        nutritionTags: ['Probiotics', 'High Protein', 'Natural'],
      ),
      Product(
        id: 'fresh_dairy_003',
        name: 'Artisan Cheese',
        category: ProductCategory.dairy,
        imageUrl: 'https://picsum.photos/400/400?random=11',
        basePrice: 280.0,
        cost: 220.0,
        description: 'Premium artisan cheese selection - 150g',
        nutritionTags: ['Artisan', 'Premium', 'Aged'],
      ),

      // BAKERY FRESH
      Product(
        id: 'fresh_bakery_001',
        name: 'Artisan Sourdough Bread',
        category: ProductCategory.bakery,
        imageUrl: 'https://picsum.photos/400/400?random=12',
        basePrice: 150.0,
        cost: 110.0,
        description: 'Freshly baked sourdough bread - 400g',
        nutritionTags: ['Artisan', 'Fresh Baked', 'Natural Fermentation'],
      ),
      Product(
        id: 'fresh_bakery_002',
        name: 'Chocolate Croissants',
        category: ProductCategory.bakery,
        imageUrl: 'https://picsum.photos/400/400?random=12',
        basePrice: 45.0,
        cost: 30.0,
        description: 'Buttery chocolate croissants - 2 pieces',
        nutritionTags: ['Fresh Baked', 'Buttery', 'Chocolate'],
      ),
      Product(
        id: 'fresh_bakery_003',
        name: 'Multigrain Bagels',
        category: ProductCategory.bakery,
        imageUrl: 'https://images.unsplash.com/photo-1584461862065-0b5d80fd1e19?w=400&h=400&fit=crop',
        basePrice: 80.0,
        cost: 60.0,
        description: 'Healthy multigrain bagels - 4 pieces',
        nutritionTags: ['Multigrain', 'Healthy', 'Fresh Baked'],
      ),

      // PREMIUM SNACKS
      Product(
        id: 'fresh_snack_001',
        name: 'Mixed Nuts Premium',
        category: ProductCategory.snacks,
        imageUrl: 'https://images.unsplash.com/photo-1608197142235-1d9d83da7a00?w=400&h=400&fit=crop',
        basePrice: 320.0,
        cost: 250.0,
        description: 'Premium mixed nuts - 200g',
        nutritionTags: ['Protein', 'Healthy Fats', 'Premium'],
      ),
      Product(
        id: 'fresh_snack_002',
        name: 'Dark Chocolate Bar',
        category: ProductCategory.snacks,
        imageUrl: 'https://images.unsplash.com/photo-1606312619070-d48b4c652a52?w=400&h=400&fit=crop',
        basePrice: 180.0,
        cost: 140.0,
        description: '70% dark chocolate bar - 100g',
        nutritionTags: ['Dark Chocolate', 'Antioxidants', 'Premium'],
      ),
      Product(
        id: 'fresh_snack_003',
        name: 'Organic Trail Mix',
        category: ProductCategory.snacks,
        imageUrl: 'https://images.unsplash.com/photo-1621939514649-280e2ee25f60?w=400&h=400&fit=crop',
        basePrice: 240.0,
        cost: 180.0,
        description: 'Organic trail mix with dried fruits - 150g',
        nutritionTags: ['Organic', 'Energy', 'Dried Fruits'],
      ),

      // FRESH PRODUCE
      Product(
        id: 'fresh_produce_001',
        name: 'Organic Bananas',
        category: ProductCategory.fruits,
        imageUrl: 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=400&h=400&fit=crop',
        basePrice: 60.0,
        cost: 40.0,
        description: 'Fresh organic bananas - 1 dozen',
        nutritionTags: ['Organic', 'Potassium', 'Natural Energy'],
      ),
      Product(
        id: 'fresh_produce_002',
        name: 'Premium Apples',
        category: ProductCategory.fruits,
        imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&h=400&fit=crop',
        basePrice: 180.0,
        cost: 140.0,
        description: 'Premium red apples - 1kg',
        nutritionTags: ['Premium', 'Fiber', 'Vitamin C'],
      ),
      Product(
        id: 'fresh_produce_003',
        name: 'Avocado Premium',
        category: ProductCategory.fruits,
        imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=400&h=400&fit=crop',
        basePrice: 120.0,
        cost: 90.0,
        description: 'Premium ripe avocados - 2 pieces',
        nutritionTags: ['Healthy Fats', 'Premium', 'Ripe'],
      ),

      // BABY CARE ESSENTIALS
      Product(
        id: 'fresh_baby_001',
        name: 'Organic Baby Food',
        category: ProductCategory.babycare,
        imageUrl: 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400&h=400&fit=crop',
        basePrice: 150.0,
        cost: 120.0,
        description: 'Organic baby food puree - apple & banana',
        nutritionTags: ['Organic', 'No Additives', 'Baby Safe'],
      ),
      Product(
        id: 'fresh_baby_002',
        name: 'Baby Wipes Natural',
        category: ProductCategory.babycare,
        imageUrl: 'https://images.unsplash.com/photo-1591301191961-a65d4262e576?w=400&h=400&fit=crop',
        basePrice: 280.0,
        cost: 220.0,
        description: 'Natural baby wipes - 80 sheets',
        nutritionTags: ['Natural', 'Gentle', 'Hypoallergenic'],
      ),

      // HOUSEHOLD ESSENTIALS
      Product(
        id: 'fresh_household_001',
        name: 'Eco-Friendly Detergent',
        category: ProductCategory.household,
        imageUrl: 'https://images.unsplash.com/photo-1563453392212-326f5e854473?w=400&h=400&fit=crop',
        basePrice: 320.0,
        cost: 260.0,
        description: 'Eco-friendly laundry detergent - 1kg',
        nutritionTags: ['Eco-Friendly', 'Biodegradable', 'Effective'],
      ),
      Product(
        id: 'fresh_household_002',
        name: 'Natural Dish Soap',
        category: ProductCategory.household,
        imageUrl: 'https://images.unsplash.com/photo-1585503418537-88331351ad99?w=400&h=400&fit=crop',
        basePrice: 150.0,
        cost: 120.0,
        description: 'Natural dish soap - 500ml',
        nutritionTags: ['Natural', 'Plant-Based', 'Gentle on Hands'],
      ),

      // PERSONAL CARE
      Product(
        id: 'fresh_personal_001',
        name: 'Organic Shampoo',
        category: ProductCategory.personalcare,
        imageUrl: 'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400&h=400&fit=crop',
        basePrice: 450.0,
        cost: 350.0,
        description: 'Organic sulfate-free shampoo - 250ml',
        nutritionTags: ['Organic', 'Sulfate-Free', 'Natural'],
      ),
      Product(
        id: 'fresh_personal_002',
        name: 'Natural Toothpaste',
        category: ProductCategory.personalcare,
        imageUrl: 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=400&h=400&fit=crop',
        basePrice: 180.0,
        cost: 140.0,
        description: 'Natural fluoride-free toothpaste - 100g',
        nutritionTags: ['Natural', 'Fluoride-Free', 'Mint Fresh'],
      ),

      // HEALTH & WELLNESS
      Product(
        id: 'fresh_health_001',
        name: 'Vitamin C Tablets',
        category: ProductCategory.health,
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
        basePrice: 380.0,
        cost: 300.0,
        description: 'Vitamin C immunity tablets - 60 tablets',
        nutritionTags: ['Immune Support', 'Vitamin C', 'Daily Supplement'],
      ),
      Product(
        id: 'fresh_health_002',
        name: 'Protein Powder',
        category: ProductCategory.health,
        imageUrl: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400&h=400&fit=crop',
        basePrice: 2500.0,
        cost: 2000.0,
        description: 'Whey protein powder - 1kg',
        nutritionTags: ['High Protein', 'Muscle Building', 'Post Workout'],
      ),

      // FROZEN FOODS
      Product(
        id: 'fresh_frozen_001',
        name: 'Frozen Mixed Vegetables',
        category: ProductCategory.frozen,
        imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=400&fit=crop',
        basePrice: 120.0,
        cost: 90.0,
        description: 'Premium frozen mixed vegetables - 500g',
        nutritionTags: ['Frozen Fresh', 'Mixed Vegetables', 'Convenient'],
      ),
      Product(
        id: 'fresh_frozen_002',
        name: 'Frozen Berry Mix',
        category: ProductCategory.frozen,
        imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=400&fit=crop',
        basePrice: 280.0,
        cost: 220.0,
        description: 'Premium frozen berry mix - 300g',
        nutritionTags: ['Antioxidants', 'Frozen Fresh', 'Mixed Berries'],
      ),

      // PANTRY STAPLES
      Product(
        id: 'fresh_pantry_001',
        name: 'Organic Quinoa',
        category: ProductCategory.pantry,
        imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop',
        basePrice: 450.0,
        cost: 350.0,
        description: 'Organic quinoa - 500g',
        nutritionTags: ['Organic', 'Complete Protein', 'Gluten-Free'],
      ),
      Product(
        id: 'fresh_pantry_002',
        name: 'Extra Virgin Olive Oil',
        category: ProductCategory.pantry,
        imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop',
        basePrice: 650.0,
        cost: 500.0,
        description: 'Extra virgin olive oil - 500ml',
        nutritionTags: ['Extra Virgin', 'Heart Healthy', 'Premium'],
      ),
    ];
  }

  /// Get products by category
  List<Product> getProductsByCategory(ProductCategory category) {
    return getAllProducts().where((product) => product.category == category).toList();
  }

  /// Get featured products (top 10 by rating or custom criteria)
  List<Product> getFeaturedProducts({int count = 10}) {
    final allProducts = getAllProducts();
    // Return first `count` products as featured for now
    return allProducts.take(count).toList();
  }

  /// Search products by name or description
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return getAllProducts();
    
    final lowercaseQuery = query.toLowerCase();
    return getAllProducts().where((product) {
      return product.name.toLowerCase().contains(lowercaseQuery) ||
             product.description.toLowerCase().contains(lowercaseQuery) ||
             product.nutritionTags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }
}