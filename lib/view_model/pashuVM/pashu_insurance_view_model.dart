import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../AppManager/api/constant/api_constant.dart';

// adjust path as needed

class AnimalInsuranceViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool success = false;
  String? errorMessage;

  Future<void> submitInsuranceForm(Map<String, dynamic> formData) async {
    isLoading = true;
    success = false;
    errorMessage = null;
    notifyListeners();

    final url = Uri.parse('${ApiConstant.baseUrl}api/animal-insurance');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(formData),
      );

      if (response.statusCode == 200) {
        success = true;
      } else {
        errorMessage = "Submission failed: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = "Error: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}
