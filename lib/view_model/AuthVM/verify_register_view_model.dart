import 'package:flutter/foundation.dart';
import 'package:pashu_app/AppManager/api/api_service/auth_service/verify_otp_register.dart';
import 'package:pashu_app/model/auth/verify_register_model.dart';



class VerifyRegisterViewModel with ChangeNotifier {
  final VerifyOtpRegisterService _service = VerifyOtpRegisterService();

  VerifyOtpRegisterModel? _response;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isVerified = false;

  // State getters
  VerifyOtpRegisterModel? get response => _response;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isVerified => _isVerified;

  // Clear error state
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset verification state
  void resetVerification() {
    _isVerified = false;
    _response = null;
    notifyListeners();
  }

  // Main OTP verification method
  Future<void> verifyOtp(String phoneNumber, String otp,String name,String? refCode) async {
    _isLoading = true;
    _errorMessage = null;
    _isVerified = false;
    notifyListeners();

    try {
      final body = {
        'phoneNumber': phoneNumber,
        'otp': otp,
        'name': name,
        'refCode':refCode ?? ''
      };

      final result = await _service.verifyRegister(body);
      _response = result;

      if (result.success == true) {
        _isVerified = true;
      } else {
        // Handle API-level errors (success: false)
        _errorMessage = _extractErrorMessage(result);
      }
    } catch (e) {
      // Handle network/parsing exceptions
      _errorMessage = _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Extract error message from response
  String? _extractErrorMessage(VerifyOtpRegisterModel? response) {
    if (response == null) return 'Verification failed';

    // Check if the response has a direct message field
    if (response.success == false) {
      return  "Verification failed. Please try again.";
    }

    return 'Verification failed. Please try again.';
  }

  // Error handling
  String _handleError(dynamic error) {
    if (error is Map<String, dynamic>) {
      // Handle error response from API
      return error['message'] ?? 'Invalid OTP';
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}