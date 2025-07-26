import 'package:pashu_app/model/pashu/all_pashu.dart';


import '../../constant/api_call.dart';
class AllPashuService {
  Future<List<AllPashuModel>> getAllPashu() async {
    try {
      final String url = "api/allpashu";
      final response = await ApiCall().call(
          url: url,
          apiCallType: ApiCallType.get(
              header: {"Content-Type": "application/json"}
          )
      );

      // Check if response is successful (status code 200)
      if (response != null && response is List) {

        // Inside getAllPashu() after getting response:


        return response
            .map((json) => AllPashuModel.fromJson(json))
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