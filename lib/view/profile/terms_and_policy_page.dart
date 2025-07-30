import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';

class TermsPrivacyPage extends StatefulWidget {
  const TermsPrivacyPage({super.key});

  @override
  State<TermsPrivacyPage> createState() => _TermsPrivacyPageState();
}

class _TermsPrivacyPageState extends State<TermsPrivacyPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _showTerms = true; // true for Terms, false for Privacy Policy

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grayish-white background
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildToggleSection(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _showTerms ? _buildTermsContent() : _buildPrivacyContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryDark.withOpacity(0.2)),
          ),
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.primaryDark,
            size: 20,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          const AppLogo(size: 40),
          const SizedBox(width: 12),
          Text(
            'Terms & Privacy',
            style: AppTextStyles.heading.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryDark,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showTerms = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: _showTerms
                      ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primaryDark.withOpacity(0.8),
                    ],
                  )
                      : null,
                  color: _showTerms ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _showTerms
                      ? [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.article_rounded,
                      color: _showTerms ? Colors.white : AppColors.primaryDark,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Terms of Service',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _showTerms ? Colors.white : AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showTerms = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: !_showTerms
                      ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primaryDark.withOpacity(0.8),
                    ],
                  )
                      : null,
                  color: !_showTerms ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_showTerms
                      ? [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.privacy_tip_rounded,
                      color: !_showTerms ? Colors.white : AppColors.primaryDark,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Privacy Policy',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: !_showTerms ? Colors.white : AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightSage.withOpacity(0.1),
            AppColors.lightSage.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryDark,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark.withOpacity(0.15),
                      AppColors.primaryDark.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.article_rounded,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms of Service',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Last updated: July 27, 2025',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDark.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Terms Content
          _buildSection(
            'Acceptance of Terms',
            'By accessing and using Pashu Parivar, you accept and agree to be bound by the terms and provision of this agreement.',
          ),

          _buildSection(
            'Use License',
            'Permission is granted to temporarily download one copy of Pashu Parivar per device for personal, non-commercial transitory viewing only.',
          ),

          _buildSection(
            'User Responsibilities',
            '• Provide accurate information when creating listings\n'
                '• Respect other users and maintain professional conduct\n'
                '• Comply with all applicable laws and regulations\n'
                '• Not misuse the platform for fraudulent activities',
          ),

          _buildSection(
            'Platform Services',
            'Pashu Parivar provides a platform for livestock trading, connecting buyers and sellers. We facilitate transactions but are not directly involved in the buying/selling process.',
          ),

          _buildSection(
            'Account Security',
            'Users are responsible for maintaining the confidentiality of their account information and password. Notify us immediately of any unauthorized use.',
          ),

          _buildSection(
            'Payment Terms',
            'All payments for premium services are processed securely. Subscription fees are non-refundable unless specified otherwise.',
          ),

          _buildSection(
            'Content Guidelines',
            'All content uploaded must be appropriate, accurate, and comply with our community guidelines. We reserve the right to remove inappropriate content.',
          ),

          _buildSection(
            'Limitation of Liability',
            'Pashu Parivar shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.',
          ),

          _buildSection(
            'Modifications',
            'We reserve the right to modify these terms at any time. Users will be notified of significant changes.',
          ),

          _buildSection(
            'Contact Information',
            'For questions about these Terms of Service, please contact us at support@pashuparivar.com',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightSage.withOpacity(0.1),
            AppColors.lightSage.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryDark,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark.withOpacity(0.15),
                      AppColors.primaryDark.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryDark.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.privacy_tip_rounded,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy Policy',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Last updated: July 27, 2025',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDark.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Privacy Content
          _buildSection(
            'Information We Collect',
            '• Personal information: Name, phone number, email address\n'
                '• Profile information: Address, preferences, usage data\n'
                '• Device information: IP address, browser type, operating system\n'
                '• Usage data: App interactions, features used, session duration',
          ),

          _buildSection(
            'How We Use Your Information',
            'We use collected information to:\n'
                '• Provide and maintain our services\n'
                '• Process transactions and send notifications\n'
                '• Improve user experience and app functionality\n'
                '• Communicate with you about updates and offers',
          ),

          _buildSection(
            'Information Sharing',
            'We may share your information:\n'
                '• With other users (profile information in listings)\n'
                '• With service providers who assist our operations\n'
                '• When required by law or to protect our rights\n'
                '• With your consent for specific purposes',
          ),

          _buildSection(
            'Data Security',
            'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
          ),

          _buildSection(
            'Data Retention',
            'We retain your personal information only as long as necessary for the purposes outlined in this policy or as required by law.',
          ),

          _buildSection(
            'Your Rights',
            'You have the right to:\n'
                '• Access your personal information\n'
                '• Correct inaccurate information\n'
                '• Delete your account and data\n'
                '• Opt-out of marketing communications',
          ),

          _buildSection(
            'Cookies and Tracking',
            'We use cookies and similar technologies to enhance your experience, analyze usage patterns, and provide personalized content.',
          ),

          _buildSection(
            'Third-Party Services',
            'Our app may contain links to third-party services. We are not responsible for their privacy practices.',
          ),

          _buildSection(
            'Children\'s Privacy',
            'Our service is not intended for children under 13. We do not knowingly collect personal information from children under 13.',
          ),

          _buildSection(
            'Changes to This Policy',
            'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.',
          ),

          _buildSection(
            'Contact Us',
            'If you have questions about this Privacy Policy, please contact us at:\n'
                'Email: privacy@pashuparivar.com\n'
                'Phone: +91-XXXXXXXXXX',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading.copyWith(
            color: AppColors.primaryDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          content,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryDark.withOpacity(0.8),
            fontSize: 14,
            height: 1.6,
          ),
        ),

        if (!isLast) ...[
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: AppColors.primaryDark.withOpacity(0.1),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
