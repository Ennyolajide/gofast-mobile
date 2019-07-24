class InitiateTransferRequest {
  String _account_bank;
  String _account_number;
  int _amount;
  String _seckey;
  String _narration;
  String _currency;
  String _reference;
  String _beneficiary_name;

  String get account_bank => _account_bank;

  set account_bank(String value) {
    _account_bank = value;
  }

  String get account_number => _account_number;

  String get beneficiary_name => _beneficiary_name;

  set beneficiary_name(String value) {
    _beneficiary_name = value;
  }

  String get reference => _reference;

  set reference(String value) {
    _reference = value;
  }

  String get currency => _currency;

  set currency(String value) {
    _currency = value;
  }

  String get narration => _narration;

  set narration(String value) {
    _narration = value;
  }

  String get seckey => _seckey;

  set seckey(String value) {
    _seckey = value;
  }

  int get amount => _amount;

  set amount(int value) {
    _amount = value;
  }

  set account_number(String value) {
    _account_number = value;
  }

  Map toMap() {
    var data = new Map();
    data['account_bank'] = this.account_bank;
    data['account_number'] = this.account_number;
    data['amount'] = this.amount;
    data['seckey'] = this.seckey;
    data['narration'] = this.narration;
    data['currency'] = this.currency;
    data['reference'] = this.reference;
    if (this.currency != "NGN") {
      data['beneficiary_name'] = this.beneficiary_name;
    }

    return data;
  }
}
