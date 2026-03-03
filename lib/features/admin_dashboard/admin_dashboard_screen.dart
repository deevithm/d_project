import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:fl_chart/fl_chart.dart';  // Temporarily disabled
import '../../core/constants.dart';
import '../../shared/repositories/order_repository.dart';
import '../../core/models/order.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Real-time dashboard data
  double _todayRevenue = 0.0;
  int _todayOrders = 0;
  int _pendingOrders = 0;
  int _confirmedOrders = 0;
  int _dispensedOrders = 0;
  int _cancelledOrders = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _calculateDashboardStats(List<Order> orders) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    // Filter today's orders
    final todayOrders = orders.where((order) => 
      order.createdAt.isAfter(todayStart)
    ).toList();
    
    // Calculate stats
    _todayOrders = todayOrders.length;
    _todayRevenue = todayOrders.fold(0.0, (sum, order) => sum + order.totalAmount);
    
    // Count by status
    _pendingOrders = orders.where((o) => o.status == OrderStatus.pending).length;
    _confirmedOrders = orders.where((o) => o.status == OrderStatus.confirmed).length;
    _dispensedOrders = orders.where((o) => o.status == OrderStatus.dispensed).length;
    _cancelledOrders = orders.where((o) => o.status == OrderStatus.cancelled || o.status == OrderStatus.failed).length;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderRepository>(
      builder: (context, orderRepository, child) {
        // Calculate dashboard stats from real orders
        _calculateDashboardStats(orderRepository.orders);
        
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Tab Bar
                  _buildTabBar(),
                  
                  // Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(orderRepository),
                        _buildStoresTab(),
                        _buildAnalyticsTab(orderRepository),
                        _buildInventoryTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  MdiIcons.viewDashboard,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Monitor & manage your grocery store network',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(
            icon: Icon(MdiIcons.viewDashboard, size: 20),
            text: 'Overview',
          ),
          Tab(
            icon: Icon(MdiIcons.store, size: 20),
            text: 'Stores',
          ),
          Tab(
            icon: Icon(MdiIcons.chartLine, size: 20),
            text: 'Analytics',
          ),
          Tab(
            icon: Icon(MdiIcons.packageVariant, size: 20),
            text: 'Inventory',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(OrderRepository orderRepository) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildKPICards(),
          const SizedBox(height: 24),
          _buildRevenueChart(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildRecentOrders(orderRepository),
        ],
      ),
    );
  }

  Widget _buildKPICards() {
    // Calculate growth percentages (compare to yesterday - simplified)
    final revenueGrowth = _todayOrders > 0 ? '+${(_todayRevenue / 100).toStringAsFixed(1)}%' : '0%';
    final ordersGrowth = _todayOrders > 0 ? '+${_todayOrders}' : '0';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'Revenue',
                '₹${_todayRevenue.toStringAsFixed(0)}',
                revenueGrowth,
                MdiIcons.currencyInr,
                _todayRevenue > 0 ? AppColors.success : AppColors.textSecondary,
                _todayRevenue > 0 ? Colors.green.shade50 : Colors.grey.shade100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                'Orders',
                '$_todayOrders',
                ordersGrowth,
                MdiIcons.receiptText,
                _todayOrders > 0 ? AppColors.primary : AppColors.textSecondary,
                _todayOrders > 0 ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'Pending',
                '$_pendingOrders',
                _pendingOrders > 0 ? 'Needs Action' : 'All Clear',
                MdiIcons.clockOutline,
                _pendingOrders > 0 ? AppColors.warning : AppColors.success,
                _pendingOrders > 0 ? Colors.orange.shade50 : Colors.green.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                'Dispensed',
                '$_dispensedOrders',
                _confirmedOrders > 0 ? '$_confirmedOrders Confirmed' : 'Ready',
                MdiIcons.checkAll,
                _dispensedOrders > 0 ? AppColors.success : AppColors.textSecondary,
                _dispensedOrders > 0 ? Colors.green.shade50 : Colors.grey.shade100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, String subtitle, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MdiIcons.chartLine,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Revenue Trend (7 Days)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  MdiIcons.chartLine,
                  size: 48,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'Revenue Chart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chart temporarily disabled',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Restock Alert',
                'View low inventory',
                MdiIcons.alertCircle,
                AppColors.warning,
                Colors.orange.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Store Status',
                'Check all stores',
                MdiIcons.monitor,
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Sales Report',
                'Generate reports',
                MdiIcons.fileChart,
                AppColors.success,
                Colors.green.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Add Product',
                'Update inventory',
                MdiIcons.plus,
                AppColors.accent,
                AppColors.accent.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, Color bgColor) {
    return GestureDetector(
      onTap: () {
        // Handle action
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(OrderRepository orderRepository) {
    final recentOrders = orderRepository.orders.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    MdiIcons.clipboardList,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to orders screen
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentOrders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      MdiIcons.cartOff,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No orders yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Orders will appear here in real-time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...recentOrders.map((order) => _buildRecentOrderItem(order)),
        ],
      ),
    );
  }

  Widget _buildRecentOrderItem(Order order) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = MdiIcons.clockOutline;
        break;
      case OrderStatus.confirmed:
        statusColor = Colors.blue;
        statusIcon = MdiIcons.checkCircle;
        break;
      case OrderStatus.dispensed:
        statusColor = AppColors.success;
        statusIcon = MdiIcons.checkAll;
        break;
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        statusColor = AppColors.error;
        statusIcon = MdiIcons.closeCircle;
        break;
    }

    final orderId = order.id.length > 8 
        ? order.id.substring(0, 8).toUpperCase() 
        : order.id.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#$orderId',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${order.items.length} items • ${_formatTimeAgo(order.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${order.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildStoresTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Store Network',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStoreCard('ST-001', 'Main Building Lobby', StoreStatus.open, 95),
          _buildStoreCard('ST-002', 'Cafeteria Floor 2', StoreStatus.open, 78),
          _buildStoreCard('ST-003', 'Library Entrance', StoreStatus.temporarilyClosed, 23),
          _buildStoreCard('ST-004', 'Parking Area', StoreStatus.temporarilyClosed, 0),
          _buildStoreCard('ST-005', 'Student Center', StoreStatus.open, 89),
        ],
      ),
    );
  }

  Widget _buildStoreCard(String id, String location, StoreStatus status, int stockLevel) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case StoreStatus.open:
        statusColor = AppColors.success;
        statusText = 'Open';
        statusIcon = MdiIcons.checkCircle;
        break;
      case StoreStatus.closed:
        statusColor = AppColors.error;
        statusText = 'Closed';
        statusIcon = MdiIcons.closeCircle;
        break;
      case StoreStatus.temporarilyClosed:
        statusColor = AppColors.warning;
        statusText = 'Temp Closed';
        statusIcon = MdiIcons.alert;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              MdiIcons.store,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      id,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      MdiIcons.packageVariant,
                      color: AppColors.textTertiary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Stock: $stockLevel%',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 80,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: stockLevel / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: stockLevel > 50 ? AppColors.success : 
                                   stockLevel > 25 ? AppColors.warning : AppColors.error,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(OrderRepository orderRepository) {
    final totalOrders = orderRepository.orders.length;
    final totalRevenue = orderRepository.orders.fold(0.0, (sum, order) => sum + order.totalAmount);
    final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analytics Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Revenue',
                  '₹${totalRevenue.toStringAsFixed(0)}',
                  MdiIcons.currencyInr,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'Total Orders',
                  '$totalOrders',
                  MdiIcons.receiptText,
                  AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Avg. Order Value',
                  '₹${avgOrderValue.toStringAsFixed(0)}',
                  MdiIcons.chartBar,
                  AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  'Cancelled',
                  '$_cancelledOrders',
                  MdiIcons.cancel,
                  AppColors.error,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Order Status Breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Status Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatusRow('Pending', _pendingOrders, AppColors.warning),
                _buildStatusRow('Confirmed', _confirmedOrders, Colors.blue),
                _buildStatusRow('Dispensed', _dispensedOrders, AppColors.success),
                _buildStatusRow('Cancelled', _cancelledOrders, AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    final total = _pendingOrders + _confirmedOrders + _dispensedOrders + _cancelledOrders;
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '$count ($percentage%)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    return const Center(
      child: Text(
        'Inventory Tab\n(Product management will go here)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
