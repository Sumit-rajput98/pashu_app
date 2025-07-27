import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'AppManager/api/constant/api_constant.dart';

class SellPashuProvider extends ChangeNotifier {
  bool isUploading = false;
  String? uploadMessage;
  String? errorMessage;

  Future<void> postPashuData({
    required File? image1,
    required File? image2,
    required String animalName,
    required String breed,
    required String price,
    required String negotiable,
    required String animalType,
    required String animalCategory,
    required String username,
    required String age,
    required String gender,
    required String description,
    required String phone,
    required String referralCode,
    required String address,
    required double latitude,
    required double longitude, required String userId,
  }) async {
    isUploading = true;
    uploadMessage = null;
    errorMessage = null;
    notifyListeners();

    final uri = Uri.parse('${ApiConstant.baseUrl}api/savepashu');
    final request = http.MultipartRequest('POST', uri);

    request.fields['lactation'] = '3';
    request.fields['animalname'] = animalName;
    request.fields['userphone'] = phone;
    request.fields['breed'] = breed;
    request.fields['price'] = price;
    request.fields['negotiable'] = negotiable;
    request.fields['type'] = animalType;
    request.fields['animatCategory'] = animalCategory;
    request.fields['username'] = username;
    request.fields['age'] = age;
    request.fields['gender'] = gender;
    request.fields['discription'] = description;
    request.fields['usernumber'] = phone;
    request.fields['referralcode'] = referralCode;
    request.fields['location'] = jsonEncode({
      "latitude": latitude,
      "longitude": longitude,
    });
    request.fields['address'] = address;

    if (image1 != null && await image1.exists()) {
      request.files.add(await http.MultipartFile.fromPath(
        'pictureOne',
        image1.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    if (image2 != null && await image2.exists()) {
      request.files.add(await http.MultipartFile.fromPath(
        'pictureTwo',
        image2.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await handleWalletAndCounter(userId, 15);
        uploadMessage = "Pashu uploaded successfully!";
        errorMessage = null;
      } else {
        uploadMessage = null;
        errorMessage = "Failed to upload Pashu. Please try again.";
      }
    } catch (e) {
      uploadMessage = null;
      errorMessage = "Error uploading: $e";
    }

    isUploading = false;
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
  }
}
