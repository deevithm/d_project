import 'package:flutter_test/flutter_test.dart';

import 'package:snackly/shared/services/app_state.dart';
import 'package:snackly/core/models/product.dart';
import 'package:snackly/core/models/order.dart';
import 'package:snackly/core/constants.dart';

void main() {
  group('Shopping Cart Functionality Tests', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    test('AppState should initialize with empty cart', () {
      expect(appState.cartItems.length, 0);
      expect(appState.cartItemCount, 0);
      expect(appState.cartTotal, 0.0);
    });

    test('Should add product to cart successfully', () {
      // Create a test product
      final product = Product(
        id: 'test-1',
        name: 'Test Coca Cola',
        description: 'Refreshing cola drink',
        basePrice: 40.0,
        cost: 30.0,
        category: ProductCategory.beverages,
        imageUrl: 'test-image.jpg',
      );

      // Create cart item
      final cartItem = CartItem(
        product: product,
        quantity: 1,
        currentPrice: product.basePrice,
      );

      // Add to cart
      appState.addToCart(cartItem);

      // Verify product was added
      expect(appState.cartItems.length, 1);
      expect(appState.cartItemCount, 1);
      expect(appState.cartTotal, 40.0);
      expect(appState.cartItems.first.product.name, 'Test Coca Cola');
      expect(appState.cartItems.first.quantity, 1);
    });

    test('Should increase quantity when adding same product', () {
      final product = Product(
        id: 'test-1',
        name: 'Test Coca Cola',
        description: 'Refreshing cola drink',
        basePrice: 40.0,
        cost: 30.0,
        category: ProductCategory.beverages,
        imageUrl: 'test-image.jpg',
      );

      final cartItem = CartItem(
        product: product,
        quantity: 1,
        currentPrice: product.basePrice,
      );

      // Add product twice
      appState.addToCart(cartItem);
      appState.addToCart(cartItem);

      // Verify quantity increased
      expect(appState.cartItems.length, 1);
      expect(appState.cartItemCount, 2);
      expect(appState.cartTotal, 80.0);
      expect(appState.cartItems.first.quantity, 2);
    });

    test('Should update cart item quantity', () {
      final product = Product(
        id: 'test-1',
        name: 'Test Coca Cola',
        description: 'Refreshing cola drink',
        basePrice: 40.0,
        cost: 30.0,
        category: ProductCategory.beverages,
        imageUrl: 'test-image.jpg',
      );

      final cartItem = CartItem(
        product: product,
        quantity: 1,
        currentPrice: product.basePrice,
      );

      // Add product and update quantity
      appState.addToCart(cartItem);
      appState.updateCartItemQuantity('test-1', 3);

      // Verify quantity updated
      expect(appState.cartItems.length, 1);
      expect(appState.cartItemCount, 3);
      expect(appState.cartTotal, 120.0);
      expect(appState.cartItems.first.quantity, 3);
    });

    test('Should remove item from cart when quantity is 0', () {
      final product = Product(
        id: 'test-1',
        name: 'Test Coca Cola',
        description: 'Refreshing cola drink',
        basePrice: 40.0,
        cost: 30.0,
        category: ProductCategory.beverages,
        imageUrl: 'test-image.jpg',
      );

      final cartItem = CartItem(
        product: product,
        quantity: 1,
        currentPrice: product.basePrice,
      );

      // Add product and set quantity to 0
      appState.addToCart(cartItem);
      appState.updateCartItemQuantity('test-1', 0);

      // Verify item removed
      expect(appState.cartItems.length, 0);
      expect(appState.cartItemCount, 0);
      expect(appState.cartTotal, 0.0);
    });

    test('Should remove specific item from cart', () {
      final product1 = Product(
        id: 'test-1',
        name: 'Test Coca Cola',
        description: 'Refreshing cola drink',
        basePrice: 40.0,
        cost: 30.0,
        category: ProductCategory.beverages,
        imageUrl: 'test-image.jpg',
      );

      final product2 = Product(
        id: 'test-2',
        name: 'Test Lays',
        description: 'Crispy potato chips',
        basePrice: 25.0,
        cost: 15.0,
        category: ProductCategory.snacks,
        imageUrl: 'test-image.jpg',
      );

      final cartItem1 = CartItem(
        product: product1,
        quantity: 1,
        currentPrice: product1.basePrice,
      );

      final cartItem2 = CartItem(
        product: product2,
        quantity: 1,
        currentPrice: product2.basePrice,
      );

      // Add both products
      appState.addToCart(cartItem1);
      appState.addToCart(cartItem2);

      // Remove first product
      appState.removeFromCart('test-1');

      // Verify only second product remains
      expect(appState.cartItems.length, 1);
      expect(appState.cartItemCount, 1);
      expect(appState.cartTotal, 25.0);
      expect(appState.cartItems.first.product.name, 'Test Lays');
    });

    test('Should calculate total with multiple items', () {
      final product1 = Product(
        id: 'test-1',
        name: 'Test Coca Cola',
        description: 'Refreshing cola drink',
        basePrice: 40.0,
        cost: 30.0,
        category: ProductCategory.beverages,
        imageUrl: 'test-image.jpg',
      );

      final product2 = Product(
        id: 'test-2',
        name: 'Test Lays',
        description: 'Crispy potato chips',
        basePrice: 25.0,
        cost: 15.0,
        category: ProductCategory.snacks,
        imageUrl: 'test-image.jpg',
      );

      final cartItem1 = CartItem(
        product: product1,
        quantity: 1,
        currentPrice: product1.basePrice,
      );

      final cartItem2 = CartItem(
        product: product2,
        quantity: 1,
        currentPrice: product2.basePrice,
      );

      // Add products with different quantities
      appState.addToCart(cartItem1);
      appState.addToCart(cartItem1); // 2x Coca Cola
      appState.addToCart(cartItem2);
      appState.updateCartItemQuantity('test-2', 3); // 3x Lays

      // Verify calculations
      expect(appState.cartItems.length, 2);
      expect(appState.cartItemCount, 5); // 2 + 3
      expect(appState.cartTotal, 155.0); // (2 * 40) + (3 * 25)
    });

    test('Should clear cart', () {
      final product = Product(
        id: 'test-1',
        name: 'Test Coca Cola',
        description: 'Refreshing cola drink',
        basePrice: 40.0,
        cost: 30.0,
        category: ProductCategory.beverages,
        imageUrl: 'test-image.jpg',
      );

      final cartItem = CartItem(
        product: product,
        quantity: 1,
        currentPrice: product.basePrice,
      );

      // Add product and clear cart
      appState.addToCart(cartItem);
      appState.clearCart();

      // Verify cart is empty
      expect(appState.cartItems.length, 0);
      expect(appState.cartItemCount, 0);
      expect(appState.cartTotal, 0.0);
    });
  });
}