
import 'dart:convert';

RequestOtpModel requestOtpModelFromJson(String str) => RequestOtpModel.fromJson(json.decode(str));

String requestOtpModelToJson(RequestOtpModel data) => json.encode(data.toJson());

class RequestOtpModel {
  final bool? success;
  final String? message;

  RequestOtpModel({
    this.success,
    this.message,
  });

  factory RequestOtpModel.fromJson(Map<String, dynamic> json) => RequestOtpModel(
    success: json["success"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
  };
}
