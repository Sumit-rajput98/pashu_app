import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/shared_pref_helper.dart';
// Make sure the path is correct
import 'bottom_nav_bar.dart';

import 'language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  void _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    bool loggedIn = await SharedPrefHelper.isLoggedIn();

    if (!mounted) return; // Ensure the widget is still in the tree

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => loggedIn
            ? const CustomBottomNavScreen()
            : const SelectLanguageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Image.asset(
            'assets/pashu_banner.jpg',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
