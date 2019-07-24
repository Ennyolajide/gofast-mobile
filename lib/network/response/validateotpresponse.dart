class ValidateOtpResponse {
  String _status;
  String _message;

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  String get message => _message;

  set message(String value) {
    _message = value;
  }

  void fromMap(Map json) {
    if (json['Status'] != null && json['Status'] != "") {
      this.status = json['Status'];
    }

    if (json['Details'] != null && json['Details'] != "") {
      this.message = json['Details'];
    }
  }
}
