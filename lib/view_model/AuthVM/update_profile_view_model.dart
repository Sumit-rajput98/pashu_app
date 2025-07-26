import 'package:flutter/material.dart';
import '../../AppManager/api/api_service/auth_service/update_profile_service.dart';


class UpdateProfileViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _message;

  bool get isLoading => _isLoading;
  String? get message => _message;

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final result = await UpdateProfileService.updateProfile(userId: userId, data: data);

    if (result != null) {
      _message = result.message;
    } else {
      _message = "Something went wrong";
    }

    _isLoading = false;
    notifyListeners();
  }
}
