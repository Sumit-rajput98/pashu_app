import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../core/language_helper.dart';

import 'bottom_nav_bar.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  String? selectedLanguage;
  final PageController _pageController = PageController();

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
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
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
                const SizedBox(height: 20),

                // Vertical page view for language selection
                SizedBox(
                  height: 50,
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: languageOptions.length,
                    onPageChanged: (index) {
                      setState(() {
                        selectedLanguage = languageOptions[index]['id'];
                      });
                    },
                    itemBuilder: (context, index) {
                      final lang = languageOptions[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedLanguage = lang['id'];
                          });
                        },
                        child: Center(
                          child: Text(
                            lang['label']!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
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
                    // Save the selected locale
                    await LanguageHelper.setLocale(selectedLanguage!);

                    // Apply locale dynamically
                    final locale = Locale(selectedLanguage!);
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Localizations.override(
                          context: context,
                          locale: locale,
                          child: const CustomBottomNavScreen(),
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
