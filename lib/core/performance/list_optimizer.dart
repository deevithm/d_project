import 'package:flutter/material.dart';

/// Optimized list view builder with performance enhancements
class OptimizedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Widget? separator;
  
  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.separator,
  });
  
  @override
  Widget build(BuildContext context) {
    if (separator != null) {
      return ListView.separated(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemCount: items.length,
        separatorBuilder: (context, index) => separator!,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            key: ValueKey(index),
            child: itemBuilder(context, items[index], index),
          );
        },
      );
    }
    
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey(index),
          child: itemBuilder(context, items[index], index),
        );
      },
    );
  }
}

/// Optimized grid view builder with performance enhancements
class OptimizedGridView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  
  const OptimizedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  });
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey(index),
          child: itemBuilder(context, items[index], index),
        );
      },
    );
  }
}

/// Lazy loading controller for infinite scrolling
class LazyLoadController extends ScrollController {
  final VoidCallback onLoadMore;
  final double threshold;
  bool _isLoading = false;
  
  LazyLoadController({
    required this.onLoadMore,
    this.threshold = 200.0,
  }) {
    addListener(_scrollListener);
  }
  
  void _scrollListener() {
    if (_isLoading) return;
    
    if (position.pixels >= position.maxScrollExtent - threshold) {
      _isLoading = true;
      onLoadMore();
      Future.delayed(const Duration(milliseconds: 500), () {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    removeListener(_scrollListener);
    super.dispose();
  }
}
