import 'package:flutter/foundation.dart';
import 'package:pashu_app/model/auth/request_otp_model.dart';


import '../../AppManager/api/api_service/auth_service/request_otp_service.dart';

class RequestOtpViewRegisterModel with ChangeNotifier {
  final RequestOtpService _service = RequestOtpService();

  RequestOtpModel? _response;
  bool _isLoading = false;
  String? _errorMessage;

  // State getters
  RequestOtpModel? get response => _response;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Reset state
  void resetState() {
    _response = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Main OTP request method
  Future<void> requestOtp(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = {'phoneNumber': phoneNumber};
      final result = await _service.login(body);

      _response = result;
      if (result?.success == false) {
        _errorMessage = result?.message ?? 'OTP request failed';
      }
    } catch (e) {
      _errorMessage = _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Error handling
  String _handleError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}