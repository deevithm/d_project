import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';  // Temporarily disabled
import '../../shared/services/app_state.dart';
import '../../shared/services/payment_service.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/repositories/order_repository.dart';
import '../../core/models/order.dart';
import '../../core/constants.dart';

class CheckoutScreen extends StatefulWidget {
  final String storeId;

  const CheckoutScreen({
    super.key,
    required this.storeId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with TickerProviderStateMixin {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.upi;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late PaymentService _paymentService;
  OrderRepository? _orderRepository;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get repository from provider
    _orderRepository ??= Provider.of<OrderRepository>(context, listen: false);
  }

  @override
  void dispose() {
    _paymentService.dispose();
    // Don't dispose - the repository is managed by Provider
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            if (appState.cartItems.isEmpty) {
              return _buildEmptyState();
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildOrderSummary(appState),
                          const SizedBox(height: 24),
                          _buildPaymentMethods(),
                          const SizedBox(height: 24),
                          _buildStoreInfo(appState),
                          const SizedBox(height: 24),
                          _buildSecurityInfo(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Payment Button
                  _buildPaymentSection(appState),
                ],
              ),
            );
          },
        ),
      ),
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
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/cart/${widget.storeId}'),
            icon: Icon(
              MdiIcons.arrowLeft,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Secure Checkout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MdiIcons.shieldCheck,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SSL Protected',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 48), // Balance the IconButton
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                MdiIcons.cartOff,
                size: 64,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No items to checkout',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your cart is empty. Add some products first.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/products/${widget.storeId}'),
                icon: Icon(MdiIcons.store),
                label: const Text(
                  'Browse Products',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(AppState appState) {
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  MdiIcons.receipt,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Items List
          ...appState.cartItems.map((item) => _buildOrderItem(item)),
          
          const Divider(height: 24, color: AppColors.border),
          
          // Totals
          _buildSummaryRow('Subtotal', '₹${appState.cartTotal.toInt()}'),
          if (appState.cartSavings > 0)
            _buildSummaryRow('Savings', '-₹${appState.cartSavings.toInt()}', 
                textColor: AppColors.success),
          _buildSummaryRow('Tax (5%)', '₹${(appState.cartTotal * 0.05).toInt()}'),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Total Amount',
            '₹${(appState.cartTotal * 1.05).toInt()}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              MdiIcons.packageVariant,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${item.totalPrice.toInt()}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? textColor, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: textColor ?? (isTotal ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  MdiIcons.creditCard,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Payment Options
          _buildPaymentOption(
            PaymentMethod.upi,
            'UPI Payment',
            'Pay using any UPI app',
            MdiIcons.qrcode,
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            PaymentMethod.card,
            'Credit/Debit Card',
            'Visa, Mastercard, RuPay accepted',
            MdiIcons.creditCard,
            AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            PaymentMethod.wallet,
            'Digital Wallet',
            'PhonePe, Paytm, Google Pay',
            MdiIcons.wallet,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final isSelected = _selectedPaymentMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                MdiIcons.checkCircle,
                color: AppColors.primary,
                size: 24,
              )
            else
              Icon(
                MdiIcons.circle,
                color: AppColors.border,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo(AppState appState) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  MdiIcons.store,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pickup Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (appState.selectedStore != null) ...[
            Row(
              children: [
                Icon(
                  MdiIcons.mapMarker,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appState.selectedStore!.storeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  MdiIcons.identifier,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Store ID: ${widget.storeId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    MdiIcons.informationOutline,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Items will be picked up from this grocery store',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  MdiIcons.shieldCheck,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Secure Payment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSecurityFeature(MdiIcons.lock, 'SSL Encrypted'),
          _buildSecurityFeature(MdiIcons.creditCardScan, 'PCI DSS Compliant'),
          _buildSecurityFeature(MdiIcons.shield, '256-bit Security'),
          _buildSecurityFeature(MdiIcons.bank, 'Bank-grade Protection'),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.success,
            size: 16,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total Amount Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '₹${(appState.cartTotal * 1.05).toInt()}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Pay Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () => _processPayment(appState),
              child: _isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Processing...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getPaymentIcon()),
                        const SizedBox(width: 8),
                        Text(
                          _getPaymentButtonText(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Terms Text
          Text(
            'By proceeding, you agree to our Terms & Conditions',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon() {
    switch (_selectedPaymentMethod) {
      case PaymentMethod.upi:
        return MdiIcons.qrcode;
      case PaymentMethod.card:
        return MdiIcons.creditCard;
      case PaymentMethod.wallet:
        return MdiIcons.wallet;
      case PaymentMethod.qr:
        return MdiIcons.qrcode;
    }
  }

  String _getPaymentButtonText() {
    switch (_selectedPaymentMethod) {
      case PaymentMethod.upi:
        return 'Pay with UPI';
      case PaymentMethod.card:
        return 'Pay with Card';
      case PaymentMethod.wallet:
        return 'Pay with Wallet';
      case PaymentMethod.qr:
        return 'Pay with QR';
    }
  }

  Future<void> _processPayment(AppState appState) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Get the current user from auth service
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      // Create order first
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        storeId: widget.storeId,
        userId: currentUser?.id,
        items: List.from(appState.cartItems),
        totalAmount: appState.cartTotal * 1.05, // Including taxes
        paymentMethod: _selectedPaymentMethod,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      // Get user details from auth service
      final userEmail = currentUser?.email ?? 'guest@snackly.com';
      final userName = currentUser?.name ?? 'Guest User';
      final userPhone = currentUser?.phone ?? '+919999999999';

      // Process payment through Razorpay
      await _paymentService.processGroceryStorePayment(
        order: order,
        customerName: userName,
        customerEmail: userEmail,
        customerPhone: userPhone,
        onSuccess: (PaymentSuccessResponse response) async {
          // Payment successful
          debugPrint('💳 Payment successful: ${response.paymentId}');
          final startTime = DateTime.now();
          Order? finalOrder;
          
          // 🚀 SAVE ORDER TO SUPABASE - Real-time sync to Admin Dashboard
          try {
            debugPrint('📤 Sending order to Supabase backend...');
            final createdOrder = await _orderRepository?.createOrder(
              storeId: widget.storeId,
              userId: currentUser?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}',
              items: appState.cartItems,
              totalAmount: appState.cartTotal * 1.05,
              paymentMethod: _selectedPaymentMethod.name,
              paymentId: response.paymentId,
            );
            
            final syncTime = DateTime.now().difference(startTime).inMilliseconds;
            
            if (createdOrder != null) {
              debugPrint('✅ Order synced to backend in ${syncTime}ms - Admin will see this instantly!');
              
              // Update order status to confirmed
              await _orderRepository?.updateOrderStatus(createdOrder.id, 'confirmed');
              
              // Save to app state with confirmed status
              finalOrder = createdOrder.copyWith(
                status: OrderStatus.confirmed,
                paymentId: response.paymentId,
              );
              appState.addOrder(finalOrder);
            } else {
              debugPrint('⚠️ Order creation returned null');
              // Fallback to local order
              finalOrder = order.copyWith(
                status: OrderStatus.confirmed,
                paymentId: response.paymentId,
              );
              appState.addOrder(finalOrder);
            }
          } catch (e) {
            debugPrint('⚠️ Failed to sync order to backend: $e');
            // Continue anyway - save order locally
            finalOrder = order.copyWith(
              status: OrderStatus.confirmed,
              paymentId: response.paymentId,
            );
            appState.addOrder(finalOrder);
          }
          
          // Clear cart
          appState.clearCart();
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      MdiIcons.checkCircle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Payment successful! Order confirmed.',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.accent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
            
            // Navigate to order confirmation
            context.go('${AppRoutes.orderConfirmation}/${finalOrder.id}');
          }
        },
        onError: (PaymentFailureResponse error) {
          // Payment failed
          debugPrint('Payment failed: ${error.message}');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      MdiIcons.alertCircle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Payment failed: ${error.message}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        onExternalWallet: (ExternalWalletResponse response) {
          // External wallet selected
          debugPrint('External wallet: ${response.walletName}');
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('External wallet: ${response.walletName}'),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        },
      );
      
    } catch (e) {
      debugPrint('Payment processing error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  MdiIcons.alertCircle,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error processing payment: ${e.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
