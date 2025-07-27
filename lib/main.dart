import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'core/language_helper.dart';
import 'core/locale_helper.dart';

import 'core/navigation_controller.dart';

import 'demo.dart';
import 'view/home/splash_screen.dart';
import 'view_model/AuthVM/get_counter_view_model.dart';
import 'view_model/AuthVM/get_profile_view_model.dart';
import 'view_model/AuthVM/request_otp_view_model.dart';
import 'view_model/AuthVM/update_profile_view_model.dart';
import 'view_model/AuthVM/verify_otp_view_model.dart';
import 'view_model/pashuVM/add_to_wishlist_view_model.dart';
import 'view_model/pashuVM/all_pashu_view_model.dart';
import 'view_model/pashuVM/animal_loan_view_model.dart';
import 'view_model/pashuVM/get_category_view_model.dart';
import 'view_model/pashuVM/get_invest_view_model.dart';
import 'view_model/pashuVM/pashu_insurance_view_model.dart';
import 'view_model/pashuVM/unlock_counter_provider.dart';
import 'view_model/pashuVM/wishlist_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppInitializer());
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

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
        ChangeNotifierProvider(create: (_) => AnimalInsuranceViewModel()),
        ChangeNotifierProvider(create: (_) => AnimalLoanViewModel()),
        ChangeNotifierProvider(create: (_) => UnlockContactProvider()),
        ChangeNotifierProvider(create: (_) => GetInvestViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..loadSavedLocale()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pashu App',
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('te'),
        Locale('ml'),
        Locale('kn'),
        Locale('ta'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
