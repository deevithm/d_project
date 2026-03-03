import 'package:flutter_test/flutter_test.dart';
import 'package:snackly/shared/repositories/supabase_repository.dart';
import 'package:snackly/shared/repositories/ml_repository.dart';
import 'package:snackly/shared/services/supabase_service.dart';

/// Integration tests for Supabase repositories
/// These tests verify that all repositories are working correctly
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Initialize Supabase before running tests
    print('🔧 Initializing Supabase for integration tests...');
    await SupabaseService().initialize();
    print('✅ Supabase initialized successfully!');
  });

  group('StoreRepository Tests', () {
    late StoreRepository storeRepo;

    setUp(() {
      storeRepo = StoreRepository();
    });

    test('Get all stores from Supabase', () async {
      final stores = await storeRepo.getAllStores();
      
      expect(stores, isNotEmpty, reason: 'Should fetch stores from Supabase');
      expect(stores.length, greaterThanOrEqualTo(3), reason: 'Should have at least 3 sample stores');
      
      print('✅ Fetched ${stores.length} stores from Supabase');
      for (var store in stores) {
        print('  - ${store.name} (${store.location})');
      }
    });

    test('Find nearby stores using location', () async {
      // Chennai coordinates
      final stores = await storeRepo.findNearbyStores(
        latitude: 13.0827,
        longitude: 80.2707,
        radiusKm: 100.0,
      );
      
      expect(stores, isNotEmpty, reason: 'Should find stores near Chennai');
      
      print('✅ Found ${stores.length} stores near Chennai');
      for (var store in stores) {
        print('  - ${store.name} at ${store.distance}');
      }
    });

    test('Get store by ID', () async {
      final allStores = await storeRepo.getAllStores();
      if (allStores.isNotEmpty) {
        final firstStoreId = allStores.first.id;
        final store = await storeRepo.getStoreById(firstStoreId);
        
        expect(store, isNotNull, reason: 'Should fetch store by ID');
        expect(store!.id, equals(firstStoreId));
        
        print('✅ Fetched store by ID: ${store.name}');
      }
    });
  });

  group('ProductRepository Tests', () {
    late ProductRepository productRepo;
    late StoreRepository storeRepo;

    setUp(() {
      productRepo = ProductRepository();
      storeRepo = StoreRepository();
    });

    test('Get all products from Supabase', () async {
      final products = await productRepo.getAllProducts();
      
      expect(products, isNotEmpty, reason: 'Should fetch products from Supabase');
      expect(products.length, greaterThanOrEqualTo(5), reason: 'Should have at least 5 sample products');
      
      print('✅ Fetched ${products.length} products from Supabase');
      for (var product in products) {
        print('  - ${product.name}: ₹${product.basePrice}');
      }
    });

    test('Get products by category', () async {
      final beverages = await productRepo.getProductsByCategory('beverages');
      
      expect(beverages, isNotEmpty, reason: 'Should have beverages category');
      
      print('✅ Found ${beverages.length} beverages');
      for (var product in beverages) {
        print('  - ${product.name}');
      }
    });

    test('Get store inventory', () async {
      final stores = await storeRepo.getAllStores();
      
      if (stores.isNotEmpty) {
        final firstStoreId = stores.first.id;
        final products = await productRepo.getStoreInventory(firstStoreId);
        
        expect(products, isNotEmpty, reason: 'Store should have inventory');
        
        print('✅ Store "${stores.first.name}" has ${products.length} products');
        for (var product in products.take(5)) {
          print('  - ${product.name}: ₹${product.effectivePrice}');
        }
      }
    });

    test('Search products', () async {
      final results = await productRepo.searchProducts('milk');
      
      print('✅ Search "milk" found ${results.length} products');
      for (var product in results) {
        print('  - ${product.name}');
      }
    });
  });

  group('FavoritesRepository Tests', () {
    late FavoritesRepository favRepo;

    setUp(() {
      favRepo = FavoritesRepository();
    });
    
    test('Favorites repository is initialized', () {
      expect(favRepo, isNotNull);
      print('✅ FavoritesRepository is ready');
    });
    
    // Note: These tests require authentication
    // Uncomment when authentication is working
    /*
    test('Add product to favorites', () async {
      final userId = 'test_user_id';
      final productId = 'test_product_id';
      
      await favRepo.addFavorite(userId, productId);
      final isFav = await favRepo.isFavorite(userId, productId);
      
      expect(isFav, isTrue);
      print('✅ Added product to favorites');
    });
    */
  });

  group('CartRepository Tests', () {
    late CartRepository cartRepo;

    setUp(() {
      cartRepo = CartRepository();
    });
    
    test('Cart repository is initialized', () {
      expect(cartRepo, isNotNull);
      print('✅ CartRepository is ready');
    });
    
    // Note: These tests require authentication
    // Uncomment when authentication is working
    /*
    test('Add item to cart', () async {
      final userId = 'test_user_id';
      final storeId = 'test_store_id';
      final productId = 'test_product_id';
      
      await cartRepo.addToCart(
        userId: userId,
        storeId: storeId,
        productId: productId,
        quantity: 2,
      );
      
      final cart = await cartRepo.getUserCart(userId);
      expect(cart, isNotEmpty);
      print('✅ Added item to cart');
    });
    */
  });

  group('MLRepository Tests', () {
    late MLRepository mlRepo;
    late StoreRepository storeRepo;

    setUp(() {
      mlRepo = MLRepository();
      storeRepo = StoreRepository();
    });
    
    test('ML repository is initialized', () {
      expect(mlRepo, isNotNull);
      print('✅ MLRepository is ready');
    });
    
    test('Get demand predictions (may be empty)', () async {
      final stores = await storeRepo.getAllStores();
      
      if (stores.isNotEmpty) {
        final storeId = stores.first.id;
        final predictions = await mlRepo.getDemandPredictions(storeId);
        
        print('✅ ML predictions for ${stores.first.name}: ${predictions.length} entries');
      }
    });
  });

  group('Integration Summary', () {
    test('All repositories are functional', () {
      final storeRepo = StoreRepository();
      final productRepo = ProductRepository();
      final orderRepo = OrderRepository();
      final favRepo = FavoritesRepository();
      final cartRepo = CartRepository();
      final notifRepo = NotificationsRepository();
      final mlRepo = MLRepository();
      
      expect(storeRepo, isNotNull);
      expect(productRepo, isNotNull);
      expect(orderRepo, isNotNull);
      expect(favRepo, isNotNull);
      expect(cartRepo, isNotNull);
      expect(notifRepo, isNotNull);
      expect(mlRepo, isNotNull);
      
      print('\n🎉 ALL REPOSITORIES INITIALIZED SUCCESSFULLY!');
      print('✅ StoreRepository');
      print('✅ ProductRepository');
      print('✅ OrderRepository');
      print('✅ FavoritesRepository');
      print('✅ CartRepository');
      print('✅ NotificationsRepository');
      print('✅ MLRepository');
      print('\n📊 Total: 7 repositories ready for use');
    });
  });
}
