import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_logo.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _amountController = TextEditingController();
  String _addMoneyAmount = '0';

  // Subscription plans data - Fixed pricing without monthly/annual toggle
  final List<Map<String, dynamic>> _subscriptionPlans = [
    {
      'name': 'Diamond Plan',
      'icon': Icons.diamond_rounded,
      'color': const Color(0xFF6C63FF),
      'features': [
        'Unlimited Pashu Profile Contact',
        'Unlimited Free Pashu Listings',
        'Priority Customer Support',
        'Advanced Analytics',
        'Premium Badge'
      ],
      'price': 365,
      'period': 'Year',
      'popular': false, // Removed popular badge
    },
    {
      'name': 'Gold Plan',
      'icon': Icons.star_rounded,
      'color': const Color(0xFFFFB800),
      'features': [
        'Unlimited Pashu Profile Contact',
        '10 Free Pashu Listings',
        'Standard Customer Support',
        'Basic Analytics'
      ],
      'price': 140,
      'period': '3 Months',
      'popular': false,
    },
    {
      'name': 'Silver Plan',
      'icon': Icons.grade_rounded,
      'color': const Color(0xFF64748B),
      'features': [
        'Unlimited Pashu Profile Contact',
        '2 Free Pashu Listings',
        'Email Support'
      ],
      'price': 49,
      'period': 'Month',
      'popular': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    // Listen to amount input changes
    _amountController.addListener(() {
      setState(() {
        _addMoneyAmount = _amountController.text.isEmpty ? '0' : _amountController.text;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildSubscriptionPlans(), // Removed pricing toggle
              _buildAddMoneySection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightSage.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
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
            'Subscription Plans',
            style: AppTextStyles.heading.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.lightSage,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightSage.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () {
            _showHelpDialog();
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lightSage.withOpacity(0.8),
                  AppColors.lightSage,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.lightSage.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 40,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'Choose Your Plan',
            style: AppTextStyles.heading.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.lightSage,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Unlock premium features and grow your livestock business with our subscription plans',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightSage.withOpacity(0.8),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _subscriptionPlans.map((plan) => _buildPlanCard(plan)).toList(),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          color: AppColors.lightSage.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: plan['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    plan['icon'],
                    color: plan['color'],
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Text(
                    plan['name'],
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.lightSage,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${plan['price']}',
                  style: AppTextStyles.heading.copyWith(
                    color: plan['color'],
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '/ ${plan['period']}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.lightSage.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Features
            ...plan['features'].map<Widget>((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.lightSage.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),

            const SizedBox(height: 24),

            // Subscribe Button with better visibility
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _handleSubscription(plan);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan['color'], // Use plan color for better visibility
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: plan['color'].withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Choose Plan', // Consistent button text
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700, // Bolder text for better visibility
                    fontSize: 16,
                    color: Colors.white, // Explicit white color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoneySection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.15),
            Colors.orange.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Add Money to Your Wallet',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.lightSage,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Add funds to your wallet and pay for subscriptions seamlessly. Your wallet can be used across all our services.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightSage.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // Amount Input
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightSage.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lightSage.withOpacity(0.2),
              ),
            ),
            child: TextField(
              controller: _amountController,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.lightSage,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Enter Amount e.g. 500',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.lightSage.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.currency_rupee_rounded,
                  color: AppColors.lightSage.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ),

          const SizedBox(height: 16),

          // Add Money Button with dynamic amount
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _handleAddMoney();
              },
              icon: const Icon(Icons.add_rounded),
              label: Text('Add ₹$_addMoneyAmount'), // Dynamic amount display
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Tip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.blue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tip: Your wallet can be used to see the contact details instantly.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubscription(Map<String, dynamic> plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: AppColors.lightSage,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: plan['color'].withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        plan['icon'],
                        color: plan['color'],
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Subscribe to ${plan['name']}',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'You will be charged ₹${plan['price']} for this ${plan['period'].toLowerCase()} subscription.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDark.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Handle payment
                          _showPaymentSuccessDialog(plan);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: plan['color'],
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Confirm Subscription',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryDark.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAddMoney() {
    if (_addMoneyAmount == '0' || _addMoneyAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Handle add money functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Adding ₹$_addMoneyAmount to wallet'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showPaymentSuccessDialog(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.lightSage,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 48,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Subscription Successful!',
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'You have successfully subscribed to ${plan['name']}. Enjoy all premium features!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.lightSage,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Subscription Help',
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• Diamond Plan: ₹365/Year\n'
                    '• Gold Plan: ₹140/3 Months\n'
                    '• Silver Plan: ₹49/Month\n'
                    '• Cancel anytime from your profile\n'
                    '• All features unlock immediately\n'
                    '• 24/7 customer support included',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Got it',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
