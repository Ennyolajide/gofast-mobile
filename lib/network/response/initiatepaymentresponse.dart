class InitiatePaymentResponse {
  String _status;
  String _message;
  Data _data;

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  Data get data => _data;

  set data(Data value) {
    _data = value;
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
  String _txRef;
  dynamic _orderRef;
  String _flwRef;
  String _redirectUrl;
  String _deviceFingerprint;
  dynamic _settlementToken;
  String _cycle;
  double _amount;
  double _chargedAmount;
  double _appfee;
  int _merchantfee;
  int _merchantbearsfee;
  String _chargeResponseCode;
  String _chargeResponseMessage;
  String _authModelUsed;
  String _currency;
  String _ip;
  String _narration;
  String _status;
  String _vbvrespmessage;
  String _authurl;
  String _vbvrespcode;
  dynamic _acctvalrespmsg;
  dynamic _acctvalrespcode;
  String _paymentType;
  String _paymentId;
  String _fraudStatus;
  String _chargeType;
  int _isLive;
  String _createdAt;
  String _updatedAt;
  dynamic _deletedAt;
  int _customerId;
  int _accountId;
  Customer _customer;
  ValidateInstructions _validateInstructions;

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  void fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.txRef = json["txRef"];
    this.orderRef = json["orderRef"];
    this.flwRef = json["flwRef"];
    this.redirectUrl = json["redirectUrl"];
    this.deviceFingerprint = json["device_fingerprint"];
    this.settlementToken = json["settlement_token"];
    this.cycle = json["cycle"];
    this.amount = json["amount"];
    this.chargedAmount = json["charged_amount"];
    this.appfee = json["appfee"];
    this.merchantfee = json["merchantfee"];
    this.merchantbearsfee = json["merchantbearsfee"];
    this.chargeResponseCode = json["chargeResponseCode"];
    this.chargeResponseMessage = json["chargeResponseMessage"];
    this.authModelUsed = json["authModelUsed"];
    this.currency = json["currency"];
    this.ip = json["IP"];
    this.narration = json["narration"];
    this.status = json["status"];
    this.vbvrespmessage = json["vbvrespmessage"];
    this.authurl = json["authurl"];
    this.vbvrespcode = json["vbvrespcode"];
    this.acctvalrespmsg = json["acctvalrespmsg"];
    this.acctvalrespcode = json["acctvalrespcode"];
    this.paymentType = json["paymentType"];
    this.paymentId = json["paymentId"];
    this.fraudStatus = json["fraud_status"];
    this.chargeType = json["charge_type"];
    this.isLive = json["is_live"];
    this.createdAt = json["createdAt"];
    this.updatedAt = json["updatedAt"];
    this.deletedAt = json["deletedAt"];
    this.customerId = json["customerId"];
    this.accountId = json["AccountId"];
    if (json["customer"] != null) {
      Customer cus = new Customer();
      cus.fromJson(json["customer"]);
    }
    if (json["validateInstructions"] != null) {
      ValidateInstructions instructions = ValidateInstructions();
      instructions.fromJson(json["validateInstructions"]);
    }
  }

  String get txRef => _txRef;

  set txRef(String value) {
    _txRef = value;
  }

  dynamic get orderRef => _orderRef;

  set orderRef(dynamic value) {
    _orderRef = value;
  }

  String get flwRef => _flwRef;

  set flwRef(String value) {
    _flwRef = value;
  }

  String get redirectUrl => _redirectUrl;

  set redirectUrl(String value) {
    _redirectUrl = value;
  }

  String get deviceFingerprint => _deviceFingerprint;

  set deviceFingerprint(String value) {
    _deviceFingerprint = value;
  }

  dynamic get settlementToken => _settlementToken;

  set settlementToken(dynamic value) {
    _settlementToken = value;
  }

  String get cycle => _cycle;

  set cycle(String value) {
    _cycle = value;
  }

  double get amount => _amount;

  set amount(double value) {
    _amount = value;
  }

  double get chargedAmount => _chargedAmount;

  set chargedAmount(double value) {
    _chargedAmount = value;
  }

  double get appfee => _appfee;

  set appfee(double value) {
    _appfee = value;
  }

  int get merchantfee => _merchantfee;

  set merchantfee(int value) {
    _merchantfee = value;
  }

  int get merchantbearsfee => _merchantbearsfee;

  set merchantbearsfee(int value) {
    _merchantbearsfee = value;
  }

  String get chargeResponseCode => _chargeResponseCode;

  set chargeResponseCode(String value) {
    _chargeResponseCode = value;
  }

  String get chargeResponseMessage => _chargeResponseMessage;

  set chargeResponseMessage(String value) {
    _chargeResponseMessage = value;
  }

  String get authModelUsed => _authModelUsed;

  set authModelUsed(String value) {
    _authModelUsed = value;
  }

  String get currency => _currency;

  set currency(String value) {
    _currency = value;
  }

  String get ip => _ip;

  set ip(String value) {
    _ip = value;
  }

  String get narration => _narration;

  set narration(String value) {
    _narration = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get vbvrespmessage => _vbvrespmessage;

  set vbvrespmessage(String value) {
    _vbvrespmessage = value;
  }

  String get authurl => _authurl;

  set authurl(String value) {
    _authurl = value;
  }

  String get vbvrespcode => _vbvrespcode;

  set vbvrespcode(String value) {
    _vbvrespcode = value;
  }

  dynamic get acctvalrespmsg => _acctvalrespmsg;

  set acctvalrespmsg(dynamic value) {
    _acctvalrespmsg = value;
  }

  dynamic get acctvalrespcode => _acctvalrespcode;

  set acctvalrespcode(dynamic value) {
    _acctvalrespcode = value;
  }

  String get paymentType => _paymentType;

  set paymentType(String value) {
    _paymentType = value;
  }

  String get paymentId => _paymentId;

  set paymentId(String value) {
    _paymentId = value;
  }

  String get fraudStatus => _fraudStatus;

  set fraudStatus(String value) {
    _fraudStatus = value;
  }

  String get chargeType => _chargeType;

  set chargeType(String value) {
    _chargeType = value;
  }

  int get isLive => _isLive;

  set isLive(int value) {
    _isLive = value;
  }

  String get createdAt => _createdAt;

  set createdAt(String value) {
    _createdAt = value;
  }

  String get updatedAt => _updatedAt;

  set updatedAt(String value) {
    _updatedAt = value;
  }

  dynamic get deletedAt => _deletedAt;

  set deletedAt(dynamic value) {
    _deletedAt = value;
  }

  int get customerId => _customerId;

  set customerId(int value) {
    _customerId = value;
  }

  int get accountId => _accountId;

  set accountId(int value) {
    _accountId = value;
  }

  Customer get customer => _customer;

  set customer(Customer value) {
    _customer = value;
  }

  ValidateInstructions get validateInstructions => _validateInstructions;

  set validateInstructions(ValidateInstructions value) {
    _validateInstructions = value;
  }
}

class Customer {
  int _id;
  dynamic _phone;
  String _fullName;
  dynamic _customertoken;
  String _email;
  DateTime _createdAt;
  DateTime _updatedAt;
  dynamic _deletedAt;
  int _accountId;

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  void fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.phone = json["phone"];
    this.fullName = json["fullName"];
    this.customertoken = json["customertoken"];
    this.email = json["email"];
    this.createdAt = DateTime.parse(json["createdAt"]);
    this.updatedAt = DateTime.parse(json["updatedAt"]);
    this.deletedAt = json["deletedAt"];
    this.accountId = json["AccountId"];
  }

  dynamic get phone => _phone;

  set phone(dynamic value) {
    _phone = value;
  }

  String get fullName => _fullName;

  set fullName(String value) {
    _fullName = value;
  }

  dynamic get customertoken => _customertoken;

  set customertoken(dynamic value) {
    _customertoken = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  DateTime get createdAt => _createdAt;

  set createdAt(DateTime value) {
    _createdAt = value;
  }

  DateTime get updatedAt => _updatedAt;

  set updatedAt(DateTime value) {
    _updatedAt = value;
  }

  dynamic get deletedAt => _deletedAt;

  set deletedAt(dynamic value) {
    _deletedAt = value;
  }

  int get accountId => _accountId;

  set accountId(int value) {
    _accountId = value;
  }
}

class ValidateInstructions {
  List<String> _valparams;
  String _instruction;

  List<String> get valparams => _valparams;

  set valparams(List<String> value) {
    _valparams = value;
  }

  void fromJson(Map<String, dynamic> json) {
    this.valparams = new List<String>.from(json["valparams"].map((x) => x));
    this.instruction = json["instruction"];
  }

  String get instruction => _instruction;

  set instruction(String value) {
    _instruction = value;
  }
}
