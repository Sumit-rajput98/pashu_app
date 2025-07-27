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

import '../../core/navigation_controller.dart';
import '../../core/shared_pref_helper.dart';
// Add your NavigationController import

class CustomBottomNavScreen extends StatefulWidget {
  const CustomBottomNavScreen({super.key});

  @override
  State<CustomBottomNavScreen> createState() => _CustomBottomNavScreenState();
}

class _CustomBottomNavScreenState extends State<CustomBottomNavScreen> {
  String phone = '';


  void initializeUserData() async {
    phone = await SharedPrefHelper.getPhoneNumber() ?? '';

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initializeUserData();
  }

  @override
  Widget build(BuildContext context) {
    // Only build pages if we have the required data


    return Consumer<NavigationController>(
      builder: (context, navController, child) {
        final List<Widget> pages = [
          const BuyPage(),
          SellPashuScreen(
            phoneNumber: phone,
            // Fallback to phone if userId not available
          ),
          const HomeScreen(),
          const WishlistPage(),
          const InvestPage(),
        ];

        return WillPopScope(
          onWillPop: () async {
            if (navController.selectedIndex != 2) {
              navController.goToHome();
              return false; // don't exit app
            }
            return true; // exit app
          },
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                flexibleSpace: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/newlogo.png',
                          height: 60,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Pashu Parivar',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF244B5C),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF244B5C)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'हि/E/ತ',
                            style: TextStyle(color: Color(0xFF244B5C)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            String? phoneNumber = await SharedPrefHelper.getPhoneNumber();
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                    phoneNumber: phoneNumber ?? '',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.account_circle,
                            size: 30,
                            color: Color(0xFF244B5C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: pages[navController.selectedIndex],
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFC2CE9A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) => _buildNavItem(index, navController)),
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
      'Home',
      'Wishlist',
      localizations.investInFarming,
    ];

    bool isSelected = index == navController.selectedIndex;

    return GestureDetector(
      onTap: () => navController.changeTab(index),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
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
          ],
        ),
      ),
    );
  }
}
