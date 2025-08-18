
import 'package:pashu_app/model/auth/verify_otp_model.dart';

import '../../constant/api_call.dart';

class VerifyOtpService{
  Future<VerifyOtpModel> verify(dynamic body) async {
    final String url = "api/verify-number";
    final response = await ApiCall().call(url: url, apiCallType: ApiCallType.post(body:body,header: {"Content-Type": "application/json"}));
    if (response!=null) {
      return VerifyOtpModel.fromJson(response);
    }
    else{
      throw Exception("Err");
    }
  }
}