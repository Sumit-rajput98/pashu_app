import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pashu_app/core/shared_pref_helper.dart';
import 'package:pashu_app/model/auth/profile_model.dart';

import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_logo.dart';
import '../../view_model/AuthVM/get_profile_view_model.dart';

class SubscriptionPage extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback? onBack;
  const SubscriptionPage({super.key, required this.phoneNumber, this.onBack});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _amountController = TextEditingController();
  String _addMoneyAmount = '0';

  late Razorpay _razorpay;
  late Result userData;

  @override
  void initState() {
    super.initState();
    Provider.of<GetProfileViewModel>(context, listen: false)
        .getProfile(widget.phoneNumber);
    userData = Provider.of<GetProfileViewModel>(context, listen: false).profile!.result!.first;
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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
    _razorpay.clear();
    _animationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Get localized subscription plans
  List<Map<String, dynamic>> getSubscriptionPlans(AppLocalizations l10n) {
    return [
      {
        'name': l10n.diamondPlan,
        'icon': Icons.diamond_rounded,
        'color': const Color(0xFF6C63FF),
        'features': [
          l10n.unlimitedPashuProfileContact,
          l10n.unlimitedFreePashuListings,
          l10n.priorityCustomerSupport,
          l10n.advancedAnalytics,
          l10n.premiumBadge
        ],
        'price': 365,
        'period': l10n.year,
        'popular': false,
      },
      {
        'name': l10n.goldPlan,
        'icon': Icons.star_rounded,
        'color': const Color(0xFFFFB800),
        'features': [
          l10n.unlimitedPashuProfileContact,
          l10n.freePashuListings10,
          l10n.standardCustomerSupport,
          l10n.basicAnalytics
        ],
        'price': 140,
        'period': l10n.months3,
        'popular': false,
      },
      {
        'name': l10n.silverPlan,
        'icon': Icons.grade_rounded,
        'color': const Color(0xFF64748B),
        'features': [
          l10n.unlimitedPashuProfileContact,
          l10n.freePashuListings2,
          l10n.emailSupport
        ],
        'price': 49,
        'period': l10n.month,
        'popular': false,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grayish-white background

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(l10n),
              _buildSubscriptionPlans(l10n),
              _buildAddMoneySection(l10n),
              const SizedBox(height: kBottomNavigationBarHeight + 30),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
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
            l10n.subscriptionPlans,
            style: AppTextStyles.heading.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryDark.withOpacity(0.2)),
            ),
            child: Icon(
              Icons.help_outline_rounded,
              color: AppColors.primaryDark,
              size: 20,
            ),
          ),
          onPressed: () {
            _showHelpDialog(l10n);
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightSage.withOpacity(0.15),
                  AppColors.lightSage.withOpacity(0.08),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryDark, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.1),
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
            l10n.chooseYourPlan,
            style: AppTextStyles.heading.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            l10n.unlockPremiumFeatures,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(AppLocalizations l10n) {
    final subscriptionPlans = getSubscriptionPlans(l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: subscriptionPlans.map((plan) => _buildPlanCard(plan, l10n)).toList(),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, AppLocalizations l10n) {
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
                    border: Border.all(
                      color: plan['color'].withOpacity(0.3),
                    ),
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
                      color: AppColors.primaryDark,
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
                      color: AppColors.primaryDark.withOpacity(0.6),
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
                        color: AppColors.primaryDark.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),

            const SizedBox(height: 24),

            // Subscribe Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _handleSubscription(plan, l10n);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: plan['color'],
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: plan['color'].withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.choosePlan,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoneySection(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
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
                  l10n.addMoneyToYourWallet,
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            l10n.addFundsToWallet,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark.withOpacity(0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // Amount Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryDark.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _amountController,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryDark,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: l10n.enterAmountEg500,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.currency_rupee_rounded,
                  color: AppColors.primaryDark.withOpacity(0.6),
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

          // Add Money Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                _handleAddMoney(l10n);
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addAmount(_addMoneyAmount)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.orange.withOpacity(0.3),
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
                    l10n.tipWalletContact,
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

  void _handleSubscription(Map<String, dynamic> plan, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: AppColors.primaryDark, width: 2),
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
                        border: Border.all(
                          color: plan['color'].withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        plan['icon'],
                        color: plan['color'],
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      l10n.subscribeToPlan(plan['name']),
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      l10n.chargedForSubscription(plan['price'].toString(), plan['period'].toLowerCase()),
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
                          _showPaymentSuccessDialog(plan, l10n);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: plan['color'],
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          l10n.confirmSubscription,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryDark.withOpacity(0.6),
                      ),
                      child: Text(
                        l10n.cancel,
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

  void _handleAddMoney(AppLocalizations l10n) async {
    final amt = double.tryParse(_amountController.text);
    if (amt == null || amt <= 0) {
      Fluttertoast.showToast(
        msg: l10n.pleaseEnterValidAmount,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.TOP,
      );
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('https://pashuparivar.com/api/payment/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': amt}),
      );
      String? phoneNumber = await SharedPrefHelper.getPhoneNumber();

      final jsonRes = json.decode(res.body);
      final orderId = jsonRes['orderId'];

      var options = {
        'key': 'rzp_live_gm2iOnFy9nUmUx',
        'amount': (amt * 100).toInt(),
        'name': 'Pashu Parivar',
        'description': 'Add Wallet Balance in Pashu Parivar',
        'order_id': orderId,
        'prefill': {
          'name': userData.username,
          'contact': userData.number,
          'email': userData.emailid ?? '',
        },
        'theme': {'color': '#A5BE7E'},
        'image': 'https://pashuparivar.com/uploads/newlogo.png',
      };

      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
      Fluttertoast.showToast(
        msg: l10n.couldNotInitiatePayment,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.TOP,
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final l10n = AppLocalizations.of(context)!;
    final amt = double.tryParse(_amountController.text) ?? 0;
    final res = await http.post(
      Uri.parse('https://pashuparivar.com/api/payment/verify-payment'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userData.id,
        'amount': amt,
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
        'razorpay_signature': response.signature,
      }),
    );

    final jsonRes = json.decode(res.body);

    if (jsonRes['success']) {
      Fluttertoast.showToast(
        msg: l10n.paymentCompletedSuccessfully,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        gravity: ToastGravity.TOP,
      );
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
        msg: l10n.paymentVerificationFailed,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.TOP,
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final l10n = AppLocalizations.of(context)!;
    String errorMsg = l10n.somethingWentWrongPayment;
    try {
      final parsed = json.decode(response.message ?? "");
      final reason = parsed['error']['reason'];
      final description = parsed['error']['description'];
      if (reason == 'payment_cancelled') {
        errorMsg = l10n.paymentCancelled;
      } else if (description != null) {
        errorMsg = description;
      }
    } catch (e) {}

    Fluttertoast.showToast(
      msg: "${l10n.paymentFailed}: $errorMsg",
      backgroundColor: Colors.red,
      textColor: Colors.white,
      gravity: ToastGravity.TOP,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    final l10n = AppLocalizations.of(context)!;
    Fluttertoast.showToast(
      msg: "${l10n.externalWalletSelected}: ${response.walletName}",
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      gravity: ToastGravity.TOP,
    );
  }

  void _showPaymentSuccessDialog(Map<String, dynamic> plan, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.primaryDark, width: 2),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 48,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                l10n.subscriptionSuccessful,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                l10n.subscriptionSuccessMessage(plan['name']),
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
                  child: Text(l10n.continueA),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.primaryDark, width: 2),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.subscriptionHelp,
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
                l10n.helpContent,
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: Text(
                l10n.gotIt,
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
