import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildRegisterCard(),
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

  Widget _buildRegisterCard() {
    return Hero(
      tag: 'register_card',
      child: Material(
        color: Colors.transparent,
        child: Container(
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
                      _buildSectionDivider('Register Now'),

                      const SizedBox(height: 32),

                      // Name Input
                      _buildInputField(
                        controller: _nameController,
                        hintText: 'Enter your name',
                        prefixIcon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                      ),

                      const SizedBox(height: 20),

                      // Phone Input
                      _buildPhoneInputSection(),

                      const SizedBox(height: 20),

                      // Referral Code Input
                      _buildInputField(
                        controller: _referralController,
                        hintText: 'Enter Referral Code (Optional)',
                        prefixIcon: Icons.card_giftcard_outlined,
                        keyboardType: TextInputType.text,
                        isOptional: true,
                      ),

                      const SizedBox(height: 28),

                      // Get OTP Button
                      PrimaryButton(
                        text: 'Get OTP',
                        onPressed: _isLoading ? null : _handleGetOTP,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 24),

                      // OR divider
                      _buildOrDivider(),

                      const SizedBox(height: 16),

                      // Sign In Link
                      SecondaryButton(
                        text: 'Already have an Account? Sign In',
                        onPressed: _handleSignIn,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
          'Optional',
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

  Widget _buildPhoneInputSection() {
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
            hintText: 'Enter phone number',
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

  Widget _buildOrDivider() {
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
              'Or',
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

  bool _validateForm() {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      _showCustomTopSnackbar(
        context: context,
        message: 'Name is required',
        isError: true,
      );
      return false;
    }

    if (_nameController.text.trim().length < 2) {
      _showCustomTopSnackbar(
        context: context,
        message: 'Name must be at least 2 characters long',
        isError: true,
      );
      return false;
    }

    // Validate phone
    if (_phoneController.text.trim().isEmpty) {
      _showCustomTopSnackbar(
        context: context,
        message: 'Phone number is required',
        isError: true,
      );
      return false;
    }

    if (_phoneController.text.length != 10 ||
        !RegExp(r'^[6-9]\d{9}$').hasMatch(_phoneController.text)) {
      _showCustomTopSnackbar(
        context: context,
        message: 'Enter a valid 10-digit Indian phone number',
        isError: true,
      );
      return false;
    }

    return true;
  }

  void _handleGetOTP() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showCustomTopSnackbar(
          context: context,
          message: 'OTP sent to +91 ${_phoneController.text}',
          isError: false,
        );

        // Navigate to OTP screen after 1 second
        Future.delayed(const Duration(seconds: 1), () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: _phoneController.text,
                isRegistration: true, // Add this parameter to OTP screen
              ),
            ),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        _showCustomTopSnackbar(
          context: context,
          message: 'Failed to send OTP. Please try again.',
          isError: true,
        );
      }
    }
  }

  void _handleSignIn() {
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

