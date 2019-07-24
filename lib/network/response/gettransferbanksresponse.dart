class TransferBanksResponse {
  String _status;
  String _message;
  List<Bank> banks;

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  void fromMap(Map json) {
    if (json['status'] != null) {
      this.status = json['status'];
    }

    if (json['message'] != null) {
      this.message = json['message'];
    }

    if (json['data']['Banks'] != null) {
      List<Bank> bankList = new List();
      json['data']['Banks'].forEach((data) {
        Bank bank = new Bank();
        bank.fromMap(data);
        bankList.add(bank);
      });
      this.banks = bankList;
    }
  }
}

class Bank {
  int _id;
  String _code;
  String _name;
  var _isMobileVerified;

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String get code => _code;

  set code(String value) {
    _code = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  get isMobileVerified => _isMobileVerified;

  set isMobileVerified(var value) {
    _isMobileVerified = value;
  }

  void fromMap(Map json) {
    if (json['Id'] != null) {
      this.id = json['Id'];
    }

    if (json['Code'] != null) {
      this.code = json['Code'];
    }

    if (json['Name'] != null) {
      this.name = json['Name'];
    }

    if (json['IsMobileVerified'] != null) {
      this.isMobileVerified = json['IsMobileVerified'];
    }
  }
}
