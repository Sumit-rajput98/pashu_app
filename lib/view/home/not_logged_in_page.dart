import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pashu_app/view/auth/login_screen.dart';
import 'package:pashu_app/view/home/language_selection_screen.dart';
import '../../core/app_colors.dart';

class NotLoggedInPage extends StatelessWidget {
  const NotLoggedInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final isSmallDevice = screenHeight < 700 || screenWidth < 400;
    final containerSize = isSmallDevice ? 120.0 : 150.0;
    final iconSize = isSmallDevice ? 60.0 : 80.0;
    final titleFontSize = isSmallDevice ? 24.0 : 28.0;
    final subtitleFontSize = isSmallDevice ? 18.0 : 20.0;
    final descriptionFontSize = isSmallDevice ? 14.0 : 16.0;
    final buttonHeight = isSmallDevice ? 50.0 : 60.0;
    final buttonFontSize = isSmallDevice ? 18.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallDevice ? 16.0 : 24.0,
                    vertical: isSmallDevice ? 16.0 : 24.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Add some top spacing for very small devices
                      if (isSmallDevice) SizedBox(height: screenHeight * 0.05),

                      // App Logo or Icon
                      Container(
                        width: containerSize,
                        height: containerSize,
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
                            width: isSmallDevice ? 2 : 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withOpacity(0.1),
                              blurRadius: isSmallDevice ? 15 : 20,
                              offset: Offset(0, isSmallDevice ? 6 : 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_off_rounded,
                          size: iconSize,
                          color: AppColors.primaryDark.withOpacity(0.7),
                        ),
                      ),

                      SizedBox(height: isSmallDevice ? 24 : 40),

                      // Main Title
                      Text(
                        "Welcome to Pashu App!",
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isSmallDevice ? 12 : 16),

                      // Subtitle
                      Text(
                        "You didn't login yet!",
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isSmallDevice ? 8 : 12),

                      // Description
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallDevice ? 8.0 : 0.0,
                        ),
                        child: Text(
                          "Please log in to access your profile, manage your pashu listings, and enjoy all the features of our app.",
                          style: TextStyle(
                            fontSize: descriptionFontSize,
                            color: AppColors.primaryDark.withOpacity(0.6),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: isSmallDevice ? 30 : 50),

                      // Login Button
                      Container(
                        width: double.infinity,
                        height: buttonHeight,
                        constraints: BoxConstraints(
                          maxWidth: isSmallDevice ? double.infinity : 400,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primaryDark.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(isSmallDevice ? 16 : 20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withOpacity(0.4),
                              blurRadius: isSmallDevice ? 10 : 15,
                              offset: Offset(0, isSmallDevice ? 4 : 8),
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
                            borderRadius: BorderRadius.circular(isSmallDevice ? 16 : 20),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallDevice ? 16 : 24,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(isSmallDevice ? 6 : 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.login_rounded,
                                      color: Colors.white,
                                      size: isSmallDevice ? 20 : 24,
                                    ),
                                  ),
                                  SizedBox(width: isSmallDevice ? 12 : 16),
                                  Text(
                                    "Login Now",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom spacing for small devices
                      if (isSmallDevice) SizedBox(height: screenHeight * 0.05),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
