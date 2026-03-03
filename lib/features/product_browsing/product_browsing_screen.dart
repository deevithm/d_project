import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../shared/services/app_state.dart';
import '../../shared/services/product_service.dart';
import '../../core/models/product.dart';
import '../../core/models/order.dart';
import '../../core/constants.dart';
import '../../shared/widgets/loading/shimmer_widget.dart';
import '../../shared/widgets/loading/loading_state_widget.dart';
import '../../shared/widgets/images/product_image_widget.dart';
import '../../shared/widgets/responsive/responsive_layout.dart';
import '../../shared/utils/accessibility_helper.dart';

class ProductBrowsingScreen extends StatefulWidget {
  final String storeId;

  const ProductBrowsingScreen({
    super.key,
    required this.storeId,
  });

  @override
  State<ProductBrowsingScreen> createState() => _ProductBrowsingScreenState();
}

class _ProductBrowsingScreenState extends State<ProductBrowsingScreen> {
  ProductCategory? _selectedCategory;
  LoadingState _loadingState = LoadingState.loading;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() async {
    setState(() {
      _loadingState = LoadingState.loading;
    });

    try {
      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Get products for the specific store
      final products = ProductService.instance.getProductsForStore(widget.storeId);
      
      setState(() {
        _products = products;
        _filteredProducts = products;
        _loadingState = LoadingState.loaded;
      });
    } catch (e) {
      setState(() {
        _loadingState = LoadingState.error;
      });
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesCategory = _selectedCategory == null || product.category == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty || 
                             product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                             product.description.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilters(),
            Expanded(
              child: _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ResponsiveContainer(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // Navigate back to store selection
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.stores);
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.textPrimary,
                  tooltip: 'Back to stores',
                ),
                SizedBox(width: ResponsiveSpacing.getSpacing(context, mobile: 8, tablet: 12, desktop: 16)),
                Expanded(
                  child: Consumer<AppState>(
                    builder: (context, appState, child) {
                      return ResponsiveText(
                        text: appState.selectedStore?.storeName ?? 'Grocery Store',
                        mobileSize: 20,
                        tabletSize: 22,
                        desktopSize: 24,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/cart/${widget.storeId}'),
                  icon: Stack(
                    children: [
                      Icon(
                        MdiIcons.shoppingOutline,
                        color: AppColors.textPrimary,
                      ),
                      Consumer<AppState>(
                        builder: (context, appState, child) {
                          final itemCount = appState.cartItems.length;
                          if (itemCount == 0) return const SizedBox.shrink();
                          
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                itemCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return ResponsiveContainer(
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _filterProducts();
            },
          ),
          SizedBox(height: ResponsiveSpacing.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          
          // Category Filter
          SizedBox(
            height: ResponsiveSpacing.getSpacing(context, mobile: 50, tablet: 55, desktop: 60),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('All', null),
                SizedBox(width: ResponsiveSpacing.getSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                ...ProductCategory.values.map((category) => Padding(
                  padding: EdgeInsets.only(right: ResponsiveSpacing.getSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                  child: _buildCategoryChip(
                    category.name.toUpperCase(),
                    category,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, ProductCategory? category) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
        _filterProducts();
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildProductGrid() {
    return LoadingStateWidget(
      state: _loadingState,
      onRetry: _loadProducts,
      loadingWidget: ResponsiveGrid(
        mobileColumns: 2,
        tabletColumns: 3, 
        desktopColumns: 4,
        childAspectRatio: ResponsiveBreakpoints.isMobile(context) ? 0.78 : 0.85,
        crossAxisSpacing: ResponsiveSpacing.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
        mainAxisSpacing: ResponsiveSpacing.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
        padding: ResponsiveBreakpoints.getResponsivePadding(context),
        children: List.generate(6, (index) => const ShimmerWidget(child: Card())),
      ),
      child: _filteredProducts.isEmpty 
        ? _buildEmptyState()
        : ResponsiveGrid(
            mobileColumns: 2,
            tabletColumns: 3,
            desktopColumns: 4,
            childAspectRatio: ResponsiveBreakpoints.isMobile(context) ? 0.78 : 0.85,
            crossAxisSpacing: ResponsiveSpacing.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
            mainAxisSpacing: ResponsiveSpacing.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
            padding: ResponsiveBreakpoints.getResponsivePadding(context),
            // Product Grid with optimized rebuilds
            children: _filteredProducts.map((product) => 
              KeyedSubtree(
                key: ValueKey(product.id), // Avoid unnecessary rebuilds
                child: _buildProductCard(product),
              ),
            ).toList(),
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.packageVariant,
            size: ResponsiveSpacing.getSpacing(context, mobile: 64, tablet: 72, desktop: 80),
            color: Colors.grey[400],
          ),
          SizedBox(height: ResponsiveSpacing.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          ResponsiveText(
            text: 'No products found',
            mobileSize: 18,
            tabletSize: 20,
            desktopSize: 22,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: ResponsiveSpacing.getSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
          ResponsiveText(
            text: 'Try adjusting your search or filters',
            mobileSize: 14,
            tabletSize: 15,
            desktopSize: 16,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final cardPadding = ResponsiveSpacing.getSpacing(context, mobile: 4, tablet: 6, desktop: 8);
    final buttonHeight = ResponsiveSpacing.getSpacing(context, mobile: 24, tablet: 26, desktop: 28);
    
    return RepaintBoundary( // Optimize repaints
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Debug button tap
            debugPrint('🔍 Product card tapped: ${product.name}');
            // Add haptic feedback
            HapticFeedback.lightImpact();
            context.push('/product/${product.id}');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image - Flexible but with constraints
              Expanded(
                flex: 3, // 60% of available space
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Stack(
                    children: [
                      // Main image container
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[200],
                          child: ProductImageWidget(
                            imageUrl: product.imageUrl,
                            productName: product.name,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      
                      // Quick add button overlay (top-right)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                debugPrint('🛒 Quick add button tapped for: ${product.name}');
                                HapticFeedback.mediumImpact();
                                _addToCart(product);
                              },
                              child: Icon(
                                Icons.add_shopping_cart_outlined,
                                color: AppColors.primary,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
              // Product Details - Fixed proportion but with intrinsic height
              Expanded(
                flex: 2, // 40% of available space
                child: Padding(
                  padding: EdgeInsets.all(cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Info - Takes available space
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ResponsiveText(
                              text: product.name,
                              mobileSize: 9,
                              tabletSize: 10,
                              desktopSize: 11,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            ResponsiveText(
                              text: '₹${product.basePrice.toStringAsFixed(0)}',
                              mobileSize: 11,
                              tabletSize: 12,
                              desktopSize: 13,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Add to Cart Button - Fixed at bottom with exact height
                      SizedBox(
                        height: buttonHeight,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            debugPrint('🛒 Add to Cart button pressed for: ${product.name}');
                            HapticFeedback.mediumImpact();
                            _addToCart(product);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            minimumSize: Size(0, buttonHeight),
                            maximumSize: Size(double.infinity, buttonHeight),
                          ),
                          child: ResponsiveText(
                            text: 'Add to Cart',
                            mobileSize: 8,
                            tabletSize: 9,
                            desktopSize: 10,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    try {
      debugPrint('🛒 Adding product to cart: ${product.name} - ₹${product.basePrice}');
      
      final appState = context.read<AppState>();
      
      // Create cart item with store-specific pricing
      final cartItem = CartItem(
        product: product,
        quantity: 1,
        currentPrice: product.basePrice,
      );
      
      appState.addToCart(cartItem);
      
      debugPrint('✅ Product added successfully to cart. Total items: ${appState.cartItems.length}');
      
      // Show enhanced success message with haptic feedback
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${product.name} added to cart',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '₹${product.basePrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              debugPrint('🛒 Navigating to cart from snackbar');
              final selectedStore = Provider.of<AppState>(context, listen: false).selectedStore;
              if (selectedStore != null) {
                context.push('/cart/${selectedStore.id}');
              }
            },
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error adding product to cart: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Failed to add item to cart. Please try again.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}