import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom image cache manager with optimized settings
class AppImageCacheManager {
  static const key = 'snacklyImageCache';
  
  static CacheManager? _instance;
  
  static CacheManager get instance {
    _instance ??= CacheManager(
      Config(
        key,
        stalePeriod: const Duration(days: 7), // Cache for 7 days
        maxNrOfCacheObjects: 200, // Max 200 images
        repo: JsonCacheInfoRepository(databaseName: key),
        fileService: HttpFileService(),
      ),
    );
    return _instance!;
  }
  
  /// Preload images for better UX
  static Future<void> preloadImages(BuildContext context, List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await precacheImage(NetworkImage(url), context);
      } catch (e) {
        debugPrint('Failed to preload image: $url');
      }
    }
  }
  
  /// Clear all cached images
  static Future<void> clearCache() async {
    await instance.emptyCache();
    debugPrint('🗑️ Image cache cleared');
  }
  
  /// Get cache size
  static Future<int> getCacheSize() async {
    try {
      final files = await instance.getFileFromCache(key);
      return files?.file.lengthSync() ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
