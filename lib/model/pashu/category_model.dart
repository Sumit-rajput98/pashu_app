// To parse this JSON data, do
//
//     final categoryModel = categoryModelFromJson(jsonString);

import 'dart:convert';

List<CategoryModel> categoryModelFromJson(String str) => List<CategoryModel>.from(json.decode(str).map((x) => CategoryModel.fromJson(x)));

String categoryModelToJson(List<CategoryModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryModel {
  final int? id;
  final String? categoryName;
  final String? categoryDetail;
  final String? categoryImage;

  CategoryModel({
    this.id,
    this.categoryName,
    this.categoryDetail,
    this.categoryImage,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json["id"],
    categoryName: json["categoryName"],
    categoryDetail: json["categoryDetail"],
    categoryImage: json["categoryImage"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "categoryName": categoryName,
    "categoryDetail": categoryDetail,
    "categoryImage": categoryImage,
  };
}
