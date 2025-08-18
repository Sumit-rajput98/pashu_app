import 'package:flutter/material.dart';
import 'package:pashu_app/view/auth/login_screen.dart';

import '../../core/language_helper.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  // ✅ Set English as the default selected language
  String? selectedLanguage = 'en';

  static const languageOptions = [
    {'id': 'en', 'label': 'English'},
    {'id': 'hi', 'label': 'हिन्दी'},
    {'id': 'te', 'label': 'తెలుగు'},
    {'id': 'ml', 'label': 'മലയാളം'},
    {'id': 'kn', 'label': 'ಕನ್ನಡ'},
    {'id': 'ta', 'label': 'தமிழ்'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E4A59),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0DA),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // Scrollable list of 4 visible items
                SizedBox(
                  height: 200, // 4 items × 50 height each
                  child: ListView.builder(
                    itemCount: languageOptions.length,
                    itemBuilder: (context, index) {
                      final lang = languageOptions[index];
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
                            color: selectedLanguage == lang['id']
                                ? const Color(0xFFB4D5A6)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            lang['label']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: selectedLanguage == lang['id']
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
                    backgroundColor: selectedLanguage != null
                        ? const Color(0xFF1E4A59)
                        : Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: selectedLanguage == null
                      ? null
                      : () async {
                    await LanguageHelper.setLocale(selectedLanguage!);
                    final locale = Locale(selectedLanguage!);
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Localizations.override(
                          context: context,
                          locale: locale,
                          child: LoginScreen(),
                        ),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}