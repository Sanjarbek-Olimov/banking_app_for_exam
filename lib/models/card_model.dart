class Cards {
  String? id;
  String cardholder;
  String expiration;
  String cardNumber;
  int cvv;

  Cards(
      {this.id,
      required this.cardholder,
      required this.expiration,
      required this.cardNumber,
      required this.cvv});

  Cards.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        cardholder = json["cardholder"],
        expiration = json["expiration"],
        cardNumber = json["cardNumber"],
        cvv = json["cvv"];

  Map<String, dynamic> toJson() => {
        "id": id,
        "cardholder": cardholder,
        "expiration": expiration,
        "cardNumber": cardNumber,
        "cvv": cvv
      };
}
