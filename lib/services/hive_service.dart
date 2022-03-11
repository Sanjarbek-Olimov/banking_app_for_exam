import 'dart:convert';

import 'package:banking_app/models/card_model.dart';
import 'package:hive/hive.dart';

class HiveDB {
  static String DB_NAME = "banking_app";
  static var box = Hive.box(DB_NAME);

// #store_saved_cards

  static Future<void> storeSavedCards(List<Cards> cards) async {
    List<String> list =
        List<String>.from(cards.map((card) => jsonEncode(card.toJson())));
    await box.put("cards", list);
  }

  // #load_saved_cards

  static List<Cards> loadSavedCards() {
    List<String> response = box.get("cards", defaultValue: <String>[]);
    List<Cards> list =
        List<Cards>.from(response.map((x) => Cards.fromJson(jsonDecode(x))));
    return list;
  }

  // store_noInternet_cards

  static Future<void> storeNoInternetCards(List<Cards> cards) async {
    List<String> list =
        List<String>.from(cards.map((card) => jsonEncode(card.toJson())));
    await box.put("no connection", list);
  }

  // #load_noInternet_cards

  static List<Cards> loadNoInternetCards() {
    List<String> response = box.get("no connection", defaultValue: <String>[]);
    List<Cards> list =
        List<Cards>.from(response.map((x) => Cards.fromJson(jsonDecode(x))));
    return list;
  }
}
