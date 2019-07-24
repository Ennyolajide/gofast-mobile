class SendOtpRequest {
  String _apiKey;
  String _phoneNumber;

  SendOtpRequest(this._apiKey, this._phoneNumber);

  String get apiKey => _apiKey;

  String get phoneNumber => _phoneNumber;

  Map toMap() {
    var data = Map();
    data['apiKey'] = apiKey;
    data['phoneNumber'] = phoneNumber;

    return data;
  }
}
