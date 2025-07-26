import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import 'package:pashu_app/view/auth/register_screen.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../core/custom_text_field.dart';
import '../../core/primary_button.dart';
import '../../core/secandory_button.dart';
import '../../core/top_snacbar.dart';
import '../../view_model/AuthVM/request_otp_view_model.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!; // Add this line
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackgroundDecorations(),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: mediaQuery.size.height -
                    mediaQuery.padding.top -
                    mediaQuery.padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLoginCard(localizations),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BackgroundPainter(),
      ),
    );
  }

  Widget _buildLoginCard(AppLocalizations localizations) {
    return Hero(
      tag: 'login_card',
      child: Material(
        color: Colors.transparent,
        child: Consumer<RequestOtpViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showCustomTopSnackbar(
                  context: context,
                  message: viewModel.errorMessage!,
                  isError: true,
                );
              });
            }

            if (viewModel.response?.success == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OTPScreen(
                      phoneNumber: _phoneController.text,
                    ),
                  ),
                );
                viewModel.resetState();
                _showCustomTopSnackbar(
                  context: context,
                  message: localizations.otpSentTo.toString().replaceAll('{phoneNumber}', _phoneController.text),
                  isError: false,
                );
              });
            }

            return Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.lightSage,
                    AppColors.lightSage.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: AppColors.lightSage.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width > 600 ? 40.0 : 32.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo section
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.lightSage.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: AppLogo(
                                size: MediaQuery.of(context).size.width > 600 ? 120 : 100,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sign in header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.phone_android_rounded,
                                  color: AppColors.primaryDark,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  localizations.signIn,
                                  style: AppTextStyles.heading.copyWith(
                                    fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            localizations.enterPhoneNumberToContinue,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryDark.withOpacity(0.7),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Phone input section
                          _buildPhoneInputSection(localizations),

                          const SizedBox(height: 28),

                          // Get OTP button
                          PrimaryButton(
                            text: localizations.sendOTP,
                            onPressed: () => viewModel.isLoading ? null : _handleGetOTP(viewModel, localizations),
                            isLoading: viewModel.isLoading,
                          ),

                          const SizedBox(height: 28),

                          // OR divider
                          _buildOrDivider(localizations),

                          const SizedBox(height: 20),

                          // Register link
                          Center(
                            child: SecondaryButton(
                              text: localizations.dontHaveAccount,
                              onPressed: _handleRegister,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhoneInputSection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.phoneNumber,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            // Country code container
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryDark.withOpacity(0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🇮🇳',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+91',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Phone number input
            Expanded(
              child: CustomTextField(
                controller: _phoneController,
                hintText: localizations.enterPhoneNumber,
                keyboardType: TextInputType.phone,
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: AppColors.primaryDark.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrDivider(AppLocalizations localizations) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primaryDark.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              localizations.or,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _validatePhone(BuildContext context, String? value, AppLocalizations localizations) {
    if (value == null || value.isEmpty) {
      _showCustomTopSnackbar(
        context: context,
        message: localizations.phoneNumberRequired,
        isError: true,
      );
      return false;
    }
    if (value.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      _showCustomTopSnackbar(
        context: context,
        message: localizations.enterValidPhoneNumber,
        isError: true,
      );
      return false;
    }
    return true;
  }

  void _handleGetOTP(RequestOtpViewModel viewModel, AppLocalizations localizations) async {
    final isValid = _validatePhone(context, _phoneController.text, localizations);
    if (!isValid) return;

    HapticFeedback.lightImpact();
    await viewModel.requestOtp(_phoneController.text);
  }

  void _handleRegister() {
    HapticFeedback.selectionClick();
    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
  }

  void _showCustomTopSnackbar({
    required BuildContext context,
    required String message,
    required bool isError,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => TopSnackbar(
        message: message,
        isError: isError,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
