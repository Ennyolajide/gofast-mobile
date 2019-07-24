class ValidateChargeRequest {
  String _PBFPubKey;
  String _transactionreference;
  String _otp;

  String get PBFPubKey => _PBFPubKey;

  set PBFPubKey(String value) {
    _PBFPubKey = value;
  }

  String get transactionreference => _transactionreference;

  String get otp => _otp;

  set otp(String value) {
    _otp = value;
  }

  set transactionreference(String value) {
    _transactionreference = value;
  }

  Map toMap() {
    var data = new Map();

    data['PBFPubKey'] = this.PBFPubKey;
    data['transactionreference'] = this.transactionreference;
    data['otp'] = this.otp;

    return data;
  }
}
