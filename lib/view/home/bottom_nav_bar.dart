import 'package:flutter/material.dart';
import 'package:pashu_app/core/app_colors.dart';
import 'package:pashu_app/view/buy/buy_screen.dart';
import 'package:pashu_app/view/buy/wishlist_screen.dart';
import 'package:pashu_app/view/home/home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomBottomNavScreen extends StatefulWidget {
  const CustomBottomNavScreen({super.key});

  @override
  State<CustomBottomNavScreen> createState() => _CustomBottomNavScreenState();
}

class _CustomBottomNavScreenState extends State<CustomBottomNavScreen> {
  int _selectedIndex = 2; // Default is Home

  final List<Widget> _pages = [
    BuyPage(),
    Center(child: Text("Sell Page")),
    HomeScreen(),
    WishlistPage(),
    Center(child: Text("Invest Page")),
  ];

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 2) {
      setState(() => _selectedIndex = 2);
      return false; // don't exit app
    }
    return true; // exit app
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFC2CE9A), // custom green shade
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) => _buildNavItem(index)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
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
      'Home', // fallback, not in ARB
      'Wishlist', // fallback, not in ARB
      localizations.investInFarming,
    ];

    bool isSelected = index == _selectedIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
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
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            // NEW badge for "Invest"
            // if (index == 4)
            //   Positioned(
            //     top: 0,
            //     right: 18,
            //     child: Container(
            //       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            //       decoration: BoxDecoration(
            //         color: Colors.grey[800],
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //       child: const Text(
            //         "NEW",
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 8,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
