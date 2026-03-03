import 'package:flutter/material.dart';

/// Custom shimmer effect widget for loading states
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.period,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.colorScheme.surface;
    final highlightColor = widget.highlightColor ?? 
        theme.colorScheme.onSurface.withValues(alpha: 0.1);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton container for shimmer effects
class SkeletonContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Pre-built shimmer loading widgets
class ShimmerLoading {
  /// Product card skeleton loader
  static Widget productCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ShimmerWidget(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonContainer(
                height: 120,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              const SizedBox(height: 12),
              const SkeletonContainer(
                height: 16,
                width: double.infinity,
              ),
              const SizedBox(height: 8),
              const SkeletonContainer(
                height: 14,
                width: 100,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkeletonContainer(
                    height: 20,
                    width: 80,
                  ),
                  SkeletonContainer(
                    height: 36,
                    width: 36,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Store card skeleton loader
  static Widget storeCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ShimmerWidget(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonContainer(
                    height: 60,
                    width: 60,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonContainer(
                          height: 18,
                          width: double.infinity,
                        ),
                        SizedBox(height: 8),
                        SkeletonContainer(
                          height: 14,
                          width: 120,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SkeletonContainer(
                height: 12,
                width: double.infinity,
              ),
              const SizedBox(height: 8),
              const SkeletonContainer(
                height: 12,
                width: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Order item skeleton loader
  static Widget orderItem() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ShimmerWidget(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkeletonContainer(
                    height: 16,
                    width: 120,
                  ),
                  SkeletonContainer(
                    height: 24,
                    width: 80,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const SkeletonContainer(
                height: 14,
                width: double.infinity,
              ),
              const SizedBox(height: 8),
              const SkeletonContainer(
                height: 14,
                width: 180,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkeletonContainer(
                    height: 14,
                    width: 100,
                  ),
                  const SkeletonContainer(
                    height: 18,
                    width: 80,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// List tile skeleton loader
  static Widget listTile() {
    return ShimmerWidget(
      child: ListTile(
        leading: SkeletonContainer(
          height: 40,
          width: 40,
          borderRadius: BorderRadius.circular(20),
        ),
        title: const SkeletonContainer(
          height: 16,
          width: double.infinity,
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: SkeletonContainer(
            height: 14,
            width: 200,
          ),
        ),
        trailing: const SkeletonContainer(
          height: 24,
          width: 60,
        ),
      ),
    );
  }
}