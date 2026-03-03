import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants.dart';

/// Helper class for managing product images with fallbacks
class ProductImageWidget extends StatelessWidget {
  final String imageUrl;
  final String? productName;
  final String? category;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool showShadow;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.productName,
    this.category,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: showShadow
          ? BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    // If it's a local asset path
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    // If it's a network URL
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildFallback(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.border,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(),
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            if (productName != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  productName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    if (category == null) return MdiIcons.packageVariant;

    final cat = category!.toLowerCase();
    if (cat.contains('beverage') || cat.contains('drink')) {
      return MdiIcons.cupOutline;
    } else if (cat.contains('snack') || cat.contains('chip')) {
      return MdiIcons.foodVariant;
    } else if (cat.contains('candy') || cat.contains('chocolate')) {
      return MdiIcons.candy;
    } else if (cat.contains('fruit') || cat.contains('vegetable')) {
      return MdiIcons.foodApple;
    } else if (cat.contains('dairy') || cat.contains('milk')) {
      return MdiIcons.bottleSoda;
    } else if (cat.contains('bakery') || cat.contains('bread')) {
      return MdiIcons.baguette;
    } else if (cat.contains('frozen')) {
      return MdiIcons.snowflake;
    } else if (cat.contains('meat') || cat.contains('seafood')) {
      return MdiIcons.foodDrumstick;
    }

    return MdiIcons.packageVariant;
  }
}
