
import 'package:pashu_app/model/auth/verify_register_model.dart';

import '../../constant/api_call.dart';

class VerifyOtpRegisterService{
  Future<VerifyOtpRegisterModel> verifyRegister(dynamic body) async {
    final String url = "api/verify-otp";
    final response = await ApiCall().call(url: url, apiCallType: ApiCallType.post(body:body,header: {"Content-Type": "application/json"}));
    if (response!=null) {
      return VerifyOtpRegisterModel.fromJson(response);
    }
    else{
      throw Exception("Err");
    }
  }
}