import 'package:flutter/material.dart';
import 'package:pashu_app/model/auth/profile_model.dart';

import '../../AppManager/api/api_service/auth_service/get_profile_service.dart';

class GetProfileViewModel extends ChangeNotifier{
  final GetProfileService _service = GetProfileService();

  GetProfileModel? _profile;
  GetProfileModel? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> getProfile(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _service.getWishlist(phoneNumber);
      if (_profile?.isMatch==false) {
        _error = "Error Getting Profile";
      }
    } catch (e) {
      _error = "Failed to fetch profile: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}