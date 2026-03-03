import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Performance monitoring and optimization utilities
class AppPerformance {
  /// Enable performance debugging overlays
  static void enablePerformanceDebugging() {
    if (kDebugMode) {
      debugPaintSizeEnabled = true;
      debugPaintLayerBordersEnabled = true;
      debugRepaintRainbowEnabled = true;
      debugPrint('🎯 Performance debugging enabled');
    }
  }
  
  /// Disable performance debugging overlays
  static void disablePerformanceDebugging() {
    debugPaintSizeEnabled = false;
    debugPaintLayerBordersEnabled = false;
    debugRepaintRainbowEnabled = false;
    debugPrint('🎯 Performance debugging disabled');
  }
  
  /// Log widget build performance
  static void logBuildPerformance(String widgetName, Function() build) {
    if (!kDebugMode) {
      build();
      return;
    }
    
    final stopwatch = Stopwatch()..start();
    build();
    stopwatch.stop();
    
    if (stopwatch.elapsedMilliseconds > 16) {
      debugPrint('⚠️ Slow build: $widgetName took ${stopwatch.elapsedMilliseconds}ms');
    }
  }
  
  /// Memory optimization hints
  static void printMemoryOptimizationTips() {
    if (kDebugMode) {
      debugPrint('''
      🚀 Memory Optimization Tips:
      1. Use const constructors where possible
      2. Implement RepaintBoundary for complex widgets
      3. Use ListView.builder for large lists
      4. Cache expensive computations
      5. Dispose controllers and streams properly
      6. Use CachedNetworkImage for images
      7. Implement lazy loading for heavy widgets
      ''');
    }
  }
}
