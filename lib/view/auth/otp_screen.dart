import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import 'package:pashu_app/view/home/bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../core/app_logo.dart';
import '../../core/primary_button.dart';
import '../../core/secandory_button.dart';
import '../../core/shared_pref_helper.dart';
import '../../core/top_snacbar.dart';
import '../../view_model/AuthVM/verify_otp_view_model.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isRegistration;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
    this.isRegistration = false,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isResending = false;
  int _remainingTime = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    // Set up focus node listeners
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        setState(() {}); // Rebuild when focus changes
      });
    }
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
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
                    // Wrap OTP card with Consumer
                    Consumer<VerifyOtpViewModel>(
                      builder: (context, viewModel, _) {
                        // Handle verification success
                        if (viewModel.isVerified) {
                          SharedPrefHelper.saveUserDetails(
                            username: viewModel.response?.result?.first.username ?? 'null',
                            phoneNumber: viewModel.response?.result?.first.number ?? '',
                            isLoggedIn: true,
                          );
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showCustomTopSnackbar(
                              context: context,
                              message: localizations.successfulLogin,
                              isError: false,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const CustomBottomNavScreen()),
                            );
                            viewModel.resetVerification();
                          });
                        }

                        // Handle verification failure
                        if (viewModel.errorMessage != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _showCustomTopSnackbar(
                              context: context,
                              message: viewModel.errorMessage!,
                              isError: true,
                            );
                          });
                        }

                        return _buildOTPCard(viewModel, localizations);
                      },
                    ),
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

  Widget _buildOTPCard(VerifyOtpViewModel viewModel, AppLocalizations localizations) {
    return Hero(
      tag: 'otp_card',
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
                          size: MediaQuery.of(context).size.width > 600 ? 100 : 80,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Enter OTP section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.sms_outlined,
                              color: AppColors.primaryDark,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              localizations.enterOTP,
                              style: AppTextStyles.heading.copyWith(
                                fontSize: MediaQuery.of(context).size.width > 600 ? 22 : 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Phone number display
                      Text(
                        localizations.otpSentMessage.toString().replaceAll('{phoneNumber}', widget.phoneNumber),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryDark.withOpacity(0.7),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // OTP Input Fields
                      _buildOTPInputFields(),

                      const SizedBox(height: 28),

                      // Login Button
                      PrimaryButton(
                        text: localizations.login,
                        onPressed: viewModel.isLoading ? null : () => _handleLogin(viewModel, localizations),
                        isLoading: viewModel.isLoading,
                      ),

                      const SizedBox(height: 24),

                      // Resend OTP section
                      _buildResendSection(localizations),
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

  Widget _buildOTPInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return Container(
          width: 45,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNodes[index].hasFocus
                  ? AppColors.primaryDark
                  : AppColors.primaryDark.withOpacity(0.1),
              width: _focusNodes[index].hasFocus ? 2 : 1,
            ),
            boxShadow: _focusNodes[index].hasFocus
                ? [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: AppTextStyles.heading.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              if (value.isNotEmpty) {
                // Move to next field
                if (index < 5) {
                  _focusNodes[index + 1].requestFocus();
                } else {
                  // Last field, remove focus
                  _focusNodes[index].unfocus();
                }
              } else if (value.isEmpty && index > 0) {
                // Move to previous field when deleting
                _focusNodes[index - 1].requestFocus();
              }
            },
            onTap: () {
              // Clear the field when tapped
              _otpControllers[index].clear();
            },
          ),
        );
      }),
    );
  }

  Widget _buildResendSection(AppLocalizations localizations) {
    return Column(
      children: [
        if (_remainingTime > 0) ...[
          Text(
            localizations.didntReceiveOTP,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              localizations.resendIn.toString().replaceAll('{seconds}', _remainingTime.toString()),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ] else ...[
          SecondaryButton(
            text: _isResending ? localizations.resending : localizations.resendOTP,
            onPressed: _isResending ? null : () => _handleResendOTP(localizations),
          ),
        ],
      ],
    );
  }

  String _getOTPValue() {
    return _otpControllers.map((controller) => controller.text).join('');
  }

  bool _validateOTP(AppLocalizations localizations) {
    final otp = _getOTPValue();
    if (otp.length != 6) {
      _showCustomTopSnackbar(
        context: context,
        message: localizations.enterComplete6DigitOTP,
        isError: true,
      );
      return false;
    }
    return true;
  }

  void _handleLogin(VerifyOtpViewModel viewModel, AppLocalizations localizations) async {
    if (!_validateOTP(localizations)) return;

    HapticFeedback.lightImpact();
    final otp = _getOTPValue();
    viewModel.verifyOtp(widget.phoneNumber, otp);
  }

  void _handleResendOTP(AppLocalizations localizations) async {
    setState(() {
      _isResending = true;
      _remainingTime = 60;
    });

    HapticFeedback.selectionClick();

    try {
      // TODO: Implement actual resend OTP logic using your RequestOtpService
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isResending = false;
        });

        _showCustomTopSnackbar(
          context: context,
          message: localizations.otpResentTo.toString().replaceAll('{phoneNumber}', widget.phoneNumber),
          isError: false,
        );

        _startCountdown();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });

        _showCustomTopSnackbar(
          context: context,
          message: localizations.failedToResendOTP,
          isError: true,
        );
      }
    }
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.homeScreen),
      ),
      body: Center(
        child: Text(localizations.welcomeToHomeScreen),
      ),
    );
  }
}
