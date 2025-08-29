import 'package:flutter/material.dart';
import 'package:pashu_app/login_dialog.dart';
import 'package:pashu_app/view/auth/login_screen.dart';
import 'package:pashu_app/view/home/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/navigation_controller.dart';
import '../../core/shared_pref_helper.dart';
import '../../model/auth/profile_model.dart';
import '../../view_model/AuthVM/get_profile_view_model.dart';
import 'package:http/http.dart' as http;


class ProfilePage extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback? onBack;

  const ProfilePage({super.key, required this.phoneNumber, this.onBack});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool _hasFetchedProfile = false;
  bool isLoggedIn = false;


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    print("ProfilePage initState called");
    _fetchProfileData();
    getLoginStatus();


  }
  void getLoginStatus()async{
    isLoggedIn = await SharedPrefHelper.isLoggedIn();
    setState(() {

    });
  }


  @override
  void dispose() {

    super.dispose();
  }

  void _fetchProfileData() {
    print("Fetching profile for: ${widget.phoneNumber}");
    if (widget.phoneNumber.isNotEmpty) {
      Provider.of<GetProfileViewModel>(
        context,
        listen: false,
      ).getProfile(widget.phoneNumber);
      _hasFetchedProfile = true;
    } else {
      print("Phone number is empty!");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<GetProfileViewModel>(
          builder: (context, viewModel, child) {
            return RefreshIndicator(
              onRefresh: () => viewModel.getProfile(widget.phoneNumber),
              color: AppColors.primaryDark,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    isLoggedIn ?
                    _buildTopSection(viewModel):
                    _buildLoginRequiredHeader(),
                    const SizedBox(height: 20),
                    _buildMenuSection(
                      viewModel.profile?.result?.first ??
                          Result(username: "", number: "", id: 0, walletBalance: 0, referralcode: ""),
                    ),
                    const SizedBox(height: kBottomNavigationBarHeight + 30),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopSection(GetProfileViewModel viewModel) {
    if (viewModel.isLoading) {
      return _buildShimmerHeader();
    }

    if (viewModel.error != null ||
        viewModel.profile?.result == null ||
        viewModel.profile!.result!.isEmpty) {
      return _buildErrorHeader();
    }

    final user = viewModel.profile!.result!.first;
    return _buildProfileHeader(user);
  }
  Widget _buildLoginRequiredHeader() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.lightSage.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryDark, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon Section
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark.withOpacity(0.1),
                  AppColors.lightSage.withOpacity(0.2),
                ],
              ),
              border: Border.all(
                color: AppColors.primaryDark.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.login_rounded,
              size: 40,
              color: AppColors.primaryDark.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 20),

          // Main Message
          Text(
            "Login Required",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 24),

          // Login Button
          Container(
            width: double.infinity,
            height: 50,
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primaryDark.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                        (route) => false,
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Login Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

// 🔧 NEW shimmer header (only header, no menu here)
  Widget _buildShimmerHeader() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightSage.withOpacity(0.1),
      highlightColor: AppColors.lightSage.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryDark, width: 2),
          ),
        ),
      ),
    );
  }

// 🔧 NEW error header (compact error widget)
  Widget _buildErrorHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryDark, width: 2),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.error_outline_rounded,
          size: 40,
          color: AppColors.primaryDark.withOpacity(0.6),
        ),
      ),
    );
  }




  Widget _buildProfileHeader(Result user) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFC2CE9A),
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(color: AppColors.primaryDark, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightSage.withOpacity(0.2),
                  AppColors.lightSage.withOpacity(0.1),
                ],
              ),
              border: Border.all(color: AppColors.primaryDark, width: 2),
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
                  user.username ?? l10n.unknown,
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
                  user.number ?? '_',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDark.withOpacity(0.7),
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
                l10n.walletBalance,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark.withOpacity(0.1),
                      AppColors.primaryDark.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryDark.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primaryDark,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user.walletBalance ?? 0} ₹',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.primaryDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(Result user) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryDark, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            l10n.addAmountAndGetPlans,
            Icons.add_card_rounded,
            l10n,
            hasNewBadge: true,
            onTap: () async {
              String? phoneNumber = await SharedPrefHelper.getPhoneNumber();
              isLoggedIn ?
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openSubscription(phoneNumber!)
              :showLoginRequiredDialog(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.getVerifiedYourPashu,
            Icons.verified_user_rounded,
            l10n,
            hasNewBadge: true,
            onTap: () {
              isLoggedIn?
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openVerifiedPashu():
                  showLoginRequiredDialog(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.withdrawBalance,
            Icons.account_balance_rounded,
            l10n,
            hasNewBadge: true,
            onTap: () {
              final nav = Provider.of<NavigationController>(
                context,
                listen: false,
              );
              isLoggedIn?
              nav.openWithdraw(user.number!, user.id!.toString()):
                  showLoginRequiredDialog(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.myTransaction,
            Icons.receipt_long_rounded,
            l10n,
            onTap: () {
              isLoggedIn?
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openTransaction():
                  showLoginRequiredDialog(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.editProfile,
            Icons.edit_rounded,
            l10n,
            onTap: () {
              isLoggedIn?
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openEditProfile(user):
                  showLoginRequiredDialog(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.yourListedPashu,
            Icons.pets_rounded,
            l10n,
            onTap: () {
              isLoggedIn?
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openListedPashu():
                  showLoginRequiredDialog(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.soldOutPashuHistory,
            Icons.history_rounded,
            l10n,
            onTap: () {
              isLoggedIn?
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openSoldOutHistory():
                  showLoginRequiredDialog(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.referralCode,
            Icons.share_rounded,
            l10n,
            onTap: () {
              isLoggedIn?
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openReferral(user.referralcode ?? '', user.username!):
                  showLoginRequiredDialog(context);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.termsAndPrivacy,
            Icons.privacy_tip_rounded,
            l10n,
            onTap: () {
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openTermsPrivacy();
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.contactUs,
            Icons.contact_support_rounded,
            l10n,
            onTap: () {
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openContactUs();
            },
          ),
         if(isLoggedIn)...[
           _buildDivider(),
           _buildMenuItem(
             l10n.logout,
             Icons.logout_rounded,
             l10n,
             isLogout: true,
             onTap: () {
               _showLogoutDialog();
             },
           ),
           _buildDivider(),
           _buildMenuItem(
             "Delete Account", // You can use l10n if you add translation
             Icons.delete_forever_rounded,
             l10n,
             isLogout: true,
             onTap: () {
               _showDeleteDialog(user.number ?? "");
             },
           ),
         ]

        ],
      ),
    );
  }

  void _showDeleteDialog(String number) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red, width: 2),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Delete Account",
                style: AppTextStyles.heading.copyWith(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            "This will permanently delete your account and all associated data. Are you sure?",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark.withOpacity(0.8),
            ),
          ),
          actions: [
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
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);


                try {
                  final url = Uri.parse("https://pashuparivar.com/api/deleteUser/:$number");
                  final response = await http.delete(url, headers: {"Content-Type": "application/json"});
                  print(response.body);

                  if (!mounted) return;

                  if (response.statusCode == 200) {
                    await SharedPrefHelper.clearUserDetails();
                    messenger.showSnackBar(
                      const SnackBar(content: Text("Account deleted successfully")),
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => SplashScreen()),
                          (route) => false,
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(content: Text("Error deleting account (${response.statusCode})")),
                    );
                  }
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }

              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }


  Widget _buildMenuItem(
    String title,
    IconData icon,
    AppLocalizations l10n, {
    bool hasNewBadge = false,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isLogout
                            ? [
                              Colors.red.withOpacity(0.1),
                              Colors.red.withOpacity(0.05),
                            ]
                            : [
                              AppColors.primaryDark.withOpacity(0.1),
                              AppColors.primaryDark.withOpacity(0.05),
                            ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isLogout
                            ? Colors.red.withOpacity(0.3)
                            : AppColors.primaryDark.withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  icon,
                  color: isLogout ? Colors.red : AppColors.primaryDark,
                  size: 20,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isLogout ? Colors.red : AppColors.primaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              if (hasNewBadge) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    l10n.newBadge,
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
                color:
                    isLogout
                        ? Colors.red.withOpacity(0.6)
                        : AppColors.primaryDark.withOpacity(0.6),
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
      color: AppColors.primaryDark.withOpacity(0.1),
    );
  }

  void _showLogoutDialog() {
    final l10n = AppLocalizations.of(context)!;

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
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.logout,
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.areYouSureLogout,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark.withOpacity(0.8),
            ),
          ),
          actions: [
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
            ElevatedButton(
              onPressed: () async {
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }




}
