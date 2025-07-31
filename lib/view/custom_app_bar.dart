import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pashu_app/core/app_colors.dart';
import 'package:pashu_app/view/auth/profile_page.dart';
import '../../core/language_helper.dart';
import '../../core/locale_helper.dart';
import '../../core/shared_pref_helper.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onLanguageTap;
  const CustomAppBar({Key? key, this.onProfileTap, this.onLanguageTap})
    : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
              Image.asset('assets/newlogo.png', height: 60),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF244B5C),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onLanguageTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF244B5C)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.languageShort,
                    style: const TextStyle(color: Color(0xFF244B5C)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onProfileTap,
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
    );
  }
}
