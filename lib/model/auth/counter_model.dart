import 'dart:convert';

CounterModel counterModelFromJson(String str) => CounterModel.fromJson(json.decode(str));

String counterModelToJson(CounterModel data) => json.encode(data.toJson());

class CounterModel {
  final bool? success;
  final List<Result>? result;

  CounterModel({
    this.success,
    this.result,
  });

  factory CounterModel.fromJson(Map<String, dynamic> json) => CounterModel(
    success: json["success"],
    result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
  };
}

class Result {
  final int? userId;
  final int? counter;

  Result({
    this.userId,
    this.counter,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    userId: json["user_id"],
    counter: json["counter"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "counter": counter,
  };
}
