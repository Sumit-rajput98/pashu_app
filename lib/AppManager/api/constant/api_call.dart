import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import 'api_constant.dart';

enum ApiType { get, post, delete }

class ApiCallType {
  Map? body;
  Map<String, String> header;
  ApiType apiType;

  ApiCallType.get({this.header = const {}})
    : apiType = ApiType.get,
      body = null;

  ApiCallType.post({required this.body, this.header = const {}})
    : apiType = ApiType.post;

  ApiCallType.delete({this.header = const {}})
    : apiType = ApiType.delete,
      body = null;
}

class ApiCall {
  Future<dynamic> call({
    String? fullUrl,
    String? url,
    required ApiCallType apiCallType,
    bool token = false,
  }) async {
    String myUrl = fullUrl ?? ApiConstant.baseUrl + url!;
    Map? body = apiCallType.body;
    Map<String, String> header = apiCallType.header;
    if (kDebugMode) {
      print("Type:  [32m${apiCallType.apiType.name} [0m");
      print("Header: $header");
      print("URL: $myUrl");
      print("BODY: $body");
    }

    http.Response? response;
    try {
      switch (apiCallType.apiType) {
        case ApiType.get:
          response = await http.get(Uri.parse(myUrl), headers: header);
          break;
        case ApiType.post:
          response = await http.post(
            Uri.parse(myUrl),
            body: jsonEncode(body),
            headers: header,
          );
          break;
        case ApiType.delete:
          response = await http.delete(Uri.parse(myUrl), headers: header);
          break;
        default:
          break;
      }
      if (response != null) {
        var data = json.decode(response.body);
        print(data);
        return data;
      }
    } catch (e) {
      rethrow;
    }
  }
}
