class VerifyAccountChargeResponse {
  String _status;
  String _message;
  Data _data;

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  void fromJson(Map<String, dynamic> json) {
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

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  Data get data => _data;

  set data(Data value) {
    _data = value;
  }
}

class Data {
  int _txid;
  String _txref;
  String _flwref;
  String _devicefingerprint;
  String _cycle;
  double _amount;
  String _currency;
  double _chargedamount;
  double _appfee;
  int _merchantfee;
  int _merchantbearsfee;
  String _chargecode;
  String _chargemessage;
  String _authmodel;
  String _ip;
  String _narration;
  String _status;
  String _vbvcode;
  String _vbvmessage;
  String _authurl;
  dynamic _acctcode;
  dynamic _acctmessage;
  String _paymenttype;
  String _paymentid;
  String _fraudstatus;
  String _chargetype;
  int _createdday;
  String _createddayname;
  int _createdweek;
  int _createdmonth;
  String _createdmonthname;
  int _createdquarter;
  int _createdyear;
  bool _createdyearisleap;
  int _createddayispublicholiday;
  int _createdhour;
  int _createdminute;
  String _createdpmam;
  String _created;
  int _customerid;
  String _custphone;
  String _custnetworkprovider;
  String _custname;
  String _custemail;
  String _custemailprovider;
  String _custcreated;
  int _accountid;
  String _acctbusinessname;
  String _acctcontactperson;
  String _acctcountry;
  int _acctbearsfeeattransactiontime;
  int _acctparent;
  String _acctvpcmerchant;
  String _acctalias;
  int _acctisliveapproved;
  String _orderref;
  dynamic _paymentplan;
  dynamic _paymentpage;
  String _raveref;
  Account _account;
  List<dynamic> _meta;

  int get txid => _txid;

  set txid(int value) {
    _txid = value;
  }

  void fromJson(Map<String, dynamic> json) {
    this.txid = json["txid"];
    this.txref = json["txref"];
    this.flwref = json["flwref"];
    this.devicefingerprint = json["devicefingerprint"];
    this.cycle = json["cycle"];
    this.amount = json["amount"];
    this.currency = json["currency"];
    this.chargedamount = json["chargedamount"];
    this.appfee = json["appfee"];
    this.merchantfee = json["merchantfee"];
    this.merchantbearsfee = json["merchantbearsfee"];
    this.chargecode = json["chargecode"];
    this.chargemessage = json["chargemessage"];
    this.authmodel = json["authmodel"];
    this.ip = json["ip"];
    this.narration = json["narration"];
    this.status = json["status"];
    this.vbvcode = json["vbvcode"];
    this.vbvmessage = json["vbvmessage"];
    this.authurl = json["authurl"];
    this.acctcode = json["acctcode"];
    this.acctmessage = json["acctmessage"];
    this.paymenttype = json["paymenttype"];
    this.paymentid = json["paymentid"];
    this.fraudstatus = json["fraudstatus"];
    this.chargetype = json["chargetype"];
    this.createdday = json["createdday"];
    this.createddayname = json["createddayname"];
    this.createdweek = json["createdweek"];
    this.createdmonth = json["createdmonth"];
    this.createdmonthname = json["createdmonthname"];
    this.createdquarter = json["createdquarter"];
    this.createdyear = json["createdyear"];
    this.createdyearisleap = json["createdyearisleap"];
    this.createddayispublicholiday = json["createddayispublicholiday"];
    this.createdhour = json["createdhour"];
    this.createdminute = json["createdminute"];
    this.createdpmam = json["createdpmam"];
    this.created = json["created"];
    this.customerid = json["customerid"];
    this.custphone = json["custphone"];
    this.custnetworkprovider = json["custnetworkprovider"];
    this.custname = json["custname"];
    this.custemail = json["custemail"];
    this.custemailprovider = json["custemailprovider"];
    this.custcreated = json["custcreated"];
    this.accountid = json["accountid"];
    this.acctbusinessname = json["acctbusinessname"];
    this.acctcontactperson = json["acctcontactperson"];
    this.acctcountry = json["acctcountry"];
    this.acctbearsfeeattransactiontime = json["acctbearsfeeattransactiontime"];
    this.acctparent = json["acctparent"];
    this.acctvpcmerchant = json["acctvpcmerchant"];
    this.acctalias = json["acctalias"];
    this.acctisliveapproved = json["acctisliveapproved"];
    this.orderref = json["orderref"];
    this.paymentplan = json["paymentplan"];
    this.paymentpage = json["paymentpage"];
    this.raveref = json["raveref"];
    this.meta = new List<dynamic>.from(json["meta"].map((x) => x));

    if (json["account"] != null) {
      Account acc = new Account();
      acc.fromJson(json["account"]);
      this.account = acc;
    }
  }

  String get txref => _txref;

  set txref(String value) {
    _txref = value;
  }

  String get flwref => _flwref;

  set flwref(String value) {
    _flwref = value;
  }

  String get devicefingerprint => _devicefingerprint;

  set devicefingerprint(String value) {
    _devicefingerprint = value;
  }

  String get cycle => _cycle;

  set cycle(String value) {
    _cycle = value;
  }

  double get amount => _amount;

  set amount(double value) {
    _amount = value;
  }

  String get currency => _currency;

  set currency(String value) {
    _currency = value;
  }

  double get chargedamount => _chargedamount;

  set chargedamount(double value) {
    _chargedamount = value;
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

  String get chargecode => _chargecode;

  set chargecode(String value) {
    _chargecode = value;
  }

  String get chargemessage => _chargemessage;

  set chargemessage(String value) {
    _chargemessage = value;
  }

  String get authmodel => _authmodel;

  set authmodel(String value) {
    _authmodel = value;
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

  String get vbvcode => _vbvcode;

  set vbvcode(String value) {
    _vbvcode = value;
  }

  String get vbvmessage => _vbvmessage;

  set vbvmessage(String value) {
    _vbvmessage = value;
  }

  String get authurl => _authurl;

  set authurl(String value) {
    _authurl = value;
  }

  dynamic get acctcode => _acctcode;

  set acctcode(dynamic value) {
    _acctcode = value;
  }

  dynamic get acctmessage => _acctmessage;

  set acctmessage(dynamic value) {
    _acctmessage = value;
  }

  String get paymenttype => _paymenttype;

  set paymenttype(String value) {
    _paymenttype = value;
  }

  String get paymentid => _paymentid;

  set paymentid(String value) {
    _paymentid = value;
  }

  String get fraudstatus => _fraudstatus;

  set fraudstatus(String value) {
    _fraudstatus = value;
  }

  String get chargetype => _chargetype;

  set chargetype(String value) {
    _chargetype = value;
  }

  int get createdday => _createdday;

  set createdday(int value) {
    _createdday = value;
  }

  String get createddayname => _createddayname;

  set createddayname(String value) {
    _createddayname = value;
  }

  int get createdweek => _createdweek;

  set createdweek(int value) {
    _createdweek = value;
  }

  int get createdmonth => _createdmonth;

  set createdmonth(int value) {
    _createdmonth = value;
  }

  String get createdmonthname => _createdmonthname;

  set createdmonthname(String value) {
    _createdmonthname = value;
  }

  int get createdquarter => _createdquarter;

  set createdquarter(int value) {
    _createdquarter = value;
  }

  int get createdyear => _createdyear;

  set createdyear(int value) {
    _createdyear = value;
  }

  bool get createdyearisleap => _createdyearisleap;

  set createdyearisleap(bool value) {
    _createdyearisleap = value;
  }

  int get createddayispublicholiday => _createddayispublicholiday;

  set createddayispublicholiday(int value) {
    _createddayispublicholiday = value;
  }

  int get createdhour => _createdhour;

  set createdhour(int value) {
    _createdhour = value;
  }

  int get createdminute => _createdminute;

  set createdminute(int value) {
    _createdminute = value;
  }

  String get createdpmam => _createdpmam;

  set createdpmam(String value) {
    _createdpmam = value;
  }

  String get created => _created;

  set created(String value) {
    _created = value;
  }

  int get customerid => _customerid;

  set customerid(int value) {
    _customerid = value;
  }

  String get custphone => _custphone;

  set custphone(String value) {
    _custphone = value;
  }

  String get custnetworkprovider => _custnetworkprovider;

  set custnetworkprovider(String value) {
    _custnetworkprovider = value;
  }

  String get custname => _custname;

  set custname(String value) {
    _custname = value;
  }

  String get custemail => _custemail;

  set custemail(String value) {
    _custemail = value;
  }

  String get custemailprovider => _custemailprovider;

  set custemailprovider(String value) {
    _custemailprovider = value;
  }

  String get custcreated => _custcreated;

  set custcreated(String value) {
    _custcreated = value;
  }

  int get accountid => _accountid;

  set accountid(int value) {
    _accountid = value;
  }

  String get acctbusinessname => _acctbusinessname;

  set acctbusinessname(String value) {
    _acctbusinessname = value;
  }

  String get acctcontactperson => _acctcontactperson;

  set acctcontactperson(String value) {
    _acctcontactperson = value;
  }

  String get acctcountry => _acctcountry;

  set acctcountry(String value) {
    _acctcountry = value;
  }

  int get acctbearsfeeattransactiontime => _acctbearsfeeattransactiontime;

  set acctbearsfeeattransactiontime(int value) {
    _acctbearsfeeattransactiontime = value;
  }

  int get acctparent => _acctparent;

  set acctparent(int value) {
    _acctparent = value;
  }

  String get acctvpcmerchant => _acctvpcmerchant;

  set acctvpcmerchant(String value) {
    _acctvpcmerchant = value;
  }

  String get acctalias => _acctalias;

  set acctalias(String value) {
    _acctalias = value;
  }

  int get acctisliveapproved => _acctisliveapproved;

  set acctisliveapproved(int value) {
    _acctisliveapproved = value;
  }

  String get orderref => _orderref;

  set orderref(String value) {
    _orderref = value;
  }

  dynamic get paymentplan => _paymentplan;

  set paymentplan(dynamic value) {
    _paymentplan = value;
  }

  dynamic get paymentpage => _paymentpage;

  set paymentpage(dynamic value) {
    _paymentpage = value;
  }

  String get raveref => _raveref;

  set raveref(String value) {
    _raveref = value;
  }

  Account get account => _account;

  set account(Account value) {
    _account = value;
  }

  List<dynamic> get meta => _meta;

  set meta(List<dynamic> value) {
    _meta = value;
  }
}

class Account {
  int _id;
  String _accountNumber;
  String _accountBank;
  String _firstName;
  String _lastName;
  int _accountIsBlacklisted;
  String _createdAt;
  String _updatedAt;
  dynamic _deletedAt;
  AccountToken _accountToken;

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  void fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.accountNumber = json["account_number"];
    this.accountBank = json["account_bank"];
    this.firstName = json["first_name"];
    this.lastName = json["last_name"];
    this.accountIsBlacklisted = json["account_is_blacklisted"];
    this.createdAt = json["createdAt"];
    this.updatedAt = json["updatedAt"];
    this.deletedAt = json["deletedAt"];
    if (json["account_token"] != null) {
      AccountToken accToken = new AccountToken();
      accToken.fromJson(json["account_token"]);
      this.accountToken = accToken;
    }
  }

  String get accountNumber => _accountNumber;

  set accountNumber(String value) {
    _accountNumber = value;
  }

  String get accountBank => _accountBank;

  set accountBank(String value) {
    _accountBank = value;
  }

  String get firstName => _firstName;

  set firstName(String value) {
    _firstName = value;
  }

  String get lastName => _lastName;

  set lastName(String value) {
    _lastName = value;
  }

  int get accountIsBlacklisted => _accountIsBlacklisted;

  set accountIsBlacklisted(int value) {
    _accountIsBlacklisted = value;
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

  AccountToken get accountToken => _accountToken;

  set accountToken(AccountToken value) {
    _accountToken = value;
  }
}

class AccountToken {
  String _token;

  String get token => _token;

  set token(String value) {
    _token = value;
  }

  void fromJson(Map<String, dynamic> json) {
    this.token = json["token"];
  }
}
