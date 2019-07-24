class VerifyAccountChargeRequest {
  String _txref;
  String _secretKey;

  String get txref => _txref;

  set txref(String value) {
    _txref = value;
  }

  String get secretKey => _secretKey;

  set secretKey(String value) {
    _secretKey = value;
  }

  Map toMap() {
    var data = new Map();

    data['txref'] = this.txref;
    data['SECKEY'] = this.secretKey;

    return data;
  }
}
