  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/models/product.dart';
import '../../core/models/order.dart';
import '../../shared/services/app_state.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/images/product_image_widget.dart';

class FavoriteItem {
  final Product product;
  final DateTime addedDate;
  final String storeId;
  final String storeName;
  final double originalPrice;
  final double? discountedPrice;
  final bool isOnSale;

  FavoriteItem({
    required this.product,
    required this.addedDate,
    required this.storeId,
    required this.storeName,
    required this.originalPrice,
    this.discountedPrice,
    this.isOnSale = false,
  });
}

class RecentlyViewedItem {
  final Product product;
  final DateTime viewedDate;
  final String storeId;
  final String storeName;

  RecentlyViewedItem({
    required this.product,
    required this.viewedDate,
    required this.storeId,
    required this.storeName,
  });
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data - in real app this would come from a service
  List<FavoriteItem> _favoriteItems = [];
  List<RecentlyViewedItem> _recentlyViewed = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // Simulate loading
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _favoriteItems = _getMockFavorites();
          _recentlyViewed = _getMockRecentlyViewed();
          _isLoading = false;
        });
      }
    });
  }

  List<FavoriteItem> _getMockFavorites() {
    return [
      FavoriteItem(
        product: Product(
          id: 'fav_001',
          name: 'Organic Almonds',
          category: ProductCategory.healthyOptions,
          imageUrl: 'https://images.unsplash.com/photo-1508747703725-719777637510?w=400&h=400&fit=crop',
          basePrice: 450.0,
          cost: 350.0,
          description: 'Premium organic almonds - 250g pack',
          nutritionTags: ['Protein Rich', 'Organic', 'Heart Healthy'],
        ),
        addedDate: DateTime.now().subtract(const Duration(days: 2)),
        storeId: 'store_001',
        storeName: 'FreshMart Chennai Central',
        originalPrice: 450.0,
        discountedPrice: 380.0,
        isOnSale: true,
      ),
      FavoriteItem(
        product: Product(
          id: 'fav_002',
          name: 'Greek Yogurt',
          category: ProductCategory.healthyOptions,
          imageUrl: 'https://images.unsplash.com/photo-1571212515416-fd40d0633d85?w=400&h=400&fit=crop',
          basePrice: 85.0,
          cost: 65.0,
          description: 'Thick Greek yogurt - 200g cup',
          nutritionTags: ['High Protein', 'Probiotics', 'Low Sugar'],
        ),
        addedDate: DateTime.now().subtract(const Duration(days: 5)),
        storeId: 'store_002',
        storeName: 'Campus Quick Mart',
        originalPrice: 85.0,
      ),
      FavoriteItem(
        product: Product(
          id: 'fav_003',
          name: 'Organic Quinoa',
          category: ProductCategory.healthyOptions,
          imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&h=400&fit=crop',
          basePrice: 320.0,
          cost: 250.0,
          description: 'Premium organic quinoa - 500g pack',
          nutritionTags: ['Complete Protein', 'Gluten Free', 'Superfood'],
        ),
        addedDate: DateTime.now().subtract(const Duration(days: 1)),
        storeId: 'store_001',
        storeName: 'FreshMart Chennai Central',
        originalPrice: 320.0,
        discountedPrice: 290.0,
        isOnSale: true,
      ),
      FavoriteItem(
        product: Product(
          id: 'fav_004',
          name: 'Dark Chocolate 70%',
          category: ProductCategory.snacks,
          imageUrl: 'https://images.unsplash.com/photo-1511381939415-e44015466834?w=400&h=400&fit=crop',
          basePrice: 280.0,
          cost: 220.0,
          description: 'Premium dark chocolate 70% cocoa - 100g',
          nutritionTags: ['Antioxidants', 'Low Sugar', 'Premium'],
        ),
        addedDate: DateTime.now().subtract(const Duration(days: 7)),
        storeId: 'store_003',
        storeName: 'Express Grocery Hub',
        originalPrice: 280.0,
      ),
    ];
  }

  List<RecentlyViewedItem> _getMockRecentlyViewed() {
    return [
      RecentlyViewedItem(
        product: Product(
          id: 'recent_001',
          name: 'Avocados',
          category: ProductCategory.healthyOptions,
          imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=400&h=400&fit=crop',
          basePrice: 150.0,
          cost: 120.0,
          description: 'Fresh avocados - 2 pieces',
          nutritionTags: ['Healthy Fats', 'Potassium', 'Fiber'],
        ),
        viewedDate: DateTime.now().subtract(const Duration(hours: 2)),
        storeId: 'store_001',
        storeName: 'FreshMart Chennai Central',
      ),
      RecentlyViewedItem(
        product: Product(
          id: 'recent_002',
          name: 'Protein Bars',
          category: ProductCategory.healthyOptions,
          imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
          basePrice: 95.0,
          cost: 75.0,
          description: 'Chocolate protein bar - 60g',
          nutritionTags: ['High Protein', 'Low Sugar', 'Energy'],
        ),
        viewedDate: DateTime.now().subtract(const Duration(hours: 5)),
        storeId: 'store_002',
        storeName: 'Campus Quick Mart',
      ),
      RecentlyViewedItem(
        product: Product(
          id: 'recent_003',
          name: 'Coconut Oil',
          category: ProductCategory.healthyOptions,
          imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&h=400&fit=crop',
          basePrice: 220.0,
          cost: 180.0,
          description: 'Virgin coconut oil - 500ml bottle',
          nutritionTags: ['Natural', 'Healthy Cooking', 'Organic'],
        ),
        viewedDate: DateTime.now().subtract(const Duration(days: 1)),
        storeId: 'store_001',
        storeName: 'FreshMart Chennai Central',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header with Stats
            _buildEnhancedHeader(),
            
            // Tab Bar
            _buildTabBar(),
            
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFavoritesTab(),
                  _buildRecentlyViewedTab(),
                  _buildPriceAlertsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const AppLogo(height: 40, showText: true),
              const Spacer(),
              Icon(
                MdiIcons.heart,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'My Favorites',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Favorites', '${_favoriteItems.length}', MdiIcons.heart),
              _buildStatCard('Recently Viewed', '${_recentlyViewed.length}', MdiIcons.eye),
              _buildStatCard('On Sale', '${_favoriteItems.where((f) => f.isOnSale).length}', MdiIcons.sale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        tabs: [
          Tab(
            icon: Icon(MdiIcons.heart),
            text: 'Favorites',
          ),
          Tab(
            icon: Icon(MdiIcons.clockOutline),
            text: 'Recently Viewed',
          ),
          Tab(
            icon: Icon(MdiIcons.bellAlert),
            text: 'Price Alerts',
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (_isLoading) {
      return _buildLoadingGrid();
    }

    if (_favoriteItems.isEmpty) {
      return _buildEmptyFavorites();
    }

    return Column(
      children: [
        // Quick Actions
        _buildQuickActions(),
        
        // Favorites Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _favoriteItems.length,
            itemBuilder: (context, index) {
              return _buildEnhancedFavoriteCard(_favoriteItems[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionButton(
            'Sort by Price',
            MdiIcons.sortAscending,
            () => _sortFavorites('price'),
          ),
          _buildQuickActionButton(
            'Filter Deals',
            MdiIcons.tagOutline,
            () => _filterDeals(),
          ),
          _buildQuickActionButton(
            'Add All to Cart',
            MdiIcons.cartPlus,
            () => _addAllToCart(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  // Missing methods for enhanced favorites functionality
  
  Widget _buildRecentlyViewedTab() {
    if (_isLoading) {
      return _buildLoadingGrid();
    }

    if (_recentlyViewed.isEmpty) {
      return _buildEmptyRecentlyViewed();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentlyViewed.length,
      itemBuilder: (context, index) {
        return _buildRecentlyViewedCard(_recentlyViewed[index]);
      },
    );
  }

  Widget _buildPriceAlertsTab() {
    final onSaleItems = _favoriteItems.where((item) => item.isOnSale).toList();
    
    return Column(
      children: [
        // Alert Settings
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(MdiIcons.bellAlert, color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price Drop Alerts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get notified when your favorite items go on sale',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: true,
                onChanged: (value) {},
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
        
        // Current Deals
        if (onSaleItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(MdiIcons.sale, color: AppColors.error),
                const SizedBox(width: 8),
                Text(
                  'Current Deals (${onSaleItems.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: onSaleItems.length,
              itemBuilder: (context, index) {
                return _buildDealCard(onSaleItems[index]);
              },
            ),
          ),
        ] else ...[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.bellAlert,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Active Deals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll notify you when your favorites go on sale!',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.heartOutline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start adding products to your favorites by tapping the heart icon when browsing products.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.stores),
              icon: Icon(MdiIcons.store),
              label: const Text('Browse Stores'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRecentlyViewed() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.clockOutline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No Recently Viewed Items',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Products you view will appear here for quick access.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedFavoriteCard(FavoriteItem favoriteItem) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image with sale badge
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                    ),
                    child: ProductImageWidget(
                      imageUrl: favoriteItem.product.imageUrl,
                      productName: favoriteItem.product.name,
                      category: favoriteItem.product.category.name,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                
                // Sale badge
                if (favoriteItem.isOnSale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'SALE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Remove from favorites button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeFromFavorites(favoriteItem),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        MdiIcons.heart,
                        color: AppColors.error,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Product details
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favoriteItem.product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    favoriteItem.storeName,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (favoriteItem.isOnSale && favoriteItem.discountedPrice != null) ...[
                        Text(
                          '₹${favoriteItem.originalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '₹${favoriteItem.discountedPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ] else ...[
                        Text(
                          '₹${favoriteItem.originalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(favoriteItem.product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyViewedCard(RecentlyViewedItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _addToCart(item.product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  child: ProductImageWidget(
                    imageUrl: item.product.imageUrl,
                    productName: item.product.name,
                    category: item.product.category.name,
                    fit: BoxFit.cover,
                    width: 70,
                    height: 70,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.storeName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimeAgo(item.viewedDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // Price and Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${item.product.basePrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => _addToFavorites(item.product),
                      icon: Icon(
                        MdiIcons.heartOutline,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDealCard(FavoriteItem item) {
    final discount = ((item.originalPrice - (item.discountedPrice ?? item.originalPrice)) / item.originalPrice * 100).round();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppColors.error.withValues(alpha: 0.1),
              AppColors.error.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: ProductImageWidget(
                  imageUrl: item.product.imageUrl,
                  productName: item.product.name,
                  category: item.product.category.name,
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.storeName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$discount% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '₹${item.originalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        '₹${item.discountedPrice!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // Add to Cart Button
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () => _addToCart(item.product),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _sortFavorites(String sortBy) {
    setState(() {
      switch (sortBy) {
        case 'price':
          _favoriteItems.sort((a, b) => (a.discountedPrice ?? a.originalPrice).compareTo(b.discountedPrice ?? b.originalPrice));
          break;
        case 'name':
          _favoriteItems.sort((a, b) => a.product.name.compareTo(b.product.name));
          break;
        case 'date':
          _favoriteItems.sort((a, b) => b.addedDate.compareTo(a.addedDate));
          break;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sorted by $sortBy')),
    );
  }

  void _filterDeals() {
    setState(() {
      // Toggle between showing all and showing only deals
      // In real app, this would filter the favorites list
    });
    
    final onSaleCount = _favoriteItems.where((item) => item.isOnSale).length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Found $onSaleCount items on sale')),
    );
  }

  void _addAllToCart() {
    final appState = Provider.of<AppState>(context, listen: false);
    int addedCount = 0;
    
    for (final favoriteItem in _favoriteItems) {
      final cartItem = CartItem(
        product: favoriteItem.product,
        quantity: 1,
        currentPrice: favoriteItem.discountedPrice ?? favoriteItem.originalPrice,
      );
      appState.addToCart(cartItem);
      addedCount++;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $addedCount items to cart'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _removeFromFavorites(FavoriteItem favoriteItem) {
    setState(() {
      _favoriteItems.remove(favoriteItem);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${favoriteItem.product.name} from favorites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _favoriteItems.add(favoriteItem);
            });
          },
        ),
      ),
    );
  }

  void _addToFavorites(Product product) {
    final newFavorite = FavoriteItem(
      product: product,
      addedDate: DateTime.now(),
      storeId: 'store_001',
      storeName: 'Default Store',
      originalPrice: product.basePrice,
    );
    
    setState(() {
      _favoriteItems.add(newFavorite);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to favorites'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _addToCart(Product product) {
    final appState = Provider.of<AppState>(context, listen: false);
    final cartItem = CartItem(
      product: product,
      quantity: 1,
      currentPrice: product.basePrice,
    );
    appState.addToCart(cartItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to cart'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}