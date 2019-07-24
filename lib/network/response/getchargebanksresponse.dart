class ChargeBankResponse {
  List<Bank> _banks;
  String _status;
  String _message;

  List<Bank> get banks => _banks;

  set banks(List<Bank> value) {
    _banks = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  void fromMap(Map<String, dynamic> json) {
    if (json != null && json['banks'] != null) {
      List<Bank> bankList = new List();

      json['banks'].forEach((bank) {
        Bank b = new Bank();
        b.fromMap(bank);
        bankList.add(b);
      });

      this.banks = bankList;
    }

    if (json != null && json['Status'] != null) {
      this.status = json['Status'];
    }

    if (json != null && json['Message'] != null) {
      this.message = json['Message'];
    }
  }
}

class Bank {
  String _bankname;
  String _bankcode;
  bool _internetbanking;

  String get bankname => _bankname;

  set bankname(String value) {
    _bankname = value;
  }

  String get bankcode => _bankcode;

  set bankcode(String value) {
    _bankcode = value;
  }

  bool get internetbanking => _internetbanking;

  set internetbanking(bool value) {
    _internetbanking = value;
  }

  void fromMap(Map json) {
    print(">>>>>> ${json['bankname']}");
    print(">>>>>> ${json['bankcode']}");
    print(">>>>>> ${json['internetbanking']}");

    bankname = json['bankname'];
    bankcode = json['bankcode'];
    internetbanking = json['internetbanking'];
  }
}
