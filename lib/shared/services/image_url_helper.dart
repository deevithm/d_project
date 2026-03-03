/// Helper class for managing product image URLs with fallbacks
class ImageUrlHelper {
  /// Map of product IDs to reliable placeholder images
  static const Map<String, String> _reliableImages = {
    // Dairy
    'fresh_dairy_001': 'https://via.placeholder.com/400x400/F8F9FA/333333?text=Fresh+Milk',
    'fresh_dairy_002': 'https://via.placeholder.com/400x400/E8F5E8/333333?text=Greek+Yogurt',
    'fresh_dairy_003': 'https://via.placeholder.com/400x400/FFF3CD/333333?text=Cheese',
    
    // Snacks
    'fresh_snack_001': 'https://via.placeholder.com/400x400/FFD700/333333?text=Premium+Chips',
    'fresh_snack_002': 'https://via.placeholder.com/400x400/D2B48C/333333?text=Cookies',
    'fresh_snack_003': 'https://via.placeholder.com/400x400/CD853F/FFFFFF?text=Mixed+Nuts',
    'fresh_snack_004': 'https://via.placeholder.com/400x400/F4A460/333333?text=Crackers',
    'fresh_snack_005': 'https://via.placeholder.com/400x400/8B4513/FFFFFF?text=Chocolate',
    
    // Food
    'fresh_food_001': 'https://via.placeholder.com/400x400/228B22/FFFFFF?text=Sandwich',
    'fresh_food_002': 'https://via.placeholder.com/400x400/32CD32/FFFFFF?text=Fresh+Salad',
    'fresh_food_003': 'https://via.placeholder.com/400x400/FF69B4/FFFFFF?text=Mixed+Fruits',
    'fresh_food_004': 'https://via.placeholder.com/400x400/FFB6C1/333333?text=Pasta',
    'fresh_food_005': 'https://via.placeholder.com/400x400/DC143C/FFFFFF?text=Mini+Pizza',
  };
  
  /// Get the best available image URL for a product
  static String getImageUrl(String productId, {String? fallbackSeed}) {
    // Use reliable placeholder images
    if (_reliableImages.containsKey(productId)) {
      return _reliableImages[productId]!;
    }
    
    // Generate a fallback using via.placeholder.com (more reliable than picsum)
    final seed = fallbackSeed ?? productId;
    final color = _getColorForSeed(seed);
    return 'https://via.placeholder.com/400x400/$color/FFFFFF?text=${Uri.encodeComponent(seed)}';
  }
  
  /// Generate a consistent color based on seed
  static String _getColorForSeed(String seed) {
    final colors = ['FF6B35', 'E74C3C', '3498DB', '2ECC71', 'F39C12', '9B59B6', '1ABC9C'];
    final index = seed.hashCode.abs() % colors.length;
    return colors[index];
  }
  
  /// Check if an image URL is an asset
  static bool isAssetImage(String imageUrl) {
    return imageUrl.startsWith('assets/');
  }
  
  /// Check if an image URL is likely to work
  static bool isReliableUrl(String imageUrl) {
    return imageUrl.contains('via.placeholder.com') ||
           imageUrl.contains('picsum.photos/seed/') ||
           imageUrl.startsWith('assets/');
  }
}