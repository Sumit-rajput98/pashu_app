import 'package:pashu_app/model/auth/counter_model.dart';
import 'package:pashu_app/model/auth/profile_model.dart';

import '../../constant/api_call.dart';

class GetCounterService{
  Future<CounterModel?> getCounter(String userId) async {
    try {
      final String url = "api/counter/$userId";
      final response = await ApiCall().call(
        url: url,
        apiCallType: ApiCallType.get(
          header: {"Content-Type": "application/json"},
        ),
      );
      if (response != null) {
        return CounterModel.fromJson(response);
      }
    } catch (e) {
      print("Service Error: $e");
      throw("Unexpected error occurred");
    }
    return null;
  }
}