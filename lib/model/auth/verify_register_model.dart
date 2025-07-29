// To parse this JSON data, do
//
//     final verifyOtpRegisterModel = verifyOtpRegisterModelFromJson(jsonString);

import 'dart:convert';

VerifyOtpRegisterModel verifyOtpRegisterModelFromJson(String str) => VerifyOtpRegisterModel.fromJson(json.decode(str));

String verifyOtpRegisterModelToJson(VerifyOtpRegisterModel data) => json.encode(data.toJson());

class VerifyOtpRegisterModel {
  final bool? success;
  final String? message;

  VerifyOtpRegisterModel({
    this.success,
    this.message,
  });

  factory VerifyOtpRegisterModel.fromJson(Map<String, dynamic> json) => VerifyOtpRegisterModel(
    success: json["success"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
  };
}
