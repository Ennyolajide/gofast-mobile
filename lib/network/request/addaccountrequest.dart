import 'package:gofast/config/urlconstants.dart';

class AddAccountRequest {
  String _account;
  String _bankCode;

  AddAccountRequest(this._account, this._bankCode);

  String get bankCode => _bankCode;

  String get account => _account;

  Map toMap() {
    var data = new Map();
    data['recipientaccount'] = account;
    data['destbankcode'] = bankCode;
    data['PBFPubKey'] = UrlConstants.LIVE_PUBLIC_KEY;

    return data;
  }
}
