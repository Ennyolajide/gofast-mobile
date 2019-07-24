class InitiateTransferResponse {
  String _status;
  String _message;
  Data _data;

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get message => _message;

  Data get data => _data;

  set data(Data value) {
    _data = value;
  }

  set message(String value) {
    _message = value;
  }

  void fromJson(Map json) {
    if (json['status'] != null) {
      this.status = json['status'];
    }

    if (json['message'] != null) {
      this.message = json['message'];
    }

    if (json["data"] != null) {
      Data data = new Data();
      data.fromJson(json["data"]);
      this.data = data;
    }
  }
}

class Data {
  int _id;
  String _accountNumber;
  String _bankCode;
  String _fullname;
  String _dateCreated;
  String _currency;
  int _amount;
  int _fee;
  String _status;
  String _reference;
  String _narration;
  String _completeMessage;
  int _requiresApproval;
  int _isApproved;
  String _bankName;

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  String get currency => _currency;

  set currency(String value) {
    _currency = value;
  }

  String get accountNumber => _accountNumber;

  set accountNumber(String value) {
    _accountNumber = value;
  }

  String get bankCode => _bankCode;

  set bankCode(String value) {
    _bankCode = value;
  }

  String get fullname => _fullname;

  set fullname(String value) {
    _fullname = value;
  }

  String get dateCreated => _dateCreated;

  set dateCreated(String value) {
    _dateCreated = value;
  }

  int get amount => _amount;

  set amount(int value) {
    _amount = value;
  }

  int get fee => _fee;

  set fee(int value) {
    _fee = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get reference => _reference;

  set reference(String value) {
    _reference = value;
  }

  String get narration => _narration;

  set narration(String value) {
    _narration = value;
  }

  String get completeMessage => _completeMessage;

  set completeMessage(String value) {
    _completeMessage = value;
  }

  int get requiresApproval => _requiresApproval;

  set requiresApproval(int value) {
    _requiresApproval = value;
  }

  int get isApproved => _isApproved;

  set isApproved(int value) {
    _isApproved = value;
  }

  String get bankName => _bankName;

  set bankName(String value) {
    _bankName = value;
  }

  void fromJson(Map json) {
    this.id = json['id'];
    this.accountNumber = json['account_number'];
    this.bankCode = json['bank_code'];
    this.fullname = json['fullname'];
    this.dateCreated = json['date_created'];
    this.currency = json['currency'];
    this.amount = json['amount'];
    this.fee = json['fee'];
    this.status = json['status'];
    this.reference = json['reference'];
    this.narration = json['narration'];
    this.completeMessage = json['complete_message'];
    this.requiresApproval = json['requires_approval'];
    this._isApproved = json['is_approved'];
    this.bankName = json['bank_name'];
  }
}
