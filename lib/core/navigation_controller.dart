// Create a new file: navigation_controller.dart
import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 2; // Default to Home

  int get selectedIndex => _selectedIndex;

  void changeTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void goToBuy() => changeTab(0);
  void goToSell() => changeTab(1);
  void goToHome() => changeTab(2);
  void goToWishlist() => changeTab(3);
  void goToInvest() => changeTab(4);
}
