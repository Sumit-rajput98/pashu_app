import 'package:flutter/material.dart';
import 'package:pashu_app/view/auth/login_screen.dart';
import 'package:pashu_app/view/home/splash_screen.dart';
import 'package:pashu_app/view/profile/edit_profile_page.dart';
import 'package:pashu_app/view/profile/sold_out_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../core/navigation_controller.dart';
import '../../core/shared_pref_helper.dart';
import '../../model/auth/profile_model.dart';
import '../../view_model/AuthVM/get_profile_view_model.dart';
import '../profile/contact_us_page.dart';
import '../profile/listed_pashu_page.dart';
import '../profile/referal_page.dart';
import '../profile/subscription_page.dart';
import '../profile/terms_and_policy_page.dart';
import '../profile/transaction_page.dart';
import '../profile/verify_pashu_screen.dart';
import '../profile/withdraw_page.dart';

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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    print("ProfilePage initState called");
    _fetchProfileData();
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
                    _buildTopSection(viewModel),
                    const SizedBox(height: 20),
                    _buildMenuSection(
                      viewModel.profile?.result?.first ??
                          Result(username: "", number: "", id: 0, walletBalance: 0, referralcode: ""),
                    ),
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


  // Widget _buildContent(GetProfileViewModel viewModel) {
  //   if (viewModel.isLoading) {
  //     return _buildShimmerContent();
  //   }
  //
  //   if (viewModel.error != null) {
  //     return _buildErrorWidget(viewModel);
  //   }
  //
  //   if (viewModel.profile?.result == null ||
  //       viewModel.profile!.result!.isEmpty) {
  //     return _buildEmptyWidget();
  //   }
  //
  //   final user = viewModel.profile!.result!.first;
  //   return _buildProfileContent(user);
  // }

  // Widget _buildShimmerContent() {
  //   return Shimmer.fromColors(
  //     baseColor: AppColors.lightSage.withOpacity(0.1),
  //     highlightColor: AppColors.lightSage.withOpacity(0.2),
  //     child: Padding(
  //       padding: const EdgeInsets.all(20),
  //       child: Column(
  //         children: [
  //           // Profile Header Shimmer
  //           Container(
  //             height: 140,
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(20),
  //               border: Border.all(color: AppColors.primaryDark, width: 2),
  //             ),
  //           ),
  //
  //           const SizedBox(height: 20),
  //
  //           // Menu Items Shimmer
  //           Container(
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(16),
  //               border: Border.all(color: AppColors.primaryDark, width: 2),
  //             ),
  //             child: Column(
  //               children: List.generate(
  //                 8,
  //                 (index) => Padding(
  //                   padding: const EdgeInsets.only(bottom: 1),
  //                   child: Container(
  //                     height: 60,
  //                     decoration: const BoxDecoration(color: Colors.white),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildProfileContent(Result user) {
  //   return Column(
  //     children: [
  //       // Profile Header Card (matching image style)
  //       _buildProfileHeader(user),
  //
  //       // Menu Section
  //       _buildMenuSection(user),
  //     ],
  //   );
  // }

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
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openSubscription(phoneNumber!);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.getVerifiedYourPashu,
            Icons.verified_user_rounded,
            l10n,
            hasNewBadge: true,
            onTap: () {
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openVerifiedPashu();
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
              nav.openWithdraw(user.number!, user.id!.toString());
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.myTransaction,
            Icons.receipt_long_rounded,
            l10n,
            onTap: () {
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openTransaction();
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.editProfile,
            Icons.edit_rounded,
            l10n,
            onTap: () {
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openEditProfile(user);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.yourListedPashu,
            Icons.pets_rounded,
            l10n,
            onTap: () {
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openListedPashu();
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.soldOutPashuHistory,
            Icons.history_rounded,
            l10n,
            onTap: () {
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openSoldOutHistory();
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            l10n.referralCode,
            Icons.share_rounded,
            l10n,
            onTap: () {
              Provider.of<NavigationController>(
                context,
                listen: false,
              ).openReferral(user.referralcode ?? '', user.username!);
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
        ],
      ),
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

  Widget _buildErrorWidget(GetProfileViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: CircularProgressIndicator(color: AppColors.primaryDark),
    );

    // return Container(
    //   padding: const EdgeInsets.all(40),
    //   child: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         Icon(
    //           Icons.error_outline_rounded,
    //           color: AppColors.primaryDark.withOpacity(0.5),
    //           size: 80,
    //         ),
    //         const SizedBox(height: 20),
    //         Text(
    //           l10n.failedToLoadProfile,
    //           style: AppTextStyles.heading.copyWith(
    //             color: AppColors.primaryDark,
    //             fontSize: 20,
    //           ),
    //         ),
    //         const SizedBox(height: 12),
    //         Text(
    //           viewModel.error ?? l10n.somethingWentWrong,
    //           style: AppTextStyles.bodyMedium.copyWith(
    //             color: AppColors.primaryDark.withOpacity(0.7),
    //             fontSize: 14,
    //           ),
    //           textAlign: TextAlign.center,
    //         ),
    //         const SizedBox(height: 30),
    //         ElevatedButton.icon(
    //           onPressed: () {
    //             viewModel.getProfile(widget.phoneNumber);
    //           },
    //           icon: const Icon(Icons.refresh_rounded),
    //           label: Text(l10n.retry),
    //           style: ElevatedButton.styleFrom(
    //             backgroundColor: AppColors.primaryDark,
    //             foregroundColor: Colors.white,
    //             padding: const EdgeInsets.symmetric(
    //               horizontal: 24,
    //               vertical: 12,
    //             ),
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(12),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildEmptyWidget() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              color: AppColors.primaryDark.withOpacity(0.5),
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noProfileFound,
              style: AppTextStyles.heading.copyWith(
                color: AppColors.primaryDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.profileInformationNotAvailable,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.7),
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
