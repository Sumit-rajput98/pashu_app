import 'package:flutter/material.dart';
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
          const BuyPage(),
          SellPashuScreen(phoneNumber: phone),
          HomeScreen(phoneNumber: phone),
          const WishlistPage(),
          const InvestPage(),
          ProfilePage(
            phoneNumber: phone,
            onBack: () => navController.closeProfile(),
          ),
        ];

        return WillPopScope(
          onWillPop: () async {
            if (navController.isProfileOpen) {
              navController.closeProfile();
              return false;
            }
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

    bool isSelected = !navController.isProfileOpen && index == navController.selectedIndex;

    return GestureDetector(
      onTap: () => navController.changeTab(index),
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
