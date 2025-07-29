import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import 'package:pashu_app/view/auth/otp_screen_register.dart';
import 'package:pashu_app/view_model/AuthVM/request_otp_register_view_model.dart';
import 'package:pashu_app/view_model/AuthVM/request_otp_view_model.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../core/custom_text_field.dart';
import '../../core/primary_button.dart';
import '../../core/secandory_button.dart';
import '../../core/top_snacbar.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _hasNavigated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!; // Add this line
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightSage.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.lightSage,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorations
            _buildBackgroundDecorations(),

            // Main content
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
                    _buildRegisterCard(localizations),
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

  Widget _buildRegisterCard(AppLocalizations localizations) {
    return Hero(
      tag: 'register_card',
      child: Material(
        color: Colors.transparent,
        child: Consumer<RequestOtpViewRegisterModel>(
          builder: (context, viewModel,_) {


            // Check both success and consumed status
            if (viewModel.errorMessage != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showCustomTopSnackbar(
                  context: context,
                  message: viewModel.response?.message ?? viewModel.errorMessage ??'Verification Failed',
                  isError: true,
                );
              });
            }

            if (viewModel.response?.success == true) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>OtpScreenRegister(phoneNumber: _phoneController.text, name: _nameController.text,refCode: _referralController.text,),
                  ),
                );
                viewModel.resetState();
                _showCustomTopSnackbar(
                  context: context,
                  message: localizations.otpSentTo(_phoneController.text),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo section
                          Container(
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

                          const SizedBox(height: 32),

                          // Register Now section with divider
                          _buildSectionDivider(localizations.registerNow),

                          const SizedBox(height: 32),

                          // Name Input
                          _buildInputField(
                            controller: _nameController,
                            hintText: localizations.enterYourName,
                            prefixIcon: Icons.person_outline_rounded,
                            keyboardType: TextInputType.name,
                            localizations: localizations,
                          ),

                          const SizedBox(height: 20),

                          // Phone Input
                          _buildPhoneInputSection(localizations),

                          const SizedBox(height: 20),

                          // Referral Code Input
                          _buildInputField(
                            controller: _referralController,
                            hintText: localizations.enterReferralCode,
                            prefixIcon: Icons.card_giftcard_outlined,
                            keyboardType: TextInputType.text,
                            isOptional: true,
                            localizations: localizations,
                          ),

                          const SizedBox(height: 28),

                          // Get OTP Button
                          PrimaryButton(
                            text: localizations.sendOTP,
                            onPressed: () => viewModel.isLoading ? null : _handleGetOTP(localizations,viewModel),
                            isLoading: viewModel.isLoading,
                          ),

                          const SizedBox(height: 24),

                          // OR divider
                          _buildOrDivider(localizations),

                          const SizedBox(height: 16),

                          // Sign In Link
                          SecondaryButton(
                            text: localizations.alreadyHaveAccount,
                            onPressed: _handleSignIn,
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

  Widget _buildSectionDivider(String title) {
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
              fontSize: 16,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    required AppLocalizations localizations,
    bool isOptional = false,
  }) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      keyboardType: keyboardType,
      prefixIcon: Icon(
        prefixIcon,
        color: AppColors.primaryDark.withOpacity(0.6),
      ),
      suffixIcon: isOptional
          ? Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryDark.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          localizations.optional,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 10,
            color: AppColors.primaryDark.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildPhoneInputSection(AppLocalizations localizations) {
    return Row(
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

  bool _validateForm(AppLocalizations localizations) {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      _showCustomTopSnackbar(
        context: context,
        message: localizations.nameIsRequired,
        isError: true,
      );
      return false;
    }

    if (_nameController.text.trim().length < 2) {
      _showCustomTopSnackbar(
        context: context,
        message: localizations.nameMinLength,
        isError: true,
      );
      return false;
    }

    // Validate phone
    if (_phoneController.text.trim().isEmpty) {
      _showCustomTopSnackbar(
        context: context,
        message: localizations.phoneNumberRequired,
        isError: true,
      );
      return false;
    }

    if (_phoneController.text.length != 10 ||
        !RegExp(r'^[6-9]\d{9}$').hasMatch(_phoneController.text)) {
      _showCustomTopSnackbar(
        context: context,
        message: localizations.enterValidPhoneNumber,
        isError: true,
      );
      return false;
    }

    return true;
  }

  void _handleGetOTP(AppLocalizations localizations, RequestOtpViewRegisterModel viewModel) async {
    if (!_validateForm(localizations)) return;
    HapticFeedback.lightImpact();
    viewModel.resetState(); // Reset state before new request
    await viewModel.requestOtp(_phoneController.text);
  } void _handleSignIn() {
    HapticFeedback.selectionClick();
    Navigator.pop(context); // Go back to login screen
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
