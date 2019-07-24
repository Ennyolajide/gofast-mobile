import 'package:gofast/config/urlconstants.dart';

class InitiateChargeAccountRequest {
  String _bankCode;
  String _accountnumber;
  String _amount;
  String _email;
  String _passCode;
  String _firstname;
  String _lastname;
  String _phoneNumber;
  String _txRef;
  String _paymentType;
  String _bvn;
  String _country;

  String get bankCode => _bankCode;

  set bankCode(String value) {
    _bankCode = value;
  }

  String get accountnumber => _accountnumber;

  String get txRef => _txRef;

  set txRef(String value) {
    _txRef = value;
  }

  String get phoneNumber => _phoneNumber;

  set phoneNumber(String value) {
    _phoneNumber = value;
  }

  String get passCode => _passCode;

  set passCode(String value) {
    _passCode = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get amount => _amount;

  set amount(String value) {
    _amount = value;
  }

  set accountnumber(String value) {
    _accountnumber = value;
  }

  String get firstname => _firstname;

  set firstname(String value) {
    _firstname = value;
  }

  String get lastname => _lastname;

  set lastname(String value) {
    _lastname = value;
  }

  String get paymentType => _paymentType;

  set paymentType(String value) {
    _paymentType = value;
  }

  String get bvn => _bvn;

  set bvn(String value) {
    _bvn = value;
  }

  String get country => _country;

  set country(String value) {
    _country = value;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = new Map();

    data['PBFPubKey'] = UrlConstants.LIVE_PUBLIC_KEY;
    data['accountbank'] = this.bankCode;
    data['accountnumber'] = this.accountnumber;
    data['amount'] = this.amount;
    data['email'] = this.email;
    if (passCode != "") {
      data['passcode'] = this.passCode;
    }
    if (firstname != "") {
      data['firstname'] = this.firstname;
    }
    if (lastname != "") {
      data['lastname'] = this.lastname;
    }
    data['phonenumber'] = this.phoneNumber;
    data['txRef'] = this.txRef;
    data['payment_type'] = this.paymentType;
    data['bvn'] = this.bvn;
    data['country'] = this.country;

    return data;
  }
}
