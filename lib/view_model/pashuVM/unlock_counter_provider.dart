import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../AppManager/api/constant/api_constant.dart';
import '../../core/shared_pref_helper.dart';

class UnlockContactProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  bool isSubscribed = false;
  Map<String, dynamic>? userData;

  Future<void> fetchUserData() async {
    try {
      final number = await SharedPrefHelper.getPhoneNumber();

      if (number == null) {
        debugPrint('📛 Phone number not found.');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}api/getprofileByNumber/$number'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        userData = data['result'][0];

        if (userData?['subscription_status'] == 'active') {
          isSubscribed = true;
        }

        notifyListeners();
      } else {
        debugPrint('❌ Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Exception while fetching user data: $e');
    }
  }


  Future<bool> isContactAlreadyUnlocked(String userId, String contactId) async {
    try {
      final url = Uri.parse('${ApiConstant.baseUrl}api/unlock-contact/$userId/$contactId');
      debugPrint('🔍 Checking unlock status: $url');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        debugPrint('📄 Unlock check response: $data');
        return data['success'] == true;
      } else {
        debugPrint('⚠️ Unlock check failed: ${res.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception during unlock check: $e');
      return false;
    }
  }

  Future<void> unlockContact({
    required String userId,
    required String contactId,
    required int walletBalance,
    required Function onInsufficientBalance,
    required Function onUnlocked,
    required Function onAlreadyUnlocked,
  }) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    if (walletBalance < 2) {
      onInsufficientBalance();
      isLoading = false;
      notifyListeners();
      return;
    }

    final alreadyUnlocked = await isContactAlreadyUnlocked(userId, contactId);

    if (alreadyUnlocked) {
      successMessage = 'Already unlocked';
      onAlreadyUnlocked();
      isLoading = false;
      notifyListeners();
      return;
    }

    final unlockUrl = Uri.parse('${ApiConstant.baseUrl}api/unlock-contact');
    final body = {
      "userId": userId,
      "contactId": contactId,
    };

    try {
      final response = await http.post(
        unlockUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('🔓 Unlock response: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        successMessage = 'Contact unlocked successfully';

        await _incrementCounter(userId);
        onUnlocked();
      } else {
        errorMessage = data['message'] ?? 'Failed to unlock contact';
      }
    } catch (e) {
      errorMessage = 'Exception: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _incrementCounter(String userId) async {
    final url = Uri.parse('${ApiConstant.baseUrl}api/increment-counter');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": userId,
          "incrementValue": 2,
        }),
      );

      debugPrint('📈 Counter increment response: ${response.body}');
    } catch (e) {
      debugPrint('❌ Counter increment exception: $e');
    }
  }
}