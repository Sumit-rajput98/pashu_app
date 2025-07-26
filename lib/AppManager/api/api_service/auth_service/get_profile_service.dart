import 'package:pashu_app/model/auth/profile_model.dart';

import '../../constant/api_call.dart';

class GetProfileService{
  Future<GetProfileModel?> getWishlist(String phoneNumber) async {
    try {
      final String url = "api/getprofileByNumber/$phoneNumber";
      final response = await ApiCall().call(
        url: url,
        apiCallType: ApiCallType.get(
          header: {"Content-Type": "application/json"},
        ),
      );
      if (response != null) {
        return GetProfileModel.fromJson(response);
      }
    } catch (e) {
      print("Wishlist Service Error: $e");
      throw("Unexpected error occurred");
    }
    return null;
  }
}