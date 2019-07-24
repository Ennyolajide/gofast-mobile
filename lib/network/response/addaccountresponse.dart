class AddAccountResponse {
  String _status;
  String _message;
  String _responseCode;
  String _responseMessage;
  Account _account;

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get message => _message;

  Account get account => _account;

  set account(Account value) {
    _account = value;
  }

  set message(String value) {
    _message = value;
  }

  String get responseCode => _responseCode;

  set responseCode(String value) {
    _responseCode = value;
  }

  String get responseMessage => _responseMessage;

  set responseMessage(String value) {
    _responseMessage = value;
  }

  void fromMap(Map json) {
    if (json['status'] != null) {
      this.status = json['status'];
    }

    if (json['message'] != null) {
      this.message = json['message'];
    }

    if (json['data']['data']['responsecode'] != null) {
      this.responseCode = json['data']['data']['responsecode'];
    }

    if (json['data']['data']['responsemessage'] != null) {
      this.responseMessage = json['data']['data']['responsemessage'];
    }

    if (json['data']['data'] != null) {
      Account acc = new Account();
      acc.fromMap(json['data']['data']);
      this.account = acc;
    }
  }
}

class Account {
  String _responseCode;
  String _accountNumber;
  String _accountName;
  String _responseMessage;
  String _phonenumber;
  String _uniqueReference;
  String _internalReference;

  String get responseCode => _responseCode;

  set responseCode(String value) {
    _responseCode = value;
  }

  String get accountNumber => _accountNumber;

  set accountNumber(String value) {
    _accountNumber = value;
  }

  String get internalReference => _internalReference;

  set internalReference(String value) {
    _internalReference = value;
  }

  String get uniqueReference => _uniqueReference;

  set uniqueReference(String value) {
    _uniqueReference = value;
  }

  String get phonenumber => _phonenumber;

  set phonenumber(String value) {
    _phonenumber = value;
  }

  String get responseMessage => _responseMessage;

  set responseMessage(String value) {
    _responseMessage = value;
  }

  String get accountName => _accountName;

  set accountName(String value) {
    _accountName = value;
  }

  void fromMap(Map json) {
    if (json['responsecode'] != null) {
      responseCode = json['responsecode'];
    }
    if (json['accountnumber'] != null) {
      accountNumber = json['accountnumber'];
    }

    if (json['accountname'] != null) {
      accountName = json['accountname'];
    }

    if (json['responsemessage'] != null) {
      responseMessage = json['responsemessage'];
    }

    if (json['phonenumber'] != null) {
      phonenumber = json['phonenumber'];
    }

    if (json['uniquereference'] != null) {
      uniqueReference = json['uniquereference'];
    }

    if (json['internalreference'] != null) {
      internalReference = json['internalreference'];
    }
  }
}
