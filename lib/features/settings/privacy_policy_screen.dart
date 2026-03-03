import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                      'Information We Collect',
                      'We collect information you provide directly to us, such as when you create an account, make a purchase, or contact customer support. This includes your name, email address, phone number, and payment information.',
                    ),
                    _buildSection(
                      'Location Information',
                      'We collect location data to help you find nearby grocery stores and provide location-based services. You can disable location sharing in your device settings at any time.',
                    ),
                    _buildSection(
                      'Usage Data',
                      'We automatically collect information about your app usage, including purchase history, product preferences, and interaction patterns to improve our services and provide personalized recommendations.',
                    ),
                    _buildSection(
                      'Device Information',
                      'We collect information about the device you use to access our app, including device type, operating system, unique device identifiers, and mobile network information.',
                    ),
                    _buildSection(
                      'How We Use Your Information',
                      'We use the information we collect to:\n• Provide and maintain our services\n• Process transactions and send related information\n• Send you technical notices and support messages\n• Respond to your comments and questions\n• Provide personalized content and recommendations\n• Monitor and analyze trends and usage',
                    ),
                    _buildSection(
                      'Information Sharing',
                      'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy. We may share information with service providers who assist us in operating our app and conducting our business.',
                    ),
                    _buildSection(
                      'Payment Information',
                      'Payment information is processed securely through our payment partners. We do not store complete payment card details on our servers. Payment data is encrypted and handled in compliance with PCI DSS standards.',
                    ),
                    _buildSection(
                      'Data Security',
                      'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
                    ),
                    _buildSection(
                      'Data Retention',
                      'We retain your personal information for as long as necessary to provide our services and fulfill the purposes outlined in this policy, unless a longer retention period is required by law.',
                    ),
                    _buildSection(
                      'Your Rights',
                      'You have the right to:\n• Access and update your personal information\n• Delete your account and associated data\n• Opt out of promotional communications\n• Request a copy of your data\n• Restrict processing of your data',
                    ),
                    _buildSection(
                      'Children\'s Privacy',
                      'Our service is not directed to children under 13. We do not knowingly collect personal information from children under 13. If you become aware that a child has provided us with personal information, please contact us.',
                    ),
                    _buildSection(
                      'Changes to This Policy',
                      'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
                    ),
                    _buildSection(
                      'Contact Us',
                      'If you have any questions about this Privacy Policy, please contact us at:\n\nEmail: chandruselvam1012@gmail.com\nPhone: +91 6369431485\n\nWe are committed to resolving any privacy concerns you may have.',
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
              'Privacy Policy',
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
            MdiIcons.shieldCheckOutline,
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