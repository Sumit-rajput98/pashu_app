

import 'package:pashu_app/model/auth/request_otp_model.dart';

import '../../constant/api_call.dart';

class RequestOtpService{
  Future<RequestOtpModel?> login(dynamic body) async {
    final String url = "api/request-otp";
    final response = await ApiCall().call(url: url, apiCallType: ApiCallType.post(body:body,header: {"Content-Type": "application/json"}));
    if (response!=null) {
      return RequestOtpModel.fromJson(response);
    }
    else{
      throw Exception("Err");
    }
  }
}