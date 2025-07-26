import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pashu_app/AppManager/api/constant/api_constant.dart';
import '../../../../model/auth/update_profile_model.dart';


class UpdateProfileService {
  static Future<UpdateProfileModel?> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final url = Uri.parse("${ApiConstant.baseUrl}api/updateProfile/$userId"); // replace with actual domain
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer your_token', // if needed
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return updateProfileModelFromJson(response.body);
      } else {
        print("Update failed: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception in updateProfile: $e");
      return null;
    }
  }
}
