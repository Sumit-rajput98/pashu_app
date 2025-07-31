// navigation_controller.dart
import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 2; // Default to Home
  bool _isProfileOpen = false;

  int get selectedIndex => _selectedIndex;
  bool get isProfileOpen => _isProfileOpen;

  int get stackIndex => _isProfileOpen ? 5 : _selectedIndex;

  void changeTab(int index) {
    _isProfileOpen = false;
    _selectedIndex = index;
    notifyListeners();
  }

  void openProfile() {
    _isProfileOpen = true;
    notifyListeners();
  }

  void closeProfile() {
    _isProfileOpen = false;
    notifyListeners();
  }

  void goToBuy() => changeTab(0);
  void goToSell() => changeTab(1);
  void goToHome() => changeTab(2);
  void goToWishlist() => changeTab(3);
  void goToInvest() => changeTab(4);
}
