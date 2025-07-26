// To parse this JSON data, do
//
//     final addToWishlistModel = addToWishlistModelFromJson(jsonString);

import 'dart:convert';

AddToWishlistModel addToWishlistModelFromJson(String str) => AddToWishlistModel.fromJson(json.decode(str));

String addToWishlistModelToJson(AddToWishlistModel data) => json.encode(data.toJson());

class AddToWishlistModel {
  final bool? status;
  final String? message;

  AddToWishlistModel({
    this.status,
    this.message,
  });

  factory AddToWishlistModel.fromJson(Map<String, dynamic> json) => AddToWishlistModel(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
