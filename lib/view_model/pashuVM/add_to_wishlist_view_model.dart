import 'package:flutter/foundation.dart';
import 'package:pashu_app/model/pashu/add_to_wishlist_model.dart';


import '../../AppManager/api/api_service/pashu_service/add_to_wishlist_service.dart';

class AddToWishlistViewModel with ChangeNotifier {
  final AddToWishlistService _service = AddToWishlistService();

  AddToWishlistModel? _response;
  bool _isLoading = false;
  String? _errorMessage;

  // State getters
  AddToWishlistModel? get response => _response;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Reset state
  void resetState() {
    _response = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Main OTP request method
  Future<void> addToWishList(dynamic body,String username, String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {

      final result = await _service.addToWishlist(body,username,phoneNumber);

      _response = result;
      if (result?.status == false) {
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