class SendOtpResponse {
  String _status;
  String _sessionKey;
  String _message;

  String get status => _status;

  String get sessionKey => _sessionKey;

  String get message => _message;

  set status(String value) {
    _status = value;
  }

  set message(String value) {
    _message = value;
  }

  set sessionKey(String value) {
    _sessionKey = value;
  }

  void fromMap(Map json) {
    if (json['Status'] != null && json['Status'] != "") {
      this.status = json['Status'];
    }

    if (json['Details'] != null && json['Details'] != "") {
      this.sessionKey = json['Details'];
    }

    if (json['Message'] != null && json['Message'] != "") {
      this.message = json['Message'];
    }
  }
}
