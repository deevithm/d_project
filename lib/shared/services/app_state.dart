import 'package:flutter/foundation.dart';
import '../../core/models/user.dart';
import '../../core/models/grocery_store.dart';
import '../../core/models/product.dart';
import '../../core/models/order.dart';
import 'auth_service.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  GroceryStore? _selectedStore;
  List<GroceryStore> _stores = [];
  List<Product> _products = [];
  final List<CartItem> _cartItems = [];
  final List<Order> _orderHistory = []; // Add order history storage
  bool _isLoading = false;
  String? _error;
  AuthService? _authService;

  // Getters
  User? get currentUser => _currentUser;
  GroceryStore? get selectedStore => _selectedStore;
  List<GroceryStore> get stores => _stores;
  List<Product> get products => _products;
  List<CartItem> get cartItems => _cartItems;
  List<Order> get orderHistory => List.unmodifiable(_orderHistory); // Add order history getter
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null && _authService?.isAuthenticated == true;
  
  double get cartTotal => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get cartSavings => _cartItems.fold(0.0, (sum, item) => sum + item.totalSavings);
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  // Initialize AppState with AuthService
  void initializeWithAuth(AuthService authService) {
    _authService = authService;
    _authService!.addListener(_onAuthStateChanged);
    _syncWithAuthService();
  }

  // Sync current user with AuthService
  void _syncWithAuthService() {
    if (_authService != null) {
      _currentUser = _authService!.currentUser;
      notifyListeners();
    }
  }

  // Listen to auth state changes
  void _onAuthStateChanged() {
    _syncWithAuthService();
    if (!isAuthenticated) {
      // Clear app state when user logs out
      _selectedStore = null;
      _cartItems.clear();
      _stores.clear();
      _products.clear();
      notifyListeners();
    }
  }

  // User management
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _selectedStore = null;
    _cartItems.clear();
    _authService?.logout();
    notifyListeners();
  }

  // Store management
  void setSelectedStore(GroceryStore store) {
    _selectedStore = store;
    _cartItems.clear(); // Clear cart when switching stores
    notifyListeners();
  }

  void setStores(List<GroceryStore> stores) {
    _stores = stores;
    notifyListeners();
  }

  // Product management
  void setProducts(List<Product> products) {
    _products = products;
    notifyListeners();
  }

  // Cart management
  void addToCart(CartItem item) {
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.product.id == item.product.id,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + item.quantity,
      );
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _cartItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Order management
  void addOrder(Order order) {
    _orderHistory.insert(0, order); // Add to beginning of list (most recent first)
    notifyListeners();
  }

  Order? getOrder(String orderId) {
    try {
      return _orderHistory.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Loading and error states
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService?.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}