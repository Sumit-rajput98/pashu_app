


import '../../../../model/pashu/add_to_wishlist_model.dart';
import '../../constant/api_call.dart';

class AddToWishlistService{
  Future<AddToWishlistModel?> addToWishlist(dynamic body,String username, String phoneNumber) async {
    final String url = "api/savewishlist/$username/$phoneNumber";
    final response = await ApiCall().call(url: url, apiCallType: ApiCallType.post(body:body,header: {"Content-Type": "application/json"}));
    if (response!=null) {
      return AddToWishlistModel.fromJson(response);
    }
    else{
      throw Exception("Err");
    }
  }
}