import 'dart:async';
import 'dart:math';

import 'package:banking_app/models/card_model.dart';
import 'package:banking_app/pages/add_page.dart';
import 'package:banking_app/services/hive_service.dart';
import 'package:banking_app/services/http_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  static const String id = "home_page";

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  List<Cards> cards = [];
  ConnectivityResult _connectionStatus = ConnectivityResult.values[0];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String greeting() {
    if (DateTime.now().hour >= 6 && DateTime.now().hour < 12) {
      return "Good Morning,";
    } else if (DateTime.now().hour >= 12 && DateTime.now().hour < 18) {
      return "Good Afternoon,";
    } else {
      return "Good Evening,";
    }
  }

  // #load_cards
  void _apiCardsList() async {
    setState(() {
      isLoading = true;
    });
    if (_connectionStatus == ConnectivityResult.wifi ||
        _connectionStatus == ConnectivityResult.mobile) {
      await Network.GET(Network.API_LIST, Network.paramsEmpty())
          .then((response) {
        setState(() {
          cards = Network.parseResponse(response!);
          HiveDB.storeSavedCards(cards);
        });
      });
    } else if (_connectionStatus == ConnectivityResult.none) {
      setState(() {
        cards = HiveDB.loadSavedCards();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initConnectivity().then((value) => _apiCardsList());
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
    if ((_connectionStatus == ConnectivityResult.wifi ||
            _connectionStatus == ConnectivityResult.mobile) &&
        HiveDB.loadNoInternetCards().isNotEmpty) {
      for (int i = 0; i < HiveDB.loadNoInternetCards().length; i++) {
        await Network.POST(Network.API_CREATE,
            Network.bodyCreate(HiveDB.loadNoInternetCards()[i]));
      }
      HiveDB.storeNoInternetCards([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 30),
                      title: RichText(
                        text: TextSpan(
                            text: greeting(),
                            style: const TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                            children: const [
                              TextSpan(
                                  text: "\nEugene",
                                  style: TextStyle(fontWeight: FontWeight.w500))
                            ]),
                      ),
                      trailing: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.asset(
                          "assets/images/profile.jpg",
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          return cardUI(cards[index], index);
                        }),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AddPage.id);
                      },
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(
                              CupertinoIcons.add_circled,
                              size: 30,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text("Add new card")
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: ""),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.arrow_up_arrow_down), label: ""),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: ""),
        ],
      ),
    );
  }

  Widget cardUI(Cards card, int index) {
    return Dismissible(
      key: const ValueKey(0),
      onDismissed: (_) async {
        cards.remove(card);
        HiveDB.storeSavedCards(cards);
        await Network.DEL(Network.API_DELETE + card.id!, Network.paramsEmpty());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 25),
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
            color:
                Colors.primaries[(Colors.primaries.length - 1) % (index + 1)],
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/images/silver.jpg",
                    height: 45,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                Image.asset(
                  "assets/images/visalogo.png",
                  height: 18,
                  color: Colors.white,
                ),
              ],
            ),
            Text(
              card.cardNumber,
              style: TextStyle(color: Colors.grey.shade50, fontSize: 27),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CARD HOLDER",
                      style:
                          TextStyle(color: Colors.grey.shade50, fontSize: 11),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(card.cardholder,
                        style:
                            TextStyle(color: Colors.grey.shade50, fontSize: 18))
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "EXPIRES",
                      style:
                          TextStyle(color: Colors.grey.shade50, fontSize: 11),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(card.expiration,
                        style:
                            TextStyle(color: Colors.grey.shade50, fontSize: 18))
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
