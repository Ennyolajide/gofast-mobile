class InitiatePaymentRequest {
  String pbfPubKey;
  String client;
  String alg;

  InitiatePaymentRequest({
    this.pbfPubKey,
    this.client,
    this.alg,
  });

  void fromJson(Map<String, dynamic> json) => new InitiatePaymentRequest(
        pbfPubKey: json["PBFPubKey"],
        client: json["client"],
        alg: json["alg"],
      );

  Map<String, dynamic> toJson() => {
        "PBFPubKey": pbfPubKey,
        "client": client,
        "alg": alg,
      };
}
