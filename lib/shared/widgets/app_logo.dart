import 'package:flutter/material.dart';
import '../../core/constants.dart';

class AppLogo extends StatelessWidget {
  final double? height;
  final Color? color;
  final bool showText;

  const AppLogo({
    super.key,
    this.height,
    this.color,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon
        Container(
          height: height ?? 40,
          width: height ?? 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_grocery_store_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          // App name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Snackly',
                style: TextStyle(
                  fontSize: (height ?? 40) * 0.5,
                  fontWeight: FontWeight.bold,
                  color: color ?? AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Smart Grocery',
                style: TextStyle(
                  fontSize: (height ?? 40) * 0.25,
                  fontWeight: FontWeight.w500,
                  color: (color ?? AppColors.textSecondary).withValues(alpha: 0.7),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class ProductImagePlaceholder extends StatelessWidget {
  final String productName;
  final String category;
  final double? width;
  final double? height;

  const ProductImagePlaceholder({
    super.key,
    required this.productName,
    required this.category,
    this.width,
    this.height,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'beverages':
        return Colors.blue;
      case 'snacks':
        return Colors.orange;
      case 'healthyoptions':
        return Colors.green;
      case 'food':
        return Colors.red;
      case 'other':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'beverages':
        return Icons.local_drink;
      case 'snacks':
        return Icons.cookie;
      case 'healthyoptions':
        return Icons.eco;
      case 'food':
        return Icons.restaurant;
      case 'other':
        return Icons.shopping_bag;
      default:
        return Icons.inventory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(category);
    final categoryIcon = _getCategoryIcon(category);

    return Container(
      width: width ?? 120,
      height: height ?? 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withValues(alpha: 0.8),
            categoryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            categoryIcon,
            color: Colors.white,
            size: (width ?? 120) * 0.3,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              productName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}