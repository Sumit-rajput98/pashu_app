import 'package:pashu_app/model/pashu/all_pashu.dart';
import 'package:pashu_app/model/pashu/category_model.dart';


import '../../constant/api_call.dart';
class GetCategoriesService {
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final String url = "api/categories";
      final response = await ApiCall().call(
          url: url,
          apiCallType: ApiCallType.get(
              header: {"Content-Type": "application/json"}
          )
      );

      // Check if response is successful (status code 200)
      if (response != null && response is List) {




        return response
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      } else {
        // Handle non-200 responses
        print("API Error: ${response?.statusCode}");
        return [];
      }
    } catch (e) {
      // Handle parsing/network errors
      print("Service Error: $e");
      return [];
    }
  }
}