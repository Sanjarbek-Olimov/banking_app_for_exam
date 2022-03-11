import 'dart:async';

import 'package:banking_app/models/card_model.dart';
import 'package:banking_app/pages/home_page.dart';
import 'package:banking_app/services/hive_service.dart';
import 'package:banking_app/services/http_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class AddPage extends StatefulWidget {
  static const String id = "add_page";

  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  bool isLoading = false;
  TextEditingController cardNumberController =
      MaskedTextController(mask: "0000 0000 0000 0000");
  TextEditingController expirationController =
      MaskedTextController(mask: "00/00");
  TextEditingController cvvController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  ConnectivityResult _connectionStatus = ConnectivityResult.bluetooth;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool isValidDate = false;

  void addCard() async {
    String cardholder = nameController.text.trim().toString();
    String cardNumber = cardNumberController.text.trim().toString();
    String expiration = expirationController.text.trim().toString();
    if (cardholder.isEmpty ||
        cardNumber.isEmpty ||
        expiration.isEmpty ||
        cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All fields must be filled")));
      return;
    }
    int cvv = int.parse(cvvController.text);
    if (int.parse(expiration.substring(0, 2)) > 0 &&
        int.parse(expiration.substring(0, 2)) < 13) {
      setState(() {
        isValidDate = true;
      });
    }
    if (!isValidDate) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid expiry date")));
      return;
    }
    setState(() {
      isLoading = true;
    });
    Cards card = Cards(
        cardholder: cardholder,
        cvv: cvv,
        expiration: expiration,
        cardNumber: cardNumber);
    List<Cards> cards = HiveDB.loadSavedCards();
    cards.add(card);
    HiveDB.storeSavedCards(cards);
    if (_connectionStatus == ConnectivityResult.wifi ||
        _connectionStatus == ConnectivityResult.mobile) {
      await Network.POST(Network.API_CREATE, Network.bodyCreate(card));
    } else if (_connectionStatus == ConnectivityResult.none) {
      List<Cards> noInternet = HiveDB.loadNoInternetCards();
      noInternet.add(card);
      HiveDB.storeNoInternetCards(noInternet);
    }
    Navigator.pushReplacementNamed(context, HomePage.id);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                    color: Colors.blueAccent.shade700,
                  )),
              Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 30),
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MaterialButton(
                          onPressed: addCard,
                          color: Colors.blueAccent.shade700,
                          height: 50,
                          minWidth: double.infinity,
                          child: const Text(
                            "Add",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                        isLoading
                            ? const Center(
                                child: CircularProgressIndicator.adaptive(),
                              )
                            : const SizedBox.shrink()
                      ],
                    ),
                  ))
            ],
          ),
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 25),
                    title: Text(
                      "Add your card",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(
                      CupertinoIcons.arrow_merge,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Fill in the fields below or use camera phone",
                    style: TextStyle(color: Colors.grey.shade300),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Your card number",
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 15),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: cardNumberController,
                    maxLength: 19,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      counter: const Offstage(),
                      prefixIconConstraints:
                          const BoxConstraints(maxHeight: 60, maxWidth: 60),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Image.asset(
                          "assets/images/prefix.png",
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expiry date",
                              style: TextStyle(
                                  color: Colors.grey.shade300, fontSize: 15),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: expirationController,
                              maxLength: 5,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                counter: const Offstage(),
                                filled: true,
                                fillColor: Colors.blue.shade50,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CVV2",
                              style: TextStyle(
                                  color: Colors.grey.shade300, fontSize: 15),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: cvvController,
                              textAlign: TextAlign.center,
                              maxLength: 3,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(fontSize: 18),
                              decoration: InputDecoration(
                                counter: const Offstage(),
                                filled: true,
                                fillColor: Colors.blue.shade50,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Full Name",
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 15),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blue.shade50,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent)),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
