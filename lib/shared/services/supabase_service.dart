import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/supabase_config.dart';
import './demo_mode_service.dart';

/// Main Supabase Service for the Snackly App
/// Handles all Supabase initialization and provides access to Supabase client
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  bool _isInitialized = false;
  bool _isDemoMode = false;
  final DemoModeService _demoService = DemoModeService();

  /// Get Supabase client instance
  SupabaseClient get client {
    if (_isDemoMode) {
      throw Exception('Running in demo mode - Supabase is not available');
    }
    if (!_isInitialized || _client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Check if Supabase is initialized
  bool get isInitialized => _isInitialized;

  /// Check if running in demo mode
  bool get isDemoMode => _isDemoMode;

  /// Get current user
  User? get currentUser => _isDemoMode ? null : _client?.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _isDemoMode ? false : currentUser != null;

  /// Initialize Supabase
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('⚠️ Supabase already initialized');
      return;
    }

    try {
      debugPrint('🚀 Initializing Supabase...');
      
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          autoRefreshToken: true,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
        storageOptions: const StorageClientOptions(
          retryAttempts: SupabaseConfig.maxRetries,
        ),
      );

      _client = Supabase.instance.client;
      _isInitialized = true;
      _isDemoMode = false;

      debugPrint('✅ Supabase initialized successfully');
      debugPrint('   URL: ${SupabaseConfig.supabaseUrl}');
      debugPrint('   Auth: ${isAuthenticated ? "Authenticated" : "Not authenticated"}');
      
      // Setup auth state listener
      _setupAuthListener();
      
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize Supabase: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Enable demo mode on failure
      _enableDemoMode();
    }
  }

  /// Enable demo mode when Supabase is unavailable
  void _enableDemoMode() {
    _isDemoMode = true;
    _isInitialized = true; // Mark as initialized so app can proceed
    _demoService.enable();
    debugPrint('🎭 App running in DEMO MODE - using mock data');
    debugPrint('   To use live data, configure a valid Supabase project');
  }

  /// Get demo mode service
  DemoModeService get demoService => _demoService;

  /// Setup authentication state listener
  void _setupAuthListener() {
    client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      
      debugPrint('🔐 Auth state changed: $event');
      
      switch (event) {
        case AuthChangeEvent.signedIn:
          debugPrint('✅ User signed in: ${session?.user.email}');
          break;
        case AuthChangeEvent.signedOut:
          debugPrint('👋 User signed out');
          break;
        case AuthChangeEvent.tokenRefreshed:
          debugPrint('🔄 Token refreshed');
          break;
        case AuthChangeEvent.userUpdated:
          debugPrint('📝 User updated');
          break;
        case AuthChangeEvent.passwordRecovery:
          debugPrint('🔑 Password recovery initiated');
          break;
        default:
          debugPrint('📡 Auth event: $event');
      }
    });
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      
      debugPrint('✅ Sign up successful: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('❌ Sign up failed: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      debugPrint('✅ Sign in successful: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('❌ Sign in failed: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      debugPrint('✅ Sign out successful');
    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
      debugPrint('✅ Password reset email sent to: $email');
    } catch (e) {
      debugPrint('❌ Password reset failed: $e');
      rethrow;
    }
  }

  /// Update user data
  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await client.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: data,
        ),
      );
      
      debugPrint('✅ User updated successfully');
      return response;
    } catch (e) {
      debugPrint('❌ User update failed: $e');
      rethrow;
    }
  }

  /// Get user profile data from users table
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      debugPrint('❌ Failed to get user profile: $e');
      return null;
    }
  }

  /// Create or update user profile
  Future<void> upsertUserProfile(Map<String, dynamic> userData) async {
    try {
      await client
          .from(SupabaseConfig.usersTable)
          .upsert(userData);
      
      debugPrint('✅ User profile upserted successfully');
    } catch (e) {
      debugPrint('❌ Failed to upsert user profile: $e');
      rethrow;
    }
  }

  /// Query database table
  SupabaseQueryBuilder from(String table) {
    return client.from(table);
  }

  /// Subscribe to realtime changes
  RealtimeChannel channel(String channelName) {
    return client.channel(channelName);
  }

  /// Upload file to storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List file,
    FileOptions? fileOptions,
  }) async {
    try {
      await client.storage.from(bucket).uploadBinary(
        path,
        file,
        fileOptions: fileOptions ?? const FileOptions(),
      );
      
      final url = client.storage.from(bucket).getPublicUrl(path);
      debugPrint('✅ File uploaded: $url');
      return url;
    } catch (e) {
      debugPrint('❌ File upload failed: $e');
      rethrow;
    }
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await client.storage.from(bucket).remove([path]);
      debugPrint('✅ File deleted: $path');
    } catch (e) {
      debugPrint('❌ File deletion failed: $e');
      rethrow;
    }
  }

  /// Get public URL for file
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Execute RPC (Remote Procedure Call)
  Future<dynamic> rpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await client.rpc(functionName, params: params);
      debugPrint('✅ RPC executed: $functionName');
      return response;
    } catch (e) {
      debugPrint('❌ RPC failed: $functionName - $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    debugPrint('🧹 Disposing Supabase service');
    // Note: Don't dispose the Supabase client as it's shared globally
  }
}
