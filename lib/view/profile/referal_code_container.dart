import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/shared_pref_helper.dart';

class ReferralCodeContainer extends StatefulWidget {
  const ReferralCodeContainer({super.key});

  @override
  State<ReferralCodeContainer> createState() => _ReferralCodeContainerState();
}

class _ReferralCodeContainerState extends State<ReferralCodeContainer> {
  String referralCode = '';

  @override
  void initState() {
    super.initState();
    _generateReferralCode();
  }

  Future<void> _generateReferralCode() async {
    final name = await SharedPrefHelper.getUsername() ?? 'Guest';
    final phone = await SharedPrefHelper.getPhoneNumber() ?? '0000000000';

    String firstName = name.split(" ").first.toLowerCase();
    String phoneSuffix = phone.length >= 10 ? phone.substring(phone.length - 5) : "00000";

    setState(() {
      referralCode = '$firstName-$phoneSuffix';
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Referral code copied!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryDark.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            referralCode,
            style: AppTextStyles.heading.copyWith(
              color: AppColors.primaryDark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Copy Button
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () => _copyToClipboard(referralCode),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}