import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../view_model/AuthVM/get_counter_view_model.dart';
import '../../view_model/AuthVM/get_profile_view_model.dart';


class WithdrawPage extends StatefulWidget {
  final String phoneNumber;
  final String userId;

  const WithdrawPage({
    super.key,
    required this.phoneNumber,
    required this.userId,
  });

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _withdrawAmount = '0';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    // Listen to amount input changes
    _amountController.addListener(() {
      setState(() {
        _withdrawAmount = _amountController.text.isEmpty ? '0' : _amountController.text;
      });
    });
  }

  Future<void> _loadInitialData() async {
    final profileViewModel = Provider.of<GetProfileViewModel>(context, listen: false);
    final counterViewModel = Provider.of<GetCounterViewModel>(context, listen: false);

    await Future.wait([
      profileViewModel.getProfile(widget.phoneNumber),
      counterViewModel.getCounter(widget.userId),
    ]);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: _buildAppBar(),
      body: Consumer2<GetProfileViewModel, GetCounterViewModel>(
        builder: (context, profileViewModel, counterViewModel, child) {
          return RefreshIndicator(
            onRefresh: _loadInitialData,
            color: AppColors.lightSage,
            backgroundColor: AppColors.primaryDark,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: _buildContent(profileViewModel, counterViewModel),
            ),
          );
        },
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
            'Withdraw from Wallet',
            style: AppTextStyles.heading.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.lightSage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(GetProfileViewModel profileViewModel, GetCounterViewModel counterViewModel) {
    if (profileViewModel.isLoading || counterViewModel.isLoading) {
      return _buildShimmerContent();
    }

    if (profileViewModel.error != null || counterViewModel.error != null) {
      return _buildErrorWidget(profileViewModel, counterViewModel);
    }

    final walletBalance = profileViewModel.profile?.result?.first.walletBalance ?? 0;
    final counter = counterViewModel.counter?.result?.first.counter ?? 0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Wallet Balance Card
            _buildWalletBalanceCard(walletBalance),

            const SizedBox(height: 20),

            // Counter Status Card
            _buildCounterStatusCard(counter),

            const SizedBox(height: 20),

            // Withdrawal Form
            _buildWithdrawalForm(walletBalance, counter),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContent() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightSage.withOpacity(0.1),
      highlightColor: AppColors.lightSage.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Wallet Balance Shimmer
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            // Counter Status Shimmer
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            const SizedBox(height: 20),

            // Form Shimmer
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletBalanceCard(int walletBalance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightSage.withOpacity(0.9),
            AppColors.lightSage,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightSage.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.primaryDark,
              size: 32,
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Balance',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDark.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '₹$walletBalance',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterStatusCard(int counter) {
    final bool isEligible = counter >= 50;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEligible
              ? [
            Colors.green.withOpacity(0.15),
            Colors.green.withOpacity(0.08),
          ]
              : [
            Colors.orange.withOpacity(0.15),
            Colors.orange.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEligible
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEligible
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEligible ? Icons.check_circle_rounded : Icons.warning_rounded,
              color: isEligible ? Colors.green : Colors.orange,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEligible ? 'Withdrawal Eligible' : 'Withdrawal Requirements',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.lightSage,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  isEligible
                      ? 'You have spent ₹$counter and can withdraw funds'
                      : 'Spend ₹${50 - counter} more to enable withdrawal (Current: ₹$counter)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.lightSage.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalForm(int walletBalance, int counter) {
    final bool isEligible = counter >= 50;

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
          color: AppColors.lightSage.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightSage.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.send_to_mobile_rounded,
                  color: AppColors.lightSage,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Withdrawal Details',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.lightSage,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Amount Input
          Text(
            'Enter Amount (e.g. 500)',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightSage.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: AppColors.lightSage.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lightSage.withOpacity(0.2),
              ),
            ),
            child: TextFormField(
              controller: _amountController,
              enabled: isEligible && walletBalance >= 100,
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Amount cannot be empty';
                }
                final amount = int.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (amount > walletBalance) {
                  return 'Amount cannot exceed wallet balance (₹$walletBalance)';
                }
                if (walletBalance < 100) {
                  return 'Minimum wallet balance of ₹100 required';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 20),

          // UPI Input
          Text(
            'Enter UPI ID (e.g. example@upi)',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.lightSage.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: AppColors.lightSage.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.lightSage.withOpacity(0.2),
              ),
            ),
            child: TextFormField(
              controller: _upiController,
              enabled: isEligible && walletBalance >= 100,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.lightSage,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Enter UPI ID e.g. example@upi',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.lightSage.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.lightSage.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'UPI ID cannot be empty';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid UPI ID';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 24),

          // Withdraw Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: (isEligible && walletBalance >= 100 && !_isProcessing)
                  ? _handleWithdraw
                  : null,
              icon: _isProcessing
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.send_rounded),
              label: Text(
                _isProcessing
                    ? 'Processing...'
                    : 'Withdraw ₹$_withdrawAmount',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: (isEligible && walletBalance >= 100)
                    ? AppColors.primaryDark
                    : Colors.grey,
                foregroundColor: Colors.white,
                elevation: (isEligible && walletBalance >= 100) ? 4 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Requirements Info
          if (!isEligible || walletBalance < 100)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.red.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Withdrawal Requirements:',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Minimum spending of ₹50 required\n'
                        '• Wallet balance must be ≥ ₹100\n'
                        '• Current spending: ₹$counter (${counter >= 50 ? '✓' : 'Need ₹${50 - counter} more'})\n'
                        '• Wallet balance: ₹$walletBalance (${walletBalance >= 100 ? '✓' : 'Need ₹${100 - walletBalance} more'})',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.red,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          else
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
                      'Tip: Withdrawals are processed within 24-48 hours to your UPI account.',
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

  void _handleWithdraw() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
    });

    // TODO: Implement actual withdrawal API call here
    _showWithdrawSuccessDialog();
  }

  void _showWithdrawSuccessDialog() {
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
                'Withdrawal Request Submitted!',
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Your withdrawal request of ₹$_withdrawAmount has been submitted successfully. You will receive the amount in your UPI account within 24-48 hours.',
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

  Widget _buildErrorWidget(GetProfileViewModel profileViewModel, GetCounterViewModel counterViewModel) {
    final String errorMessage = profileViewModel.error ?? counterViewModel.error ?? 'Something went wrong';

    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.lightSage.withOpacity(0.5),
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to Load Data',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.lightSage,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.lightSage.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _loadInitialData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightSage,
                foregroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
