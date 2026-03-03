import '../constants.dart';

class Product {
  final String id;
  final String name;
  final ProductCategory category;
  final String imageUrl;
  final double basePrice;
  final double cost;
  final int? expiryDays;
  final List<String> nutritionTags;
  final String description;
  final bool isPerishable;
  final double? price;  // Store-specific price (can be different from basePrice)
  final double? discount;  // Store-specific discount
  
  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.basePrice,
    required this.cost,
    this.expiryDays,
    this.nutritionTags = const [],
    this.description = '',
    this.isPerishable = false,
    this.price,
    this.discount,
  });
  
  // Get the effective price (store price if available, otherwise base price)
  double get effectivePrice => price ?? basePrice;
  
  // Get the final price after discount
  double get finalPrice {
    if (discount != null && discount! > 0) {
      return effectivePrice * (1 - discount! / 100);
    }
    return effectivePrice;
  }
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: _parseCategory(json['category']),
      imageUrl: json['image_url'] ?? '',
      basePrice: (json['base_price'] ?? json['price_base'] ?? 0.0).toDouble(),
      cost: (json['cost'] ?? 0.0).toDouble(),
      expiryDays: json['expiry_days'],
      nutritionTags: _parseNutritionTags(json),
      description: json['description'] ?? '',
      isPerishable: json['is_perishable'] ?? false,
      price: json['current_price'] != null 
        ? (json['current_price'] as num).toDouble() 
        : null,
      discount: json['discount'] != null 
        ? (json['discount'] as num).toDouble() 
        : null,
    );
  }
  
  static ProductCategory _parseCategory(dynamic category) {
    if (category == null) return ProductCategory.other;
    
    final categoryStr = category.toString().toLowerCase();
    return ProductCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == categoryStr,
      orElse: () => ProductCategory.other,
    );
  }
  
  static List<String> _parseNutritionTags(Map<String, dynamic> json) {
    // Check for nutrition_tags first
    if (json['nutrition_tags'] != null) {
      return List<String>.from(json['nutrition_tags']);
    }
    
    // Check for nutrition_info and extract tags
    if (json['nutrition_info'] != null && json['nutrition_info'] is Map) {
      final nutritionInfo = json['nutrition_info'] as Map<String, dynamic>;
      return nutritionInfo.keys.toList();
    }
    
    return [];
  }
  
  Product copyWith({
    String? id,
    String? name,
    ProductCategory? category,
    String? imageUrl,
    double? basePrice,
    double? cost,
    int? expiryDays,
    List<String>? nutritionTags,
    String? description,
    bool? isPerishable,
    double? price,
    double? discount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      basePrice: basePrice ?? this.basePrice,
      cost: cost ?? this.cost,
      expiryDays: expiryDays ?? this.expiryDays,
      nutritionTags: nutritionTags ?? this.nutritionTags,
      description: description ?? this.description,
      isPerishable: isPerishable ?? this.isPerishable,
      price: price ?? this.price,
      discount: discount ?? this.discount,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'image_url': imageUrl,
      'price_base': basePrice,
      'cost': cost,
      'expiry_days': expiryDays,
      'nutrition_tags': nutritionTags,
      'description': description,
      'is_perishable': isPerishable,
    };
  }
}