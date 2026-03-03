import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../core/models/user.dart';
import '../../core/models/auth.dart';
import '../../core/constants.dart';
import './supabase_service.dart';

/// Comprehensive authentication service for the grocery store app
/// Now powered by Supabase Authentication with Demo Mode fallback
class AuthService extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';

  final SupabaseService _supabase = SupabaseService();

  User? _currentUser;
  AuthToken? _authToken;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _lastError;
  bool _isDemoUser = false;

  // Getters
  User? get currentUser => _currentUser;
  AuthToken? get authToken => _authToken;
  bool get isAuthenticated => _isAuthenticated && (_authToken != null || _isDemoUser);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  String? get authHeader => _authToken != null ? 'Bearer ${_authToken!.accessToken}' : null;
  bool get isDemoMode => _supabase.isDemoMode || _isDemoUser;

  /// Initialize the auth service and check for existing session
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // If Supabase is in demo mode, check for saved demo user
      if (_supabase.isDemoMode) {
        debugPrint('🎭 Auth running in demo mode');
        await _loadStoredAuth();
        if (_currentUser != null && _authToken != null) {
          _isAuthenticated = true;
          _isDemoUser = true;
          debugPrint('✅ Restored demo user session: ${_currentUser?.email}');
        }
        _setLoading(false);
        return;
      }

      // Check Supabase session - this persists across app restarts
      final session = _supabase.client.auth.currentSession;
      debugPrint('📡 Checking existing Supabase session: ${session != null ? "Found" : "None"}');
      
      if (session != null) {
        debugPrint('✅ Found existing session for: ${session.user.email}');
        await _syncUserFromSupabase(session.user);
      } else {
        // Supabase handles session persistence automatically via FlutterAuthClientOptions
        // Fallback to local stored auth if no Supabase session
        debugPrint('🔄 No active session, checking local storage...');
        await _loadStoredAuth();
        if (_authToken != null && !_authToken!.isExpired && _currentUser != null) {
          _isAuthenticated = true;
          debugPrint('✅ Restored local session: ${_currentUser?.email}');
        } else if (_authToken != null && _authToken!.isExpired) {
          debugPrint('⏰ Token expired, attempting refresh...');
          await _tryRefreshToken();
        }
      }
      
      // Listen to auth state changes
      _supabase.client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        debugPrint('🔐 Auth state changed: $event');
        if (event == supabase.AuthChangeEvent.signedIn) {
          debugPrint('✅ User signed in: ${data.session?.user.email}');
          _syncUserFromSupabase(data.session?.user);
        } else if (event == supabase.AuthChangeEvent.signedOut) {
          debugPrint('👋 User signed out');
          _handleSignOut();
        } else if (event == supabase.AuthChangeEvent.tokenRefreshed) {
          debugPrint('🔄 Token refreshed');
          if (data.session != null) {
            _authToken = AuthToken(
              accessToken: data.session!.accessToken,
              refreshToken: data.session!.refreshToken ?? '',
              expiresAt: DateTime.fromMillisecondsSinceEpoch(data.session!.expiresAt! * 1000),
              issuedAt: DateTime.now(),
            );
            if (_currentUser != null) {
              _saveAuthData(_currentUser!, _authToken!, true);
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      // Don't logout on initialization error - try to continue with cached data
      await _loadStoredAuth();
      if (_currentUser != null && _authToken != null) {
        _isAuthenticated = true;
        debugPrint('✅ Using cached auth data: ${_currentUser?.email}');
      }
    } finally {
      _setLoading(false);
    }
  }
  
  /// Sync user data from Supabase
  Future<void> _syncUserFromSupabase(supabase.User? supabaseUser) async {
    if (supabaseUser == null) return;
    
    try {
      // Small delay to ensure database insert completes
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Fetch user profile from database
      final profile = await _supabase.client
          .from('users')
          .select()
          .eq('id', supabaseUser.id)
          .maybeSingle();
      
      // Create User object
      _currentUser = User(
        id: supabaseUser.id,
        email: supabaseUser.email ?? '',
        name: profile?['full_name'] ?? supabaseUser.userMetadata?['full_name'] ?? '',
        phone: profile?['phone'] ?? '',
        role: _parseUserRole(profile?['role'] ?? 'buyer'),
        paymentMethods: const ['card', 'upi'],
        loyaltyPoints: profile?['loyalty_points'] ?? 0,
        preferences: Map<String, dynamic>.from(profile?['preferences'] ?? {}),
        createdAt: DateTime.parse(profile?['created_at'] ?? DateTime.now().toIso8601String()),
        lastActiveAt: DateTime.now(),
      );
      
      // Create auth token from session
      final session = _supabase.client.auth.currentSession;
      if (session != null) {
        _authToken = AuthToken(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken ?? '',
          expiresAt: DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
          issuedAt: DateTime.now(),
        );
      }
      
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing user from Supabase: $e');
    }
  }
  
  UserRole _parseUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'buyer':
        return UserRole.buyer;
      case 'operator':
        return UserRole.operator;
      case 'admin':
        return UserRole.admin;
      case 'restocker':
        return UserRole.restocker;
      case 'analyst':
        return UserRole.analyst;
      default:
        return UserRole.buyer;
    }
  }
  
  void _handleSignOut() {
    _currentUser = null;
    _authToken = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Login with email and password using Supabase
  Future<AuthResponse> login(LoginRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔐 Starting login process for: ${request.email}');
      
      // Validate input
      if (request.email.isEmpty || request.password.isEmpty) {
        throw Exception('Email and password are required');
      }
      
      if (!request.email.contains('@')) {
        throw Exception('Please enter a valid email address');
      }
      
      if (request.password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Check for demo mode login
      if (_supabase.isDemoMode) {
        return _handleDemoLogin(request);
      }
      
      // Sign in with Supabase
      debugPrint('📧 Calling Supabase signIn...');
      final response = await _supabase.signIn(
        email: request.email,
        password: request.password,
      );
      
      debugPrint('📬 Supabase response - User: ${response.user?.email}, Session: ${response.session != null}');
      
      if (response.user == null || response.session == null) {
        throw Exception('Invalid email or password. Please try again.');
      }
      
      // Create auth token immediately from session
      _authToken = AuthToken(
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken ?? '',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(response.session!.expiresAt! * 1000),
        issuedAt: DateTime.now(),
      );
      
      // Create minimal user immediately for fast login
      _currentUser = User(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: response.user!.userMetadata?['full_name'] ?? response.user!.email?.split('@').first ?? 'User',
        phone: '',
        role: UserRole.buyer,
        paymentMethods: const ['card', 'upi'],
        loyaltyPoints: 0,
        preferences: const {},
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
      
      // Set authenticated immediately
      _isAuthenticated = true;
      notifyListeners();
      
      debugPrint('✅ Login successful! User: ${_currentUser?.email}');
      
      // Sync full user data in background (non-blocking)
      _syncUserFromSupabase(response.user).then((_) {
        debugPrint('📥 Full user profile synced');
      }).catchError((e) {
        debugPrint('⚠️ Background sync failed: $e');
      });
      
      // Always save auth data for session persistence
      if (_currentUser != null && _authToken != null) {
        _saveAuthData(_currentUser!, _authToken!, true);
      }
      return AuthResponse.success(
        token: _authToken!.accessToken,
        user: _currentUser!,
      );
    } on supabase.AuthException catch (e) {
      // Handle Supabase-specific auth errors
      String errorMessage = 'Login failed';
      
      if (e.message.toLowerCase().contains('invalid') || 
          e.message.toLowerCase().contains('credentials')) {
        errorMessage = 'Invalid email or password. Please check your credentials.';
      } else if (e.message.toLowerCase().contains('email not confirmed')) {
        errorMessage = 'Please confirm your email address before logging in.';
      } else if (e.message.toLowerCase().contains('too many requests')) {
        errorMessage = 'Too many login attempts. Please try again later.';
      } else if (e.message.toLowerCase().contains('socket') || 
                 e.message.toLowerCase().contains('host lookup') ||
                 e.message.toLowerCase().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection and try again.';
      } else {
        errorMessage = e.message;
      }
      
      debugPrint('❌ Auth error: ${e.message}');
      _setError(errorMessage);
      return AuthResponse.error(message: errorMessage);
    } catch (e) {
      debugPrint('❌ Login error: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // Handle network errors - offer demo mode
      if (errorMessage.toLowerCase().contains('socket') || 
          errorMessage.toLowerCase().contains('host lookup') ||
          errorMessage.toLowerCase().contains('network') ||
          errorMessage.toLowerCase().contains('failed host')) {
        // Automatically switch to demo mode on network error
        debugPrint('🎭 Network error detected, switching to demo mode...');
        return _handleDemoLogin(LoginRequest(
          email: request.email,
          password: request.password,
          rememberMe: request.rememberMe,
        ));
      }
      
      _setError(errorMessage);
      return AuthResponse.error(message: errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Handle demo mode login
  AuthResponse _handleDemoLogin(LoginRequest request) {
    debugPrint('🎭 Processing demo mode login for: ${request.email}');
    
    // Create demo user
    _currentUser = User(
      id: 'demo-user-001',
      email: request.email,
      name: request.email.split('@').first,
      phone: '+91 9876543210',
      role: UserRole.buyer,
      paymentMethods: const ['card', 'upi'],
      loyaltyPoints: 250,
      preferences: const {},
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
    
    // Create demo auth token
    _authToken = AuthToken(
      accessToken: 'demo-token-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'demo-refresh-token',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      issuedAt: DateTime.now(),
    );
    
    _isAuthenticated = true;
    _isDemoUser = true;
    notifyListeners();
    
    debugPrint('✅ Demo login successful! User: ${_currentUser?.email}');
    debugPrint('🎭 App is now running in DEMO MODE with mock data');
    
    return AuthResponse.success(
      token: _authToken!.accessToken,
      user: _currentUser!,
    );
  }

  /// Register a new user account using Supabase
  Future<AuthResponse> register(RegisterRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('📝 Starting registration for: ${request.email}');
      
      // Validate registration request
      if (!request.isValid) {
        throw Exception('Please fill all required fields correctly');
      }
      
      // Sign up with Supabase
      debugPrint('🔐 Calling Supabase signUp...');
      final response = await _supabase.signUp(
        email: request.email,
        password: request.password,
        userData: {
          'full_name': request.name,
          'phone': request.phone,
        },
      );
      
      debugPrint('📧 Supabase response - User: ${response.user?.email}, Session: ${response.session != null}');
      
      if (response.user == null) {
        throw Exception('Registration failed. Please try again.');
      }
      
      // Check if email confirmation is required
      if (response.session == null) {
        debugPrint('⚠️ Email confirmation required. User created but session is null.');
        // User created but needs email confirmation
        return AuthResponse.error(
          message: 'Account created! Please check your email (${request.email}) to confirm your account. After confirming, you can log in.',
        );
      }
      
      // Session exists - user is auto-logged in
      // Create auth token immediately from session
      _authToken = AuthToken(
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken ?? '',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(response.session!.expiresAt! * 1000),
        issuedAt: DateTime.now(),
      );
      
      // Create minimal user immediately for fast navigation
      _currentUser = User(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: request.name,
        phone: request.phone ?? '',
        role: UserRole.buyer,
        paymentMethods: const ['card', 'upi'],
        loyaltyPoints: 0,
        preferences: const {},
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
      
      // Set authenticated immediately
      _isAuthenticated = true;
      notifyListeners();
      
      debugPrint('✅ Registration successful! User: ${_currentUser?.email}');
      
      // Create user profile in database (non-blocking)
      debugPrint('💾 Creating user profile in database...');
      _supabase.client.from('users').insert({
        'id': response.user!.id,
        'email': request.email,
        'full_name': request.name,
        'phone': request.phone,
        'role': 'buyer',
        'loyalty_points': 0,
        'preferences': {
          'language': 'en',
          'currency': 'INR',
          'notifications': true,
          'darkMode': false,
        },
      }).then((_) {
        debugPrint('✅ User profile created in database');
      }).catchError((e) {
        debugPrint('⚠️ Profile creation in background failed: $e');
      });
      
      return AuthResponse.success(
        token: _authToken!.accessToken,
        user: _currentUser!,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Registration error: $e');
      debugPrint('Stack trace: $stackTrace');
      _setError('Registration failed: ${e.toString()}');
      return AuthResponse.error(message: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      // Sign out from Supabase
      await _supabase.signOut();
    } catch (e) {
      debugPrint('Supabase sign out error: $e');
    }
    
    // Clear local data
    _currentUser = null;
    _authToken = null;
    _isAuthenticated = false;
    
    await _clearStoredAuth();
    notifyListeners();
  }

  /// Refresh the authentication token
  Future<bool> refreshToken() async {
    if (_authToken?.refreshToken == null) return false;

    try {
      // Supabase handles token refresh automatically
      final session = _supabase.client.auth.currentSession;
      if (session != null) {
        _authToken = AuthToken(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken ?? '',
          expiresAt: DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000),
          issuedAt: DateTime.now(),
        );
        
        if (_currentUser != null) {
          await _saveAuthData(_currentUser!, _authToken!, true);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      return false;
    }
  }

  /// Request password reset
  Future<AuthResponse> requestPasswordReset(PasswordResetRequest request) async {
    _setLoading(true);
    try {
      // Mock password reset for development/academic project
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call delay
      
      if (!request.isValid) {
        throw Exception('Please enter a valid email address');
      }
      
      // Simulate successful password reset email
      return AuthResponse.success(
        token: '', // Not needed for password reset
        user: User(
          id: 'temp',
          name: 'temp',
          email: request.email,
          role: UserRole.buyer,
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        ),
      );
    } catch (e) {
      return AuthResponse.error(message: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Change user password
  Future<AuthResponse> changePassword(ChangePasswordRequest request) async {
    if (!isAuthenticated) {
      return AuthResponse.error(message: 'You must be logged in to change password');
    }

    _setLoading(true);
    try {
      // Mock password change for development/academic project
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call delay
      
      if (!request.isValid) {
        throw Exception(request.passwordValidationError ?? 'Invalid password data');
      }
      
      // Simulate successful password change
      return AuthResponse.success(
        token: _authToken!.accessToken,
        user: _currentUser!,
      );
    } catch (e) {
      return AuthResponse.error(message: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<AuthResponse> updateProfile(User updatedUser) async {
    if (!isAuthenticated) {
      return AuthResponse.error(message: 'You must be logged in to update profile');
    }

    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = updatedUser;
      await _saveAuthData(_currentUser!, _authToken!, true);
      
      return AuthResponse.success(
        token: _authToken!.accessToken,
        user: _currentUser!,
      );
    } catch (e) {
      return AuthResponse.error(message: 'Failed to update profile');
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _lastError = error;
    notifyListeners();
  }

  void _clearError() {
    _lastError = null;
  }

  Future<void> _loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    final tokenJson = prefs.getString(_tokenKey);

    if (userJson != null && tokenJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      _authToken = AuthToken.fromJson(jsonDecode(tokenJson));
      _isAuthenticated = true;
    }
  }

  Future<void> _saveAuthData(User user, AuthToken token, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setString(_tokenKey, jsonEncode(token.toJson()));
    await prefs.setBool(_rememberMeKey, rememberMe);
  }

  Future<void> _clearStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_rememberMeKey);
  }

  Future<bool> _tryRefreshToken() async {
    if (_authToken?.refreshToken != null) {
      return await refreshToken();
    }
    return false;
  }

  Future<void> loginWithPhone(String phoneNumber) async {}
}