import 'package:flutter/material.dart';
import 'package:pashu_app/core/app_colors.dart';
import 'package:pashu_app/view/auth/profile_page.dart';
import '../../core/language_helper.dart';
import '../../core/locale_helper.dart';
import '../../core/shared_pref_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onLanguageTap;

  const CustomAppBar({Key? key, this.onProfileTap, this.onLanguageTap})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // More granular breakpoints
    final isVerySmallScreen = screenWidth < 320;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth < 400;

    // Calculate responsive values
    double logoHeight = isVerySmallScreen ? 40 : (isSmallScreen ? 45 : (isMediumScreen ? 50 : 60));

    // Adjust font size based on both screen size and system text scale
    double baseFontSize = isVerySmallScreen ? 14 : (isSmallScreen ? 16 : (isMediumScreen ? 18 : 22));
    double titleFontSize = baseFontSize / textScaleFactor.clamp(1.0, 1.3);

    double languageButtonPadding = isVerySmallScreen ? 4 : (isSmallScreen ? 6 : 8);
    double iconSize = isVerySmallScreen ? 22 : (isSmallScreen ? 24 : 30);
    double horizontalPadding = isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12);
    double spacingBetweenElements = isVerySmallScreen ? 2 : (isSmallScreen ? 4 : 8);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              // Logo with flexible sizing
              Image.asset(
                'assets/newlogo.png',
                height: logoHeight,
                width: logoHeight, // Keep aspect ratio
                fit: BoxFit.contain,
              ),

              SizedBox(width: spacingBetweenElements),

              // App Title with Flexible widget and smart truncation
              Expanded(
                flex: isVerySmallScreen ? 2 : 3, // Give more space on larger screens
                child: Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF244B5C),
                    letterSpacing: isVerySmallScreen ? -0.5 : 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(width: spacingBetweenElements),

              // Language Button with more compact design
              GestureDetector(
                onTap: onLanguageTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: languageButtonPadding,
                    vertical: isVerySmallScreen ? 3 : (isSmallScreen ? 4 : 6),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF244B5C),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(isVerySmallScreen ? 4 : 6),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.languageShort,
                    style: TextStyle(
                      color: const Color(0xFF244B5C),
                      fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(width: spacingBetweenElements),

              // Profile Icon with compact design
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  padding: EdgeInsets.all(isVerySmallScreen ? 3 : (isSmallScreen ? 4 : 6)),
                  child: Icon(
                    Icons.account_circle,
                    size: iconSize,
                    color: const Color(0xFF244B5C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
