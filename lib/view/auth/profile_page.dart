import 'package:flutter/material.dart';
import 'package:pashu_app/view/auth/login_screen.dart';
import 'package:pashu_app/view/home/splash_screen.dart';
import 'package:pashu_app/view/profile/edit_profile_page.dart';
import 'package:pashu_app/view/profile/sold_out_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../core/shared_pref_helper.dart';
import '../../model/auth/profile_model.dart';
import '../../view_model/AuthVM/get_profile_view_model.dart';
import '../profile/contact_us_page.dart';
import '../profile/listed_pashu_page.dart';
import '../profile/referal_page.dart';
import '../profile/subscription_page.dart';
import '../profile/terms_and_policy_page.dart';
import '../profile/withdraw_page.dart';


class ProfilePage extends StatefulWidget {
  final String phoneNumber;

  const ProfilePage({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GetProfileViewModel>(context, listen: false)
          .getProfile(widget.phoneNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Consumer<GetProfileViewModel>(
          builder: (context, viewModel, child) {
            return RefreshIndicator(
              onRefresh: () => viewModel.getProfile(widget.phoneNumber),
              color: AppColors.lightSage,
              backgroundColor: AppColors.primaryDark,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _buildContent(viewModel),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(GetProfileViewModel viewModel) {
    if (viewModel.isLoading) {
      return _buildShimmerContent();
    }

    if (viewModel.error != null) {
      return _buildErrorWidget(viewModel);
    }

    if (viewModel.profile?.result == null || viewModel.profile!.result!.isEmpty) {
      return _buildEmptyWidget();
    }

    final user = viewModel.profile!.result!.first;
    return _buildProfileContent(user);
  }

  Widget _buildShimmerContent() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightSage.withOpacity(0.1),
      highlightColor: AppColors.lightSage.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header Shimmer
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 20),

            // Menu Items Shimmer
            ...List.generate(8, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(Result user) {
    return Column(
      children: [
        // Profile Header Card (matching image style)
        _buildProfileHeader(user),

        // Menu Section
        _buildMenuSection(user),
      ],
    );
  }

  Widget _buildProfileHeader(Result user) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
          // Profile Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryDark.withOpacity(0.1),
              border: Border.all(
                color: AppColors.primaryDark.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 35,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username ?? 'Ankit Khare',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Text(
                  user.number ?? '6393906928',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDark.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Wallet Balance
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Wallet Balance',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.primaryDark,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${user.walletBalance ?? 50} ₹',
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(Result user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.lightSage.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.lightSage.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            'Add Amount & Get Plans',
            Icons.add_card_rounded,
            hasNewBadge: true,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Get Verified Your Pashu',
            Icons.verified_user_rounded,
            hasNewBadge: true,
            onTap: () {
              Navigator.pushNamed(context, '/verify-pashu');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Withdraw Balance',
            Icons.account_balance_rounded,
            hasNewBadge: true,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => WithdrawPage(phoneNumber: user.number!, userId: user.id!.toString(),)));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'My Transaction',
            Icons.receipt_long_rounded,
            onTap: () {
              Navigator.pushNamed(context, '/my-transactions');
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Edit Profile',
            Icons.edit_rounded,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(userProfile: user, phoneNumber: user.number!)));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Your Listed Pashu',
            Icons.pets_rounded,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ListedPashuPage()));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Sold Out Pashu History',
            Icons.history_rounded,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SoldOutHistoryPage()));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Referral Code',
            Icons.share_rounded,
            onTap: () {
              Navigator.push(context,  MaterialPageRoute(builder: (context) => ReferralPage(referralCode: user.referralcode ?? '', username: user.username!)));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Terms & Privacy',
            Icons.privacy_tip_rounded,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsPrivacyPage()));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Contact Us',
            Icons.contact_support_rounded,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsPage()));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            'Logout',
            Icons.logout_rounded,
            isLogout: true,
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      String title,
      IconData icon, {
        bool hasNewBadge = false,
        bool isLogout = false,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLogout ? Colors.red : AppColors.lightSage,
                size: 22,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isLogout ? Colors.red : AppColors.lightSage,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              if (hasNewBadge) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'NEW',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isLogout ? Colors.red.withOpacity(0.6) : AppColors.lightSage.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: AppColors.lightSage.withOpacity(0.1),
    );
  }

  void _showLogoutDialog() {
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
              Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from your account?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark.withOpacity(0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async{
                Navigator.pop(context);
                await SharedPrefHelper.clearUserDetails();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorWidget(GetProfileViewModel viewModel) {
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
              'Failed to Load Profile',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.lightSage,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              viewModel.error ?? 'Something went wrong',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.lightSage.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                viewModel.getProfile(widget.phoneNumber);
              },
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

  Widget _buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              color: AppColors.lightSage.withOpacity(0.5),
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'No Profile Found',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.lightSage,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Profile information is not available',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.lightSage.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
