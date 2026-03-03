import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/constants.dart';
import '../../core/models/order.dart';
import '../../shared/repositories/order_repository.dart';

// Model class for order with customer details
class OrderWithCustomer {
  final String orderId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final OrderStatus status;
  final double totalAmount;
  final int itemCount;
  final DateTime orderDate;
  final String storeId;
  final String storeName;
  final String paymentMethod;
  final String paymentStatus;

  OrderWithCustomer({
    required this.orderId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.status,
    required this.totalAmount,
    required this.itemCount,
    required this.orderDate,
    required this.storeId,
    required this.storeName,
    required this.paymentMethod,
    required this.paymentStatus,
  });

  OrderWithCustomer copyWith({
    OrderStatus? status,
    String? paymentStatus,
  }) {
    return OrderWithCustomer(
      orderId: orderId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      status: status ?? this.status,
      totalAmount: totalAmount,
      itemCount: itemCount,
      orderDate: orderDate,
      storeId: storeId,
      storeName: storeName,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  OrderRepository? _orderRepository;
  List<OrderWithCustomer> _orders = [];
  bool _isLoading = true;
  int _previousOrderCount = 0;
  bool _isListenerAttached = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Defer loading to after first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeRepository();
    });
  }
  
  void _initializeRepository() {
    if (!_isListenerAttached && mounted) {
      _orderRepository = Provider.of<OrderRepository>(context, listen: false);
      _orderRepository!.addListener(_onOrdersUpdated);
      _isListenerAttached = true;
      _loadOrders();
    }
  }
  
  void _onOrdersUpdated() {
    if (mounted && _orderRepository != null) {
      final updateStartTime = DateTime.now();
      final newOrders = _convertToOrderWithCustomer(_orderRepository!.orders);
      final newOrderCount = newOrders.length;
      
      // Check if new orders were added
      if (newOrderCount > _previousOrderCount && _previousOrderCount > 0) {
        final newOrdersAdded = newOrderCount - _previousOrderCount;
        debugPrint('🆕 $newOrdersAdded new order(s) received!');
        
        // Show notification for new order
        _showNewOrderNotification(newOrdersAdded);
      }
      
      setState(() {
        _orders = newOrders;
        _previousOrderCount = newOrderCount;
        _isLoading = _orderRepository!.isLoading;
      });
      final updateTime = DateTime.now().difference(updateStartTime).inMilliseconds;
      debugPrint('📊 UI updated with ${_orders.length} orders in ${updateTime}ms');
    }
  }
  
  void _showNewOrderNotification(int count) {
    if (!mounted) return;
    
    // Play a visual notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(MdiIcons.bellRing, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              count == 1 
                ? '🆕 New order received!' 
                : '🆕 $count new orders received!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Switch to pending tab
            _tabController.animateTo(0);
          },
        ),
      ),
    );
  }
  
  List<OrderWithCustomer> _convertToOrderWithCustomer(List<Order> orders) {
    return orders.map((order) => OrderWithCustomer(
      orderId: order.id,
      customerName: 'Customer', // Will be fetched from users table
      customerEmail: order.userId ?? 'guest@snackly.com',
      customerPhone: '+91 XXXXXXXXXX',
      status: order.status,
      totalAmount: order.totalAmount,
      itemCount: order.items.length,
      orderDate: order.createdAt,
      storeId: order.storeId,
      storeName: 'Store', // Will be fetched from stores table
      paymentMethod: order.paymentMethod.name.toUpperCase(),
      paymentStatus: order.status == OrderStatus.dispensed ? 'Paid' : 
                     order.status == OrderStatus.failed ? 'Failed' : 'Pending',
    )).toList();
  }

  @override
  void dispose() {
    _orderRepository?.removeListener(_onOrdersUpdated);
    // Don't dispose - the repository is managed by Provider
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (_orderRepository == null) return;
    
    final loadStartTime = DateTime.now();
    setState(() => _isLoading = true);
    
    try {
      debugPrint('🔄 Loading orders from Supabase...');
      
      // Only fetch if no orders yet (real-time will handle updates)
      if (_orderRepository!.orders.isEmpty) {
        final dbStartTime = DateTime.now();
        await _orderRepository!.fetchOrders();
        final dbTime = DateTime.now().difference(dbStartTime).inMilliseconds;
        debugPrint('   ⏱️ Database Query: ${dbTime}ms');
      } else {
        debugPrint('📡 Using real-time data (${_orderRepository!.orders.length} orders)');
      }
      
      if (mounted) {
        final uiStartTime = DateTime.now();
        setState(() {
          _orders = _convertToOrderWithCustomer(_orderRepository!.orders);
          _previousOrderCount = _orders.length;
          _isLoading = false;
        });
        final uiTime = DateTime.now().difference(uiStartTime).inMilliseconds;
        
        final totalTime = DateTime.now().difference(loadStartTime).inMilliseconds;
        debugPrint('✅ Orders loaded successfully:');
        debugPrint('   📊 Total Orders: ${_orders.length}');
        debugPrint('   🖥️ UI Render: ${uiTime}ms');
        debugPrint('   🎯 Total Time: ${totalTime}ms');
      }
    } catch (e) {
      print('❌ Error loading orders: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load orders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<OrderWithCustomer> _getFilteredOrders(OrderStatus? status) {
    if (status == null) return _orders;
    return _orders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Orders',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            // Real-time indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(MdiIcons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Refresh Orders',
          ),
          IconButton(
            icon: Icon(MdiIcons.filterVariant),
            onPressed: () {
              // TODO: Show filter options
            },
            tooltip: 'Filter Orders',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Pending (${_getFilteredOrders(OrderStatus.pending).length})'),
            Tab(text: 'Confirmed (${_getFilteredOrders(OrderStatus.confirmed).length})'),
            Tab(text: 'Dispensed (${_getFilteredOrders(OrderStatus.dispensed).length})'),
            Tab(text: 'All (${_orders.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_getFilteredOrders(OrderStatus.pending)),
                _buildOrderList(_getFilteredOrders(OrderStatus.confirmed)),
                _buildOrderList(_getFilteredOrders(OrderStatus.dispensed)),
                _buildOrderList(_orders),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<OrderWithCustomer> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.clipboardTextOutline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderWithCustomer order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.customerName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),
              
              const Divider(height: 24),
              
              // Order Info
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      MdiIcons.storeOutline,
                      order.storeName,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      MdiIcons.clockOutline,
                      _formatTime(order.orderDate),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      MdiIcons.cartOutline,
                      '${order.itemCount} items',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      MdiIcons.creditCardOutline,
                      order.paymentMethod,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor(order.paymentStatus).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getPaymentStatusColor(order.paymentStatus),
                      ),
                    ),
                    child: Text(
                      order.paymentStatus,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getPaymentStatusColor(order.paymentStatus),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Action Buttons
              if (order.status == OrderStatus.pending || order.status == OrderStatus.confirmed)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _updateOrderStatus(order, OrderStatus.cancelled),
                          icon: Icon(MdiIcons.closeCircleOutline, size: 18),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => _updateOrderStatus(
                            order,
                            order.status == OrderStatus.pending
                                ? OrderStatus.confirmed
                                : OrderStatus.dispensed,
                          ),
                          icon: Icon(MdiIcons.checkCircleOutline, size: 18),
                          label: Text(
                            order.status == OrderStatus.pending
                                ? 'Confirm Order'
                                : 'Mark Dispensed',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        icon = MdiIcons.clockOutline;
        text = 'Pending';
        break;
      case OrderStatus.confirmed:
        color = Colors.blue;
        icon = MdiIcons.checkCircle;
        text = 'Confirmed';
        break;
      case OrderStatus.dispensed:
        color = AppColors.success;
        icon = MdiIcons.checkAll;
        text = 'Dispensed';
        break;
      case OrderStatus.failed:
        color = AppColors.error;
        icon = MdiIcons.alertCircle;
        text = 'Failed';
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        icon = MdiIcons.closeCircle;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'refunded':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
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

  void _showOrderDetails(OrderWithCustomer order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Order ID', order.orderId),
                    _buildDetailRow('Customer', order.customerName),
                    _buildDetailRow('Email', order.customerEmail),
                    _buildDetailRow('Phone', order.customerPhone),
                    _buildDetailRow('Store', order.storeName),
                    _buildDetailRow('Items', '${order.itemCount} items'),
                    _buildDetailRow('Payment Method', order.paymentMethod),
                    _buildDetailRow('Payment Status', order.paymentStatus),
                    _buildDetailRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(2)}'),
                    _buildDetailRow('Order Time', order.orderDate.toString()),
                    const SizedBox(height: 16),
                    const Text(
                      'Order Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Item details would be shown here...'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(OrderWithCustomer order, OrderStatus newStatus) async {
    if (_orderRepository == null) return;
    
    // Capture scaffold messenger before async gap
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Update status in Supabase
    final success = await _orderRepository!.updateOrderStatus(order.orderId, newStatus.name);
    
    if (success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Order ${order.orderId} updated to ${newStatus.name}'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to update order status'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
