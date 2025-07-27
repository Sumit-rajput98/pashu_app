import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../AppManager/api/constant/api_constant.dart';



class UnlockContactProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  Future<void> unlockContact({
    required String userId,
    required String contactId,
  }) async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    final url = Uri.parse('${ApiConstant.baseUrl}api/unlock-contact');
    final body = {
      "userId": userId,
      "contactId": contactId,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final alreadyUnlocked = responseData['alreadyUnlocked'] ?? false;

        if (alreadyUnlocked) {
          successMessage = 'Already unlocked';
        } else {
          // Deduct ₹2
          handleWalletAndCounter(userId, 2);
          successMessage = 'Contact unlocked successfully';
        }
      } else {
        errorMessage = 'Failed to unlock contact: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> handleWalletAndCounter(String userId, int amount) async {
    final deductUri = Uri.parse('${ApiConstant.baseUrl}api/payment/deduct-wallet');
    final counterUri = Uri.parse('${ApiConstant.baseUrl}api/increment-counter');

    try {
      final deductResponse = await http.post(
        deductUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": userId,
          "amount": amount,
        }),
      );

      if (deductResponse.statusCode == 200) {
        final counterResponse = await http.post(
          counterUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "userId": userId,
            "incrementValue": amount,
          }),
        );

        if (counterResponse.statusCode == 200) {
          debugPrint('Both APIs succeeded');
        } else {
          debugPrint('Counter increment failed: ${counterResponse.statusCode}');
        }
      } else {
        debugPrint('Wallet deduction failed: ${deductResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error hitting APIs: $e');
    }
  }}
