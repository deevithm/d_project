import 'package:flutter_test/flutter_test.dart';
import 'package:snackly/shared/services/supabase_service.dart';

/// Simple test to verify Supabase connection
void main() {
  test('Supabase connection test', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    print('\n🔍 Testing Supabase Connection...\n');
    
    try {
      // Initialize Supabase
      print('1️⃣ Initializing Supabase service...');
      final supabase = SupabaseService();
      await supabase.initialize();
      print('   ✅ Supabase initialized successfully');
      
      // Check if client is accessible
      print('\n2️⃣ Checking Supabase client...');
      final client = supabase.client;
      print('   ✅ Client accessible');
      
      // Test database connection with a simple query
      print('\n3️⃣ Testing database connection...');
      final response = await client
          .from('stores')
          .select('id, name')
          .limit(1);
      
      print('   ✅ Database query successful');
      print('   📊 Response: $response');
      
      // Check auth functionality
      print('\n4️⃣ Checking auth service...');
      final currentUser = supabase.currentUser;
      print('   ℹ️ Current user: ${currentUser?.email ?? "Not logged in"}');
      print('   ✅ Auth service accessible');
      
      print('\n✅ ✅ ✅ ALL SUPABASE TESTS PASSED! ✅ ✅ ✅\n');
      print('🎉 Your Supabase connection is working perfectly!\n');
      
      expect(client, isNotNull);
      expect(supabase.isInitialized, isTrue);
      
    } catch (e, stackTrace) {
      print('\n❌ SUPABASE CONNECTION FAILED!\n');
      print('Error: $e\n');
      print('Stack trace:\n$stackTrace\n');
      
      print('🔧 Troubleshooting steps:');
      print('1. Check your internet connection');
      print('2. Verify Supabase URL and API key in lib/core/config/supabase_config.dart');
      print('3. Ensure the stores table exists in your Supabase database');
      print('4. Check Supabase dashboard for any issues\n');
      
      rethrow;
    }
  });
}
