import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pashu_app/demo.dart';
import 'package:pashu_app/view/home/bottom_nav_bar.dart';
import 'package:pashu_app/view/home/splash_screen.dart';
import 'package:pashu_app/view_model/AuthVM/get_counter_view_model.dart';
import 'package:pashu_app/view_model/AuthVM/get_profile_view_model.dart';
import 'package:pashu_app/view_model/AuthVM/request_otp_view_model.dart';
import 'package:pashu_app/view_model/AuthVM/update_profile_view_model.dart';
import 'package:pashu_app/view_model/AuthVM/verify_otp_view_model.dart';
import 'package:pashu_app/view_model/pashuVM/add_to_wishlist_view_model.dart';
import 'package:pashu_app/view_model/pashuVM/all_pashu_view_model.dart';
import 'package:pashu_app/view_model/pashuVM/animal_loan_view_model.dart';
import 'package:pashu_app/view_model/pashuVM/get_category_view_model.dart';
import 'package:pashu_app/view_model/pashuVM/get_invest_view_model.dart';
import 'package:pashu_app/view_model/pashuVM/pashu_insurance_view_model.dart';
import 'package:pashu_app/view_model/pashuVM/unlock_counter_provider.dart';
import 'package:pashu_app/view_model/pashuVM/wishlist_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import 'core/language_helper.dart';
import 'core/navigation_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String savedLang = await LanguageHelper.getLocale();

  runApp(MyApp(savedLang: savedLang));
}

class MyApp extends StatelessWidget {
  final String savedLang;

  const MyApp({super.key, required this.savedLang});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RequestOtpViewModel()),
        ChangeNotifierProvider(create: (_) => VerifyOtpViewModel()),
        ChangeNotifierProvider(create: (_) => AllPashuViewModel()),
        ChangeNotifierProvider(create: (_) => AddToWishlistViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
        ChangeNotifierProvider(create: (_) => GetProfileViewModel()),
        ChangeNotifierProvider(create: (_) => GetCounterViewModel()),
        ChangeNotifierProvider(create: (_) => UpdateProfileViewModel()),
        ChangeNotifierProvider(create: (_) => SellPashuProvider()),
        ChangeNotifierProvider(create: (_) => GetCategoryViewModel()),
        ChangeNotifierProvider(
          create: (context) => NavigationController(),
          child: CustomBottomNavScreen(),
        ),
        ChangeNotifierProvider(create: (_) => AnimalInsuranceViewModel()),
        ChangeNotifierProvider(create: (_) => AnimalLoanViewModel()),
        ChangeNotifierProvider(create: (_) => UnlockContactProvider()),
        ChangeNotifierProvider(create: (_) => GetInvestViewModel()),
      ],
      child: MaterialApp(
        title: 'Pashu App',
        locale: Locale(savedLang),
        supportedLocales: const [
          Locale('en'), Locale('hi'), Locale('te'),
          Locale('ml'), Locale('kn'), Locale('ta'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
