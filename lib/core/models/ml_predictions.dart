class DemandPrediction {
  final String productId;
  final String machineId;
  final DateTime date;
  final double predictedDemand;
  final double selloutProbability;
  final double confidence;
  final Map<String, double> featureImportances;
  final String explanation;
  
  DemandPrediction({
    required this.productId,
    required this.machineId,
    required this.date,
    required this.predictedDemand,
    required this.selloutProbability,
    required this.confidence,
    this.featureImportances = const {},
    this.explanation = '',
  });
  
  factory DemandPrediction.fromJson(Map<String, dynamic> json) {
    return DemandPrediction(
      productId: json['product_id'] ?? '',
      machineId: json['machine_id'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      predictedDemand: (json['predicted_demand'] ?? 0.0).toDouble(),
      selloutProbability: (json['sellout_probability'] ?? 0.0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      featureImportances: Map<String, double>.from(json['feature_importances'] ?? {}),
      explanation: json['explanation'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'machine_id': machineId,
      'date': date.toIso8601String(),
      'predicted_demand': predictedDemand,
      'sellout_probability': selloutProbability,
      'confidence': confidence,
      'feature_importances': featureImportances,
      'explanation': explanation,
    };
  }
  
  bool get highSelloutRisk => selloutProbability > 0.8;
  bool get mediumSelloutRisk => selloutProbability > 0.5 && selloutProbability <= 0.8;
  bool get lowSelloutRisk => selloutProbability <= 0.5;
}

class PricingSuggestion {
  final String productId;
  final String machineId;
  final double currentPrice;
  final double suggestedPrice;
  final double discountPercentage;
  final String reason;
  final double expectedSalesLift;
  final double expectedRevenueDelta;
  final double confidence;
  final DateTime validUntil;
  final bool isAutomaticApprovalSafe;
  
  PricingSuggestion({
    required this.productId,
    required this.machineId,
    required this.currentPrice,
    required this.suggestedPrice,
    required this.discountPercentage,
    required this.reason,
    required this.expectedSalesLift,
    required this.expectedRevenueDelta,
    required this.confidence,
    required this.validUntil,
    this.isAutomaticApprovalSafe = false,
  });
  
  factory PricingSuggestion.fromJson(Map<String, dynamic> json) {
    return PricingSuggestion(
      productId: json['product_id'] ?? '',
      machineId: json['machine_id'] ?? '',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      suggestedPrice: (json['suggested_price'] ?? 0.0).toDouble(),
      discountPercentage: (json['discount_percentage'] ?? 0.0).toDouble(),
      reason: json['reason'] ?? '',
      expectedSalesLift: (json['expected_sales_lift'] ?? 0.0).toDouble(),
      expectedRevenueDelta: (json['expected_revenue_delta'] ?? 0.0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      validUntil: DateTime.parse(json['valid_until'] ?? DateTime.now().add(const Duration(hours: 24)).toIso8601String()),
      isAutomaticApprovalSafe: json['is_automatic_approval_safe'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'machine_id': machineId,
      'current_price': currentPrice,
      'suggested_price': suggestedPrice,
      'discount_percentage': discountPercentage,
      'reason': reason,
      'expected_sales_lift': expectedSalesLift,
      'expected_revenue_delta': expectedRevenueDelta,
      'confidence': confidence,
      'valid_until': validUntil.toIso8601String(),
      'is_automatic_approval_safe': isAutomaticApprovalSafe,
    };
  }
  
  bool get isExpired => DateTime.now().isAfter(validUntil);
  bool get hasPositiveROI => expectedRevenueDelta > 0;
  double get absoluteDiscount => currentPrice - suggestedPrice;
}