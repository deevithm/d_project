import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../services/app_state.dart';
import '../../core/constants.dart';

/// A floating action button that shows the cart with item count badge.
/// This widget can be used across different screens to provide quick cart access.
class CartFAB extends StatelessWidget {
  final String? storeId;
  final bool mini;
  final bool showWhenEmpty;

  const CartFAB({
    super.key,
    this.storeId,
    this.mini = false,
    this.showWhenEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final itemCount = appState.cartItemCount;
        
        // Hide if cart is empty and showWhenEmpty is false
        if (itemCount == 0 && !showWhenEmpty) {
          return const SizedBox.shrink();
        }

        // Get the current store ID from app state if not provided
        final targetStoreId = storeId ?? appState.selectedStore?.id ?? 'default';

        return Stack(
          clipBehavior: Clip.none,
          children: [
            FloatingActionButton(
              mini: mini,
              heroTag: 'cart_fab_${DateTime.now().millisecondsSinceEpoch}',
              onPressed: () {
                context.push('/cart/$targetStoreId');
              },
              backgroundColor: AppColors.primary,
              elevation: 4,
              child: Icon(
                MdiIcons.shoppingOutline,
                color: Colors.white,
                size: mini ? 20 : 24,
              ),
            ),
            if (itemCount > 0)
              Positioned(
                right: mini ? -4 : -2,
                top: mini ? -4 : -2,
                child: Container(
                  padding: EdgeInsets.all(mini ? 4 : 6),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    minWidth: mini ? 18 : 22,
                    minHeight: mini ? 18 : 22,
                  ),
                  child: Text(
                    itemCount > 99 ? '99+' : itemCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: mini ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// An extended cart FAB with total amount display
class CartFABExtended extends StatelessWidget {
  final String? storeId;

  const CartFABExtended({
    super.key,
    this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final itemCount = appState.cartItemCount;
        final total = appState.cartTotal;

        if (itemCount == 0) {
          return const SizedBox.shrink();
        }

        final targetStoreId = storeId ?? appState.selectedStore?.id ?? 'default';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(28),
            color: AppColors.primary,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () {
                context.push('/cart/$targetStoreId');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          MdiIcons.shoppingOutline,
                          color: Colors.white,
                          size: 24,
                        ),
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              itemCount > 99 ? '99+' : itemCount.toString(),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '₹${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        MdiIcons.arrowRight,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A bottom sheet style cart preview widget
class CartBottomBar extends StatelessWidget {
  final String? storeId;

  const CartBottomBar({
    super.key,
    this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final itemCount = appState.cartItemCount;
        final total = appState.cartTotal;

        if (itemCount == 0) {
          return const SizedBox.shrink();
        }

        final targetStoreId = storeId ?? appState.selectedStore?.id ?? 'default';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Cart Icon with Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        MdiIcons.shoppingOutline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          itemCount > 99 ? '99+' : itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Total Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${total.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // View Cart Button
                ElevatedButton(
                  onPressed: () {
                    context.push('/cart/$targetStoreId');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Cart',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
