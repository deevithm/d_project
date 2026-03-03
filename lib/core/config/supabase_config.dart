/// Supabase Configuration for Snackly App
/// This file contains all Supabase-related configuration
class SupabaseConfig {
  // Supabase Project Credentials
  static const String supabaseUrl = 'https://kojaaeqjupvnpuorcuno.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtvamFhZXFqdXB2bnB1b3JjdW5vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzMTQ5MTMsImV4cCI6MjA3Nzg5MDkxM30.ZQsBHi-mxNR8N566nCnJzi6577K4Oo7Tpf-4l-4pUFg';
  
  // Database Tables
  static const String usersTable = 'users';
  static const String storesTable = 'stores';
  static const String productsTable = 'products';
  static const String storeProductsTable = 'store_products';
  static const String ordersTable = 'orders';
  static const String orderItemsTable = 'order_items';
  static const String favoritesTable = 'favorites';
  static const String mlPredictionsTable = 'ml_predictions';
  
  // Storage Buckets
  static const String productImagesBucket = 'product-images';
  static const String storeImagesBucket = 'store-images';
  static const String userAvatarsBucket = 'user-avatars';
  
  // Realtime Channels
  static const String ordersChannel = 'orders';
  static const String inventoryChannel = 'inventory';
  static const String notificationsChannel = 'notifications';
  
  // App Settings
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration cacheExpiry = Duration(hours: 6);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
