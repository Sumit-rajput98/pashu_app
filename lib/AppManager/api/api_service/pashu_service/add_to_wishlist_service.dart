

import 'package:pashu_app/model/auth/request_otp_model.dart';

import '../../../../model/pashu/add_to_wishlist_model.dart';
import '../../constant/api_call.dart';

class AddToWishlistService{
  Future<AddToWishlistModel?> addToWishlist(dynamic body) async {
    final String url = "api/savewishlist/Ankit/6393906928";
    final response = await ApiCall().call(url: url, apiCallType: ApiCallType.post(body:body,header: {"Content-Type": "application/json"}));
    if (response!=null) {
      return AddToWishlistModel.fromJson(response);
    }
    else{
      throw Exception("Err");
    }
  }
}