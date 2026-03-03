import 'package:flutter/material.dart';
import 'package:snackly/shared/services/supabase_service.dart';
import 'package:snackly/shared/repositories/supabase_repository.dart';
import 'package:snackly/core/constants.dart';

/// Diagnostic screen to test Supabase connection
class SupabaseDiagnosticScreen extends StatefulWidget {
  const SupabaseDiagnosticScreen({super.key});

  @override
  State<SupabaseDiagnosticScreen> createState() => _SupabaseDiagnosticScreenState();
}

class _SupabaseDiagnosticScreenState extends State<SupabaseDiagnosticScreen> {
  final List<DiagnosticResult> _results = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isRunning = true;
      _results.clear();
    });

    // Test 1: Supabase Service Initialization
    await _addTest(
      'Supabase Service Initialization',
      () async {
        final supabase = SupabaseService();
        if (!supabase.isInitialized) {
          await supabase.initialize();
        }
        return supabase.isInitialized;
      },
    );

    // Test 2: Database Connection
    await _addTest(
      'Database Connection (Stores Table)',
      () async {
        final storeRepo = StoreRepository();
        final stores = await storeRepo.getAllStores();
        return stores.isNotEmpty;
      },
    );

    // Test 3: Auth Service
    await _addTest(
      'Auth Service Access',
      () async {
        final supabase = SupabaseService();
        return supabase.client.auth.currentUser == null; // No user logged in is ok
      },
    );

    // Test 4: Product Repository
    await _addTest(
      'Product Repository',
      () async {
        final productRepo = ProductRepository();
        final products = await productRepo.getAllProducts();
        return products.isNotEmpty;
      },
    );

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _addTest(String name, Future<bool> Function() test) async {
    try {
      final result = await test();
      setState(() {
        _results.add(DiagnosticResult(
          name: name,
          success: result,
          message: result ? 'Success' : 'Test returned false',
        ));
      });
    } catch (e) {
      setState(() {
        _results.add(DiagnosticResult(
          name: name,
          success: false,
          message: e.toString(),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final passedTests = _results.where((r) => r.success).length;
    final totalTests = _results.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Supabase Diagnostics'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Column(
              children: [
                Icon(
                  _isRunning
                      ? Icons.sync
                      : passedTests == totalTests
                          ? Icons.check_circle
                          : Icons.error,
                  size: 64,
                  color: _isRunning
                      ? AppColors.primary
                      : passedTests == totalTests
                          ? AppColors.success
                          : AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _isRunning
                      ? 'Running Tests...'
                      : passedTests == totalTests
                          ? 'All Tests Passed!'
                          : 'Some Tests Failed',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$passedTests / $totalTests tests passed',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      result.success ? Icons.check_circle : Icons.error,
                      color: result.success ? AppColors.success : AppColors.error,
                    ),
                    title: Text(
                      result.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      result.message,
                      style: TextStyle(
                        color: result.success ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _isRunning ? null : _runDiagnostics,
              icon: const Icon(Icons.refresh),
              label: const Text('Run Tests Again'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiagnosticResult {
  final String name;
  final bool success;
  final String message;

  DiagnosticResult({
    required this.name,
    required this.success,
    required this.message,
  });
}
