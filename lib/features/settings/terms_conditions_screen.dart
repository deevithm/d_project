import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLastUpdated(),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Acceptance of Terms',
                      'By accessing and using this grocery store application, you accept and agree to be bound by the terms and provision of this agreement.',
                    ),
                    _buildSection(
                      'Service Description',
                      'This app provides access to smart grocery stores with AI-powered product recommendations, dynamic pricing, and convenient payment options. Features include product browsing, inventory tracking, and order history.',
                    ),
                    _buildSection(
                      'User Accounts',
                      'You must create an account to use our services. You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
                    ),
                    _buildSection(
                      'Payment and Pricing',
                      'Prices are displayed in real-time and may change based on demand. Payment is processed securely through integrated payment gateways. All sales are final unless products are defective.',
                    ),
                    _buildSection(
                      'Product Availability',
                      'Product availability is updated in real-time but may not always reflect current inventory due to technical limitations. We reserve the right to limit quantities and refuse service.',
                    ),
                    _buildSection(
                      'User Conduct',
                      'You agree not to use the service for any unlawful purpose or in any way that could damage, disable, or impair the service. Tampering with store equipment is strictly prohibited.',
                    ),
                    _buildSection(
                      'Privacy and Data',
                      'Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information.',
                    ),
                    _buildSection(
                      'Refunds and Returns',
                      'Refunds may be issued for products not dispensed due to store system malfunction. Contact customer support within 24 hours for refund requests. Digital products and services are non-refundable.',
                    ),
                    _buildSection(
                      'Limitation of Liability',
                      'We shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.',
                    ),
                    _buildSection(
                      'Changes to Terms',
                      'We reserve the right to modify these terms at any time. Changes will be effective immediately upon posting. Continued use of the service constitutes acceptance of modified terms.',
                    ),
                    _buildSection(
                      'Contact Information',
                      'For questions about these Terms and Conditions, please contact us at:\n\nEmail: chandruselvam1012@gmail.com\nPhone: +91 6369431485',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            onPressed: () => context.pop(),
            icon: Icon(
              MdiIcons.arrowLeft,
              color: AppColors.textPrimary,
            ),
          ),
          const Expanded(
            child: Text(
              'Terms & Conditions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            MdiIcons.clockOutline,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Last updated: January 15, 2025',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}