
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

import 'shared/services/app_state.dart';
import 'shared/services/auth_service.dart';
import 'shared/services/theme_service.dart';
import 'shared/services/localization_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/supabase_service.dart';
import 'shared/repositories/order_repository.dart';
import 'shared/widgets/main_navigation_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/product_browsing/product_browsing_screen.dart';
import 'features/shopping_cart/cart_screen.dart';
import 'features/checkout/checkout_screen.dart';
import 'features/checkout/order_confirmation_screen.dart';
import 'features/authentication/login_screen.dart';
import 'features/authentication/register_screen.dart';
import 'features/settings/change_password_screen.dart';
import 'features/settings/terms_conditions_screen.dart';
import 'features/settings/privacy_policy_screen.dart';
import 'features/diagnostics/supabase_diagnostic_screen.dart';
import 'features/admin/admin_login_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/admin_orders_screen.dart';
import 'features/admin/admin_payments_screen.dart';
import 'core/constants.dart';
import 'core/models/order.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (with error handling)
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('App will continue without Firebase features');
  }
  
  // Initialize Supabase (with error handling - enables demo mode on failure)
  await SupabaseService().initialize();
  
  runApp(const GroceryStoreApp());
}

class GroceryStoreApp extends StatefulWidget {
  const GroceryStoreApp({super.key});

  @override
  State<GroceryStoreApp> createState() => _GroceryStoreAppState();
}

class _GroceryStoreAppState extends State<GroceryStoreApp> {
  late AuthService _authService;
  late AppState _appState;
  late ThemeService _themeService;
  late LocalizationService _localizationService;
  late NotificationService _notificationService;
  late OrderRepository _orderRepository;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _appState = AppState();
    _themeService = ThemeService();
    _localizationService = LocalizationService();
    _notificationService = NotificationService();
    _orderRepository = OrderRepository();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _authService.initialize();
      await _themeService.initialize();
      await _localizationService.initialize();
      await _notificationService.initialize();
      await _orderRepository.initialize();
      _appState.initializeWithAuth(_authService);
    } catch (e) {
      debugPrint('Failed to initialize services: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/images/snackly_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.restaurant,
                          size: 60,
                          color: Colors.brown.shade600,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Snackly',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Smart Grocery Store Made Simple',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _appState),
        ChangeNotifierProvider.value(value: _authService),
        ChangeNotifierProvider.value(value: _themeService),
        ChangeNotifierProvider.value(value: _localizationService),
        ChangeNotifierProvider.value(value: _notificationService),
        ChangeNotifierProvider.value(value: _orderRepository),
      ],
      child: Consumer3<AuthService, ThemeService, LocalizationService>(
        builder: (context, authService, themeService, localizationService, child) {
          return MaterialApp.router(
            title: 'Snackly',
            debugShowCheckedModeBanner: false,
            themeMode: themeService.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.light,
                surface: AppColors.background,
              ),
              scaffoldBackgroundColor: AppColors.background,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.surface,
                elevation: 0,
                iconTheme: IconThemeData(color: AppColors.textPrimary),
                titleTextStyle: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              cardTheme: CardThemeData(
                color: AppColors.cardBackground,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF1E1E1E),
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF1E1E1E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF333333), width: 1),
                ),
              ),
              useMaterial3: true,
            ),
            routerConfig: _createRouter(authService),
          );
        },
      ),
    );
  }
}

GoRouter _createRouter(AuthService authService) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authService, // Listen to auth state changes
    redirect: (context, state) {
      final isLoggedIn = authService.isAuthenticated;
      final isLoginRoute = state.fullPath == AppRoutes.login;
      final isRegisterRoute = state.fullPath == AppRoutes.register;
      final isSplashRoute = state.fullPath == '/';
      final isOnboardingRoute = state.fullPath == '/onboarding';
      final isAdminRoute = state.fullPath?.startsWith('/admin') ?? false;
      
      debugPrint('🔀 GoRouter redirect - Path: ${state.fullPath}, isLoggedIn: $isLoggedIn');
      
      // Allow admin routes to have their own auth handling
      if (isAdminRoute) {
        return null;
      }
      
      // Allow splash and onboarding routes
      if (isSplashRoute || isOnboardingRoute) {
        return null;
      }
      
      // If not logged in and not on auth routes, redirect to login
      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) {
        debugPrint('🔀 Redirecting to login (not authenticated)');
        return AppRoutes.login;
      }
      
      // If logged in and on auth routes, redirect to stores
      if (isLoggedIn && (isLoginRoute || isRegisterRoute)) {
        debugPrint('🔀 Redirecting to stores (authenticated)');
        return AppRoutes.stores;
      }
      
      return null; // No redirect needed
    },
    routes: [
      // Splash Route
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding Route
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Main Navigation Routes
      GoRoute(
        path: AppRoutes.stores,
        builder: (context, state) => const MainNavigationScreen(initialIndex: 0),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const MainNavigationScreen(initialIndex: 1),
      ),
      GoRoute(
        path: AppRoutes.favorites,
        builder: (context, state) => const MainNavigationScreen(initialIndex: 2),
      ),
      
      // Product Flow Routes (outside main navigation)
      GoRoute(
        path: '${AppRoutes.products}/:storeId',
        builder: (context, state) {
          final storeId = state.pathParameters['storeId']!;
          return ProductBrowsingScreen(storeId: storeId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.cart}/:storeId',
        builder: (context, state) {
          final storeId = state.pathParameters['storeId']!;
          return CartScreen(storeId: storeId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.checkout}/:storeId',
        builder: (context, state) {
          final storeId = state.pathParameters['storeId']!;
          return CheckoutScreen(storeId: storeId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.orderConfirmation}/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          
          // Mock order lookup for development/academic project
          final placeholderOrder = Order(
            id: orderId,
            storeId: 'store_001',
            userId: 'temp-user',
            items: [],
            totalAmount: 0.0,
            paymentMethod: PaymentMethod.upi,
            status: OrderStatus.confirmed,
            createdAt: DateTime.now(),
          );
          
          return OrderConfirmationScreen(order: placeholderOrder);
        },
      ),
      
      // Settings Routes
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      
      // Diagnostic Route (for testing Supabase connection)
      GoRoute(
        path: '/diagnostics',
        builder: (context, state) => const SupabaseDiagnosticScreen(),
      ),
      
      // Admin Routes
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: '/admin/payments',
        builder: (context, state) => const AdminPaymentsScreen(),
      ),
      GoRoute(
        path: '/admin/inventory',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Inventory Management'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Text('Inventory Management - Coming Soon'),
          ),
        ),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Analytics'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Text('Analytics Dashboard - Coming Soon'),
          ),
        ),
      ),
      
      // Redirect root to stores
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.stores,
      ),
    ],
  );
}