import 'package:flutter/material.dart';
import 'package:pashu_app/view/auth/login_screen.dart';
import 'package:pashu_app/view_model/AuthVM/request_otp_view_model.dart';
import 'package:pashu_app/view_model/AuthVM/verify_otp_view_model.dart';
import 'package:pashu_app/view_model/pashuVM/add_to_wishlist_view_model.dart';
import 'package:pashu_app/view_model/pashuVM/all_pashu_view_model.dart';
import 'package:pashu_app/view_model/pashuVM/wishlist_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RequestOtpViewModel()),
        ChangeNotifierProvider(create: (_) => VerifyOtpViewModel()),
        ChangeNotifierProvider(create: (_) => AllPashuViewModel()),
        ChangeNotifierProvider(create: (_) => AddToWishlistViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: const LoginScreen());
  }
}
