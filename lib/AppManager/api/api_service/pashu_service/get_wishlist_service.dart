import 'package:pashu_app/model/pashu/all_pashu.dart';
import '../../constant/api_call.dart';

class GetWishlistService {
  Future<List<AllPashuModel>> getWishlist() async {
    try {
      final String url = "api/wishpashu";
      final response = await ApiCall().call(
        url: url,
        apiCallType: ApiCallType.get(
          header: {"Content-Type": "application/json"},
        ),
      );
      if (response != null && response is List) {
        return response.map((json) => AllPashuModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Wishlist Service Error: $e");
      return [];
    }
  }

  Future<bool> removeFromWishlist({
    required String name,
    required String phoneNumber,
    required int id,
  }) async {
    try {
      final String url = "api/deletewishpashu/$name/$phoneNumber/$id";
      final response = await ApiCall().call(
        url: url,
        apiCallType: ApiCallType.delete(
          header: {"Content-Type": "application/json"},
        ),
      );
      if (response != null && response["status"] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Remove Wishlist Service Error: $e");
      return false;
    }
  }
}
