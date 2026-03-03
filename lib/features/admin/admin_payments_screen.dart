import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/constants.dart';

class PaymentTransaction {
  final String transactionId;
  final String orderId;
  final String customerName;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime transactionDate;
  final String? referenceNumber;

  PaymentTransaction({
    required this.transactionId,
    required this.orderId,
    required this.customerName,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.transactionDate,
    this.referenceNumber,
  });
}

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  List<PaymentTransaction> _transactions = [];
  bool _isLoading = true;
  double _totalRevenue = 0;
  double _pendingAmount = 0;
  int _successfulPayments = 0;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    
    // Simulate loading - replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _transactions = _getMockTransactions();
      _calculateStats();
      _isLoading = false;
    });
  }

  void _calculateStats() {
    _totalRevenue = 0;
    _pendingAmount = 0;
    _successfulPayments = 0;

    for (var transaction in _transactions) {
      if (transaction.status.toLowerCase() == 'success') {
        _totalRevenue += transaction.amount;
        _successfulPayments++;
      } else if (transaction.status.toLowerCase() == 'pending') {
        _pendingAmount += transaction.amount;
      }
    }
  }

  List<PaymentTransaction> _getMockTransactions() {
    return [
      PaymentTransaction(
        transactionId: 'TXN-2024-001',
        orderId: 'ORD-2024-001',
        customerName: 'John Doe',
        amount: 1250.0,
        paymentMethod: 'UPI',
        status: 'Success',
        transactionDate: DateTime.now().subtract(const Duration(minutes: 15)),
        referenceNumber: 'UPI2024001',
      ),
      PaymentTransaction(
        transactionId: 'TXN-2024-002',
        orderId: 'ORD-2024-002',
        customerName: 'Jane Smith',
        amount: 890.0,
        paymentMethod: 'Card',
        status: 'Success',
        transactionDate: DateTime.now().subtract(const Duration(hours: 1)),
        referenceNumber: 'CARD2024002',
      ),
      PaymentTransaction(
        transactionId: 'TXN-2024-003',
        orderId: 'ORD-2024-003',
        customerName: 'Mike Johnson',
        amount: 560.0,
        paymentMethod: 'Cash',
        status: 'Pending',
        transactionDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PaymentTransaction(
        transactionId: 'TXN-2024-004',
        orderId: 'ORD-2024-004',
        customerName: 'Sarah Williams',
        amount: 2100.0,
        paymentMethod: 'UPI',
        status: 'Success',
        transactionDate: DateTime.now().subtract(const Duration(hours: 5)),
        referenceNumber: 'UPI2024004',
      ),
      PaymentTransaction(
        transactionId: 'TXN-2024-005',
        orderId: 'ORD-2024-005',
        customerName: 'David Brown',
        amount: 450.0,
        paymentMethod: 'Card',
        status: 'Failed',
        transactionDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PaymentTransaction(
        transactionId: 'TXN-2024-006',
        orderId: 'ORD-2024-006',
        customerName: 'Emma Wilson',
        amount: 720.0,
        paymentMethod: 'UPI',
        status: 'Refunded',
        transactionDate: DateTime.now().subtract(const Duration(days: 2)),
        referenceNumber: 'REF2024006',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Status'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(MdiIcons.refresh),
            onPressed: _loadPayments,
          ),
          IconButton(
            icon: Icon(MdiIcons.downloadOutline),
            onPressed: () {
              // TODO: Export payment report
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPayments,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Revenue Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Revenue',
                            '₹${_totalRevenue.toStringAsFixed(2)}',
                            MdiIcons.currencyInr,
                            Colors.green,
                            '+12%',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Pending',
                            '₹${_pendingAmount.toStringAsFixed(2)}',
                            MdiIcons.clockOutline,
                            Colors.orange,
                            '3 pending',
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Successful',
                            '$_successfulPayments',
                            MdiIcons.checkCircle,
                            AppColors.success,
                            '${(_successfulPayments / _transactions.length * 100).toStringAsFixed(1)}%',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Transactions',
                            '${_transactions.length}',
                            MdiIcons.swapHorizontal,
                            Colors.blue,
                            'Total',
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Transaction List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        return _buildTransactionCard(_transactions[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(PaymentTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTransactionDetails(transaction),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.transactionId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.customerName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(transaction.status),
                ],
              ),
              
              const Divider(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getPaymentIcon(transaction.paymentMethod),
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            transaction.paymentMethod,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDateTime(transaction.transactionDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₹${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(transaction.status),
                    ),
                  ),
                ],
              ),
              
              if (transaction.referenceNumber != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          MdiIcons.identifier,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ref: ${transaction.referenceNumber}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            fontFamily: 'monospace',
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

  Widget _buildStatusBadge(String status) {
    Color color = _getStatusColor(status);
    IconData icon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return AppColors.error;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return MdiIcons.checkCircle;
      case 'pending':
        return MdiIcons.clockOutline;
      case 'failed':
        return MdiIcons.closeCircle;
      case 'refunded':
        return MdiIcons.arrowULeftTop;
      default:
        return MdiIcons.helpCircle;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return MdiIcons.cellphone;
      case 'card':
        return MdiIcons.creditCard;
      case 'cash':
        return MdiIcons.cash;
      default:
        return MdiIcons.currencyInr;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showTransactionDetails(PaymentTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                  'Transaction Details',
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
                    _buildDetailRow('Transaction ID', transaction.transactionId),
                    _buildDetailRow('Order ID', transaction.orderId),
                    _buildDetailRow('Customer', transaction.customerName),
                    _buildDetailRow('Amount', '₹${transaction.amount.toStringAsFixed(2)}'),
                    _buildDetailRow('Payment Method', transaction.paymentMethod),
                    _buildDetailRow('Status', transaction.status),
                    if (transaction.referenceNumber != null)
                      _buildDetailRow('Reference Number', transaction.referenceNumber!),
                    _buildDetailRow('Date & Time', _formatDateTime(transaction.transactionDate)),
                  ],
                ),
              ),
            ),
            
            // Actions
            if (transaction.status.toLowerCase() == 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Initiate refund
                    Navigator.pop(context);
                  },
                  icon: Icon(MdiIcons.arrowULeftTop),
                  label: const Text('Initiate Refund'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
            width: 140,
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
}
