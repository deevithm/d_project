import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

/// ML Predictions Repository
class MLRepository {
  final SupabaseClient _client = SupabaseService().client;

  /// Get demand predictions for a store
  Future<List<Map<String, dynamic>>> getDemandPredictions(
    String storeId, {
    DateTime? validAfter,
  }) async {
    try {
      final baseQuery = _client
          .from('ml_predictions')
          .select('''
            *,
            product:products(id, name, category),
            store:stores(name)
          ''')
          .eq('store_id', storeId)
          .eq('prediction_type', 'demand');

      final query = validAfter != null
        ? baseQuery.gte('valid_until', validAfter.toIso8601String())
        : baseQuery;

      final response = await query.order('confidence', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch predictions: $e');
    }
  }

  /// Save ML prediction
  Future<void> savePrediction({
    required String storeId,
    required String productId,
    required String predictionType,
    required double predictedValue,
    required double confidence,
    Map<String, dynamic>? factors,
    DateTime? validUntil,
  }) async {
    try {
      await _client.from('ml_predictions').insert({
        'store_id': storeId,
        'product_id': productId,
        'prediction_type': predictionType,
        'predicted_value': predictedValue,
        'confidence': confidence,
        'factors': factors ?? {},
        'valid_until': validUntil?.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save prediction: $e');
    }
  }

  /// Get pricing recommendations
  Future<List<Map<String, dynamic>>> getPricingRecommendations(
    String storeId,
  ) async {
    try {
      final response = await _client
          .from('ml_predictions')
          .select('''
            *,
            product:products(id, name, base_price)
          ''')
          .eq('store_id', storeId)
          .eq('prediction_type', 'pricing')
          .gt('confidence', 0.7)
          .order('confidence', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch pricing recommendations: $e');
    }
  }

  /// Get stock recommendations (for restocking)
  Future<List<Map<String, dynamic>>> getStockRecommendations(
    String storeId,
  ) async {
    try {
      final response = await _client
          .from('ml_predictions')
          .select('''
            *,
            product:products(id, name),
            inventory:store_products!inner(stock, low_stock_threshold)
          ''')
          .eq('store_id', storeId)
          .eq('prediction_type', 'stock')
          .order('predicted_value', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch stock recommendations: $e');
    }
  }

  /// Get trend predictions for all products in a store
  Future<List<Map<String, dynamic>>> getTrendPredictions(
    String storeId,
  ) async {
    try {
      final response = await _client
          .from('ml_predictions')
          .select('''
            *,
            product:products(id, name, category)
          ''')
          .eq('store_id', storeId)
          .eq('prediction_type', 'trend')
          .gt('confidence', 0.6)
          .order('predicted_value', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch trend predictions: $e');
    }
  }

  /// Batch save predictions (for ML model updates)
  Future<void> batchSavePredictions(List<Map<String, dynamic>> predictions) async {
    try {
      await _client.from('ml_predictions').insert(predictions);
    } catch (e) {
      throw Exception('Failed to batch save predictions: $e');
    }
  }

  /// Delete old predictions
  Future<void> deleteOldPredictions({DateTime? before}) async {
    try {
      final cutoffDate = before ?? DateTime.now().subtract(const Duration(days: 7));
      
      await _client
          .from('ml_predictions')
          .delete()
          .lt('valid_until', cutoffDate.toIso8601String());
    } catch (e) {
      throw Exception('Failed to delete old predictions: $e');
    }
  }

  /// Get prediction by ID
  Future<Map<String, dynamic>?> getPredictionById(String predictionId) async {
    try {
      final response = await _client
          .from('ml_predictions')
          .select('''
            *,
            product:products(*),
            store:stores(*)
          ''')
          .eq('id', predictionId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }
}
