import 'package:flutter/material.dart';
import 'package:pashu_app/view/home/not_logged_in_page.dart';
import 'package:pashu_app/view/home/pashu_insurance_form.dart';
import 'package:pashu_app/view/home/race_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:pashu_app/core/app_colors.dart';
import 'package:pashu_app/view/auth/profile_page.dart';
import 'package:pashu_app/view/buy/buy_screen.dart';
import 'package:pashu_app/view/buy/wishlist_screen.dart';
import 'package:pashu_app/view/home/home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pashu_app/view/invest/invest_page.dart';
import 'package:pashu_app/view/sell/sell_page.dart';
import '../../core/language_helper.dart';
import '../../core/locale_helper.dart';
import '../../core/navigation_controller.dart';
import '../../core/shared_pref_helper.dart';
import 'package:pashu_app/view/custom_app_bar.dart';
import '../../login_dialog.dart';
import '../buy/animal_detail_page.dart';
import '../invest/invest_details_page.dart';
import '../invest/my_investment_page.dart';
import '../invest/projects_list_page.dart';
import '../profile/contact_us_page.dart';
import '../profile/edit_profile_page.dart';
import '../profile/listed_pashu_page.dart';
import '../profile/referal_page.dart';
import '../profile/sold_out_page.dart';
import '../profile/subscription_page.dart';
import '../profile/terms_and_policy_page.dart';
import '../profile/transaction_page.dart';
import '../profile/verify_pashu_screen.dart';
import '../profile/withdraw_page.dart';
import 'animal_loan_page.dart';
import 'live_race_page.dart';
// Add your NavigationController import

class CustomBottomNavScreen extends StatefulWidget {
  const CustomBottomNavScreen({super.key});

  @override
  State<CustomBottomNavScreen> createState() => _CustomBottomNavScreenState();
}

class _CustomBottomNavScreenState extends State<CustomBottomNavScreen> {
  String phone = '';
  void _showLanguageDialog(BuildContext context) async {
    String? selectedLanguage = await LanguageHelper.getLocale();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFE9F0DA),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.selectLanguage,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: LanguageHelper.languageOptions.length,
                        itemBuilder: (context, index) {
                          final lang = LanguageHelper.languageOptions[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLanguage = lang['id'];
                              });
                            },
                            child: Container(
                              height: 48,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    selectedLanguage == lang['id']
                                        ? const Color(0xFFB4D5A6)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lang['label']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      selectedLanguage == lang['id']
                                          ? const Color(0xFF1E4A59)
                                          : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedLanguage != null
                                ? const Color(0xFF1E4A59)
                                : Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed:
                          selectedLanguage == null
                              ? null
                              : () async {
                                if (!context.mounted) return;
                                Provider.of<LocaleProvider>(
                                  context,
                                  listen: false,
                                ).setLocale(selectedLanguage!);
                                Navigator.of(context).pop();
                              },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 10,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.ok,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void initializeUserData() async {
    phone = await SharedPrefHelper.getPhoneNumber() ?? '';


    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initializeUserData();
  }

  // custom_bottom_nav_screen.dart

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, navController, child) {
        final List<Widget> pages = [
          const BuyPage(), // 0
          SellPashuScreen(phoneNumber: phone), // 1
          HomeScreen(phoneNumber: phone), // 2
          const WishlistPage(), // 3
          const InvestPage(), // 4
          // 5 - Profile

          ProfilePage(
            phoneNumber: phone,
            onBack: () => navController.closeProfile(),
          )
         ,

          // 6 - My Investment
          MyInvestmentPage(onBack: () => navController.closeMyInvestment()),

          // 7 - Animal Detail
          if (navController.selectedAnimal != null &&
              navController.selectedDistance != null)
            AnimalDetailPage(
              pashu: navController.selectedAnimal!,
              distance: navController.selectedDistance!,
              onBack: () => navController.closeAnimalDetail(),
            )
          else
            const SizedBox.shrink(),

          // 8 - Subscription
          if (navController.isSubscriptionOpen)
            SubscriptionPage(
              phoneNumber: navController.subscriptionPhone!,
              onBack: () => navController.closeSubscription(),
            )
          else
            const SizedBox.shrink(),

          // 9 - Verified Pashu
          if (navController.isVerifiedPashuOpen)
            VerifiedPashuScreen(
              onBack: () => navController.closeVerifiedPashu(),
            )
          else
            const SizedBox.shrink(),

          // 10 - Transactions
          if (navController.isTransactionOpen)
            TransactionPage(onBack: () => navController.closeTransaction())
          else
            const SizedBox.shrink(),

          // 11 - Edit Profile
          if (navController.isEditProfileOpen &&
              navController.userProfileForEdit != null)
            EditProfilePage(
              userProfile: navController.userProfileForEdit!,
              phoneNumber: navController.userProfileForEdit!.number!,
              onBack: () => navController.closeEditProfile(),
            )
          else
            const SizedBox.shrink(),

          // 12 - Listed Pashu
          if (navController.isListedPashuOpen)
            ListedPashuPage(onBack: () => navController.closeListedPashu())
          else
            const SizedBox.shrink(),

          // 13 - Sold Out History
          if (navController.isSoldOutHistoryOpen)
            SoldOutHistoryPage(
              onBack: () => navController.closeSoldOutHistory(),
            )
          else
            const SizedBox.shrink(),

          // 14 - Referral
          if (navController.isReferralOpen)
            ReferralPage(
              referralCode: navController.referralCode ?? '',
              username: navController.referralUsername ?? '',
              onBack: () => navController.closeReferral(),
            )
          else
            const SizedBox.shrink(),

          // 15 - Terms & Privacy
          if (navController.isTermsPrivacyOpen)
            TermsPrivacyPage(onBack: () => navController.closeTermsPrivacy())
          else
            const SizedBox.shrink(),

          // 16 - Contact Us
          if (navController.isContactUsOpen)
            ContactUsPage(onBack: () => navController.closeContactUs())
          else
            const SizedBox.shrink(),

          // 17 - Withdraw Page
          if (navController.isWithdrawOpen)
            WithdrawPage(
              phoneNumber: navController.withdrawPhone!,
              userId: navController.withdrawUserId!,
              onBack: () => navController.closeWithdraw(),
            )
          else
            const SizedBox.shrink(),

          // 18 - Projects List
          if (navController.isProjectsListOpen &&
              navController.projectsList.isNotEmpty)
            ProjectsListPage(
              projects: navController.projectsList,
              onBack: () => navController.closeProjectsList(),
            )
          else
            const SizedBox.shrink(),

          // 19 - Invest Details
          if (navController.isInvestDetailsOpen &&
              navController.selectedInvestProject != null)
            InvestDetailsPage(
              project: navController.selectedInvestProject!,
              onBack: () => navController.closeInvestDetails(),
            )
          else
            const SizedBox.shrink(),

          // 20 - Pashu Insurance
          if (navController.isPashuInsuranceOpen)
            const PashuInsuranceFormPage()
          else
            const SizedBox.shrink(),

          // 21 - Live Race
          if (navController.isLiveRaceOpen)
            const LiveRacePage()
          else
            const SizedBox.shrink(),

          // 22 - Pashu Loan
          if (navController.isPashuLoanOpen)
            const PashuLoanFormPage()
          else
            const SizedBox.shrink(),

          // 23 - Race Detail
          if (navController.isRaceDetailOpen &&
              navController.selectedRaceCategory != null)
            RaceDetailPage(category: navController.selectedRaceCategory!)
          else
            const SizedBox.shrink(),
        ];

        return WillPopScope(
          onWillPop: () async {
            if (navController.isInvestDetailsOpen) {
              navController.closeInvestDetails();
              return false;
            }
            if (navController.isProjectsListOpen) {
              navController.closeProjectsList();
              return false;
            }
            if (navController.isWithdrawOpen) {
              navController.closeWithdraw();
              return false;
            }
            if (navController.isContactUsOpen) {
              navController.closeContactUs();
              return false;
            }
            if (navController.isTermsPrivacyOpen) {
              navController.closeTermsPrivacy();
              return false;
            }
            if (navController.isReferralOpen) {
              navController.closeReferral();
              return false;
            }
            if (navController.isSoldOutHistoryOpen) {
              navController.closeSoldOutHistory();
              return false;
            }
            if (navController.isListedPashuOpen) {
              navController.closeListedPashu();
              return false;
            }
            if (navController.isEditProfileOpen) {
              navController.closeEditProfile();
              return false;
            }
            if (navController.isTransactionOpen) {
              navController.closeTransaction();
              return false;
            }
            if (navController.isVerifiedPashuOpen) {
              navController.closeVerifiedPashu();
              return false;
            }
            if (navController.isSubscriptionOpen) {
              navController.closeSubscription();
              return false;
            }
            if (navController.isAnimalDetailOpen) {
              navController.closeAnimalDetail();
              return false;
            }
            if (navController.isMyInvestmentOpen) {
              navController.closeMyInvestment();
              return false;
            }
            if (navController.isProfileOpen) {
              navController.closeProfile();
              return false;
            }

            if (navController.isPashuInsuranceOpen) {
              navController.closePashuInsurance();
              return false;
            }
            if (navController.isLiveRaceOpen) {
              navController.closeLiveRace();
              return false;
            }
            if (navController.isPashuLoanOpen) {
              navController.closePashuLoan();
              return false;
            }

            if (navController.isRaceDetailOpen) {
              navController.closeRaceDetail();
              return false;
            }

            // If user is not on Home tab, go to Home
            if (navController.selectedIndex != 2) {
              navController.goToHome();
              return false;
            }

            return true;
          },

          child: Scaffold(
            appBar: CustomAppBar(
              onLanguageTap: () => _showLanguageDialog(context),
              onProfileTap: () {
                navController.openProfile();
              },
            ),
            body: IndexedStack(
              index: navController.stackIndex,
              children: pages,
            ),
            extendBody: true,
            bottomNavigationBar: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                decoration: const BoxDecoration(color: Color(0xFFC2CE9A)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      5,
                      (index) => _buildNavItem(index, navController),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, NavigationController navController) {
    const icons = [
      "assets/buy-icon.png",
      "assets/sell-icon.png",
      "assets/home-icon.png",
      "assets/wishlist-icon.png",
      "assets/money_invest.png",
    ];

    final localizations = AppLocalizations.of(context)!;
    final labels = [
      localizations.buyAnimal,
      localizations.sellAnimal,
      localizations.homeScreen,
      localizations.wishlist,
      localizations.investInFarming,
    ];

    bool isSelected =
        !navController.isProfileOpen && index == navController.selectedIndex;

    return GestureDetector(
      onTap: () async {
        // Block Wishlist (3) and Invest (4) if not logged in
        if ((index == 3 ) &&
            !(await SharedPrefHelper.isLoggedIn())) {
          showLoginRequiredDialog(context);
          return;
        }

        navController.changeTab(index);
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              icons[index],
              height: 24,
              color: isSelected ? AppColors.primaryDark : Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              labels[index],
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primaryDark : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
