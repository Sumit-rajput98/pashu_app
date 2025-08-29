import 'package:flutter/material.dart';
import 'package:pashu_app/view/home/language_selection_screen.dart';
import '../../core/app_colors.dart'; // Make sure to import your app colors

Future<void> showLoginRequiredDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // user must choose
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.primaryDark,
            width: 2,
          ),
        ),
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                AppColors.lightSage.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Close icon with Pashu app styling
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryDark.withOpacity(0.3),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.primaryDark.withOpacity(0.7),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Icon with Pashu app theme
                Container(
                  width: 80,
                  height: 80,
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
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.login_rounded,
                    size: 40,
                    color: AppColors.primaryDark.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 20),

                // Title with Pashu app styling
                Text(
                  "Login Required",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 12),

                // Message with Pashu app styling
                Text(
                  "You don't have an account yet.\nPlease login first.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryDark.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // Login button with Pashu app theme
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryDark,
                        AppColors.primaryDark.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(ctx).pop(); // close dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SelectLanguageScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.login_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Login Now",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Cancel button (optional) with subtle styling
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryDark.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(
                    "Maybe Later",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
