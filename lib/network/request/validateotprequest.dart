class ValidateOtpRequest {
  String _apiKey;
  String _sessionid;
  String _otp;

  ValidateOtpRequest(this._apiKey, this._sessionid, this._otp);

  String get otp => _otp;

  String get sessionid => _sessionid;

  String get apiKey => _apiKey;

  Map toMap() {
    var data = Map();
    data['apiKey'] = apiKey;
    data['sessionId'] = sessionid;
    data['otp'] = otp;

    return data;
  }
}
