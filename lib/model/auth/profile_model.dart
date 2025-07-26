
import 'dart:convert';

GetProfileModel getProfileModelFromJson(String str) => GetProfileModel.fromJson(json.decode(str));

String getProfileModelToJson(GetProfileModel data) => json.encode(data.toJson());

class GetProfileModel {
  final bool? isMatch;
  final List<Result>? result;

  GetProfileModel({
    this.isMatch,
    this.result,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) => GetProfileModel(
    isMatch: json["isMatch"],
    result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "isMatch": isMatch,
    "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
  };
}

class Result {
  final int? id;
  final String? username;
  final String? number;
  final dynamic emailid;
  final int? walletBalance;
  final String? referralcode;
  final String? address;
  final String? subscriptionId;
  final String? subscriptionStatus;
  final dynamic paymentId;
  final String? planId;
  final dynamic panCard;
  final dynamic aadharCard;
  final dynamic accountNumber;
  final dynamic ifscCode;
  final dynamic bankName;
  final int? slots;

  Result({
    this.id,
    this.username,
    this.number,
    this.emailid,
    this.walletBalance,
    this.referralcode,
    this.address,
    this.subscriptionId,
    this.subscriptionStatus,
    this.paymentId,
    this.planId,
    this.panCard,
    this.aadharCard,
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.slots,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    username: json["username"],
    number: json["number"],
    emailid: json["emailid"],
    walletBalance: json["walletBalance"],
    referralcode: json["referralcode"],
    address: json["address"],
    subscriptionId: json["subscription_id"],
    subscriptionStatus: json["subscription_status"],
    paymentId: json["payment_id"],
    planId: json["plan_id"],
    panCard: json["pan_card"],
    aadharCard: json["aadhar_card"],
    accountNumber: json["account_number"],
    ifscCode: json["ifsc_code"],
    bankName: json["bank_name"],
    slots: json["slots"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "number": number,
    "emailid": emailid,
    "walletBalance": walletBalance,
    "referralcode": referralcode,
    "address": address,
    "subscription_id": subscriptionId,
    "subscription_status": subscriptionStatus,
    "payment_id": paymentId,
    "plan_id": planId,
    "pan_card": panCard,
    "aadhar_card": aadharCard,
    "account_number": accountNumber,
    "ifsc_code": ifscCode,
    "bank_name": bankName,
    "slots": slots,
  };
}
