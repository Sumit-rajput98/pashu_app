
import 'dart:convert';

List<AllPashuModel> allPashuModelFromJson(String str) => List<AllPashuModel>.from(json.decode(str).map((x) => AllPashuModel.fromJson(x)));

String allPashuModelToJson(List<AllPashuModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AllPashuModel {
  final int? id;
  final String? type;
  final String? status;
  final String? lactation;
  final String? animalname;
  final String? animatCategory;
  final String? price;
  final String? location;
  final String? address;
  final String? negotiable;
  final String? pictureOne;
  final String? pictureTwo;
  final String? username;
  final String? usernumber;
  final String? userphone;
  final String? age;
  final String? gender;
  final String? discription;
  final String? referralcode;
  final String? breed;

  AllPashuModel({
    this.id,
    this.type,
    this.status,
    this.lactation,
    this.animalname,
    this.animatCategory,
    this.price,
    this.location,
    this.address,
    this.negotiable,
    this.pictureOne,
    this.pictureTwo,
    this.username,
    this.usernumber,
    this.userphone,
    this.age,
    this.gender,
    this.discription,
    this.referralcode,
    this.breed,
  });

  factory AllPashuModel.fromJson(Map<String, dynamic> json) => AllPashuModel(
    id: json["id"],
    type: json["type"],
    status: json["status"],
    lactation: json["lactation"],
    animalname: json["animalname"],
    animatCategory: json["animatCategory"],
    price: json["price"],
    location: json["location"],
    address: json["address"],
    negotiable: json["negotiable"],
    pictureOne: json["pictureOne"],
    pictureTwo: json["pictureTwo"],
    username: json["username"],
    usernumber: json["usernumber"],
    userphone: json["userphone"],
    age: json["age"],
    gender: json["gender"],
    discription: json["discription"],
    referralcode: json["referralcode"],
    breed: json["breed"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "status": status,
    "lactation": lactation,
    "animalname": animalname,
    "animatCategory": animatCategory,
    "price": price,
    "location": location,
    "address": address,
    "negotiable": negotiable,
    "pictureOne": pictureOne,
    "pictureTwo": pictureTwo,
    "username": username,
    "usernumber": usernumber,
    "userphone": userphone,
    "age": age,
    "gender": gender,
    "discription": discription,
    "referralcode": referralcode,
    "breed": breed,
  };
}
