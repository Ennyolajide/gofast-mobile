class FetchTransferResponse {
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
  PageInfo _pageInfo;
  List<Transfer> _transfers;

  PageInfo get pageInfo => _pageInfo;

  set pageInfo(PageInfo value) {
    _pageInfo = value;
  }

  List<Transfer> get transfers => _transfers;

  set transfers(List<Transfer> value) {
    _transfers = value;
  }

  void fromJson(Map json) {
    if (json['page_info'] != null) {
      PageInfo _pageInfo = PageInfo();
      _pageInfo.fromJson(json['page_info']);
      this.pageInfo = _pageInfo;
    }

    if (json['transfers'] != null) {
      List<Transfer> transferList = List();
      json['transfers'].forEach((json) {
        Transfer transfer = new Transfer();
        transfer.fromMap(json);
        transferList.add(transfer);
      });
      this.transfers = transferList;
    }
  }
}

class PageInfo {
  int _total;
  int _currentPage;
  int _totalPages;

  int get total => _total;

  set total(int value) {
    _total = value;
  }

  int get currentPage => _currentPage;

  set currentPage(int value) {
    _currentPage = value;
  }

  int get totalPages => _totalPages;

  set totalPages(int value) {
    _totalPages = value;
  }

  void fromJson(Map json) {
    if (json['total'] != null) {
      this.total = json['total'];
    }

    if (json['current_page'] != null) {
      this.currentPage = json['current_page'];
    }

    if (json["total_pages"] != null) {
      this.totalPages = json['total_pages'];
    }
  }
}

class Transfer {
  int id;
  String _accountNumber;
  String _bankCode;
  String _fullname;
  String _dateCreated;
  String _currency;
  int _amount;
  int _fee;
  String _status;
  String _narration;
  var _approver;
  String _completeMessage;
  int _requiresApproval;
  int _isApproved;
  String _bankName;

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

  String get currency => _currency;

  set currency(String value) {
    _currency = value;
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

  String get narration => _narration;

  set narration(String value) {
    _narration = value;
  }

  get approver => _approver;

  set approver(var value) {
    _approver = value;
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

  void fromMap(Map json) {
    this.id = json['id'];
    this.accountNumber = json['account_number'];
    this.bankCode = json['bank_code'];
    this.fullname = json['fullname'];
    this.dateCreated = json['date_created'];
    this.currency = json['currency'];
    this.amount = json['amount'];
    this.fee = json['fee'];
    this.status = json['status'];
    this.narration = json['narration'];
    this.approver = json['approver'];
    this.completeMessage = json['complete_message'];
    this.requiresApproval = json['requires_approval'];
    this.isApproved = json['is_approved'];
    this.bankName = json['bank_name'];
  }
}
