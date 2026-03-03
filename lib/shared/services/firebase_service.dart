import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/product.dart';
import '../../core/models/grocery_store.dart';
import '../../core/models/order.dart' as app_models;
import '../../core/constants.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time store inventory
  Stream<List<Product>> getStoreProducts(String storeId) {
    return _firestore
        .collection('stores')
        .doc(storeId)
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Real-time nearby stores
  Stream<List<GroceryStore>> getNearbyStores() {
    return _firestore
        .collection('stores')
        .where('isOpen', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroceryStore.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Real-time order tracking
  Stream<app_models.Order> trackOrder(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) => app_models.Order.fromJson({...doc.data()!, 'id': doc.id}));
  }

  // Create order
  Future<String> createOrder(app_models.Order order) async {
    final docRef = await _firestore.collection('orders').add(order.toJson());
    return docRef.id;
  }

  // Update product stock
  Future<void> updateProductStock(String storeId, String productId, int newStock) async {
    await _firestore
        .collection('stores')
        .doc(storeId)
        .collection('products')
        .doc(productId)
        .update({
      'stock': newStock, 
      'updatedAt': FieldValue.serverTimestamp(),
      'isAvailable': newStock > 0
    });
  }

  // Add store
  Future<void> addStore(GroceryStore store) async {
    await _firestore.collection('stores').doc(store.id).set(store.toJson());
  }

  // Add product to store
  Future<void> addProductToStore(String storeId, Product product) async {
    await _firestore
        .collection('stores')
        .doc(storeId)
        .collection('products')
        .doc(product.id)
        .set({
      ...product.toJson(),
      'stock': 50, // Default stock
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update store status
  Future<void> updateStoreStatus(String storeId, StoreStatus status) async {
    await _firestore.collection('stores').doc(storeId).update({
      'status': status.name,
      'isOpen': status == StoreStatus.open,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get store details
  Future<GroceryStore?> getStore(String storeId) async {
    final doc = await _firestore.collection('stores').doc(storeId).get();
    if (doc.exists) {
      return GroceryStore.fromJson({...doc.data()!, 'id': doc.id});
    }
    return null;
  }
}