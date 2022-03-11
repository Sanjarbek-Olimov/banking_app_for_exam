import 'dart:convert';
import 'package:banking_app/models/card_model.dart';
import 'package:http/http.dart';

class Network {
  static bool isTester = true;

  static String SERVER_DEVELOPMENT = "622ac48914ccb950d224bf79.mockapi.io";
  static String SERVER_PRODUCTION = "622ac48914ccb950d224bf79.mockapi.io";

  static Map<String, String> getHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8'
    };
    return headers;
  }

  static String getServer() {
    if (isTester) return SERVER_DEVELOPMENT;
    return SERVER_PRODUCTION;
  }

  /* Http Requests */

  static Future<String?> GET(String api, Map<String, dynamic> params) async {
    var uri = Uri.http(getServer(), api, params); // http or https
    var response = await get(uri, headers: getHeaders());
    if (response.statusCode == 200) return response.body;
    return null;
  }

  static Future<String?> POST(String api, Map<String, dynamic> params) async {
    var uri = Uri.http(getServer(), api); // http or https
    var response =
        await post(uri, headers: getHeaders(), body: jsonEncode(params));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    }
    return null;
  }

  static Future<String?> PUT(String api, Map<String, dynamic> params) async {
    var uri = Uri.http(getServer(), api); // http or https
    var response =
        await put(uri, headers: getHeaders(), body: jsonEncode(params));
    if (response.statusCode == 200) return response.body;
    return null;
  }

  static Future<String?> PATCH(String api, Map<String, dynamic> params) async {
    var uri = Uri.http(getServer(), api); // http or https
    var response =
        await patch(uri, headers: getHeaders(), body: jsonEncode(params));
    if (response.statusCode == 200) return response.body;
    return null;
  }

  static Future<String?> DEL(String api, Map<String, dynamic> params) async {
    var uri = Uri.http(getServer(), api, params); // http or https
    var response = await delete(uri, headers: getHeaders());
    if (response.statusCode == 200) return response.body;
    return null;
  }

  /* Http Apis */
  static String API_LIST = "/Cards";
  static String API_ONE_ELEMENT = "/Cards/"; //{id}
  static String API_CREATE = "/Cards";
  static String API_UPDATE = "/Cards/"; //{id}
  static String API_DELETE = "/Cards/"; //{id}

  /* Http Params */
  static Map<String, dynamic> paramsEmpty() {
    Map<String, dynamic> params = {};
    return params;
  }

  /* Http Bodies */
  static Map<String, dynamic> bodyCreate(Cards card) {
    Map<String, dynamic> params = {};
    params.addAll({
      'cardholder': card.cardholder,
      'cardNumber': card.cardNumber,
      'expiration': card.expiration,
      "cvv": card.cvv
    });
    return params;
  }

  static Map<String, dynamic> bodyUpdate(Cards card) {
    Map<String, dynamic> params = {};
    params.addAll({
      'id': card.id,
      'cardholder': card.cardholder,
      'cardNumber': card.cardNumber,
      'expiration': card.expiration,
      "cvv": card.cvv
    });
    return params;
  }

  /* Http parsing */

  static List<Cards> parseResponse(String response) {
    List json = jsonDecode(response);
    List<Cards> cards = List<Cards>.from(json.map((x) => Cards.fromJson(x)));
    return cards;
  }
}
