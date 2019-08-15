import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gofast/config/urlconstants.dart';
import 'package:gofast/network/request/addaccountrequest.dart';
import 'package:gofast/network/request/initiatepaymentrequest.dart';
import 'package:gofast/network/request/initiatetransferrequest.dart';
import 'package:gofast/network/request/sendotprequest.dart';
import 'package:gofast/network/request/validatechargerequest.dart';
import 'package:gofast/network/request/validateotprequest.dart';
import 'package:gofast/network/request/verifyaccchargerequest.dart';
import 'package:gofast/network/response/addaccountresponse.dart';
import 'package:gofast/network/response/fetchtransferresponse.dart';
import 'package:gofast/network/response/getchargebanksresponse.dart';
import 'package:gofast/network/response/gettransferbanksresponse.dart';
import 'package:gofast/network/response/initiatepaymentresponse.dart';
import 'package:gofast/network/response/initiatetransferresponse.dart';
import 'package:gofast/network/response/sendotpresponse.dart';
import 'package:gofast/network/response/validatechargeresponse.dart';
import 'package:gofast/network/response/validateotpresponse.dart';
import 'package:gofast/network/response/verifyaccchargeresponse.dart';
import 'package:gofast/utils/encryption.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  static const String message = "Message";
  static const String status = "Status";
  static const String details = "Details";

  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    print("Send otp request ----> ${request.toMap()}");

    String url =
        "https://2factor.in/API/V1/${request.apiKey}/SMS/${request.phoneNumber}/AUTOGEN/Gofast2";

    SendOtpResponse response = new SendOtpResponse();

    try {
      http.Response res =
          await http.get(url, headers: {"Content-Type": "application/json"});

      if (res.statusCode == HttpStatus.ok) {
        Map map = json.decode(res.body);

        if (map['Status'] == "Success") {
          map['Message'] = "OTP sent to device";
        }

        print(map);
        response.fromMap(map);
      } else if (res.statusCode == HttpStatus.internalServerError) {
        print(
            "****SEND OTP SERVICE**** Service temporarily down, please try again late");
        Map responseMap = new Map();
        responseMap[message] =
            "Service temporarily down, please try again later";
        responseMap[status] = "failure";
        responseMap[details] = "An Error occured, try again";

        response.fromMap(responseMap);
      } else if (res.statusCode == HttpStatus.notFound) {
        print(
            "****SEND OTP SERVICE**** Resource not found, please try again later");
        Map responseMap = new Map();
        responseMap[message] = "Resource not found, please try again later";
        responseMap[status] = "failure";
        responseMap[details] = "An Error occured, try again";

        response.fromMap(responseMap);
      } else {
        print(" ****SEND OTP SERVICE****   An error occurred");
        Map map = json.decode(res.body);
        map['Message'] = "An error occurred";

        response.fromMap(map);
      }
    } catch (e) {
      print("********** connection error");
      Map map = new Map();
      map[message] = "Connection Error, please check your internet connection";
      map[status] = "failure";
      map[details] = "";

      response.fromMap(map);
    }

    return response;
  }

  Future<ValidateOtpResponse> validateOtp(ValidateOtpRequest request) async {
    print("validate otp request ----> ${request.toMap()}");

    String url =
        "https://2factor.in/API/V1/${request.apiKey}/SMS/VERIFY/${request.sessionid}/${request.otp}";

    ValidateOtpResponse response = new ValidateOtpResponse();

    try {
      http.Response res =
          await http.get(url, headers: {"Content-Type": "application/json"});

      if (res.statusCode == HttpStatus.ok) {
        Map map = json.decode(res.body);

        print(map);
        response.fromMap(map);
      } else if (res.statusCode == HttpStatus.internalServerError) {
        print(
            "****Validate OTP SERVICE**** Service temporarily down, please try again later");
        Map map = new Map();

        map[status] = "failure";
        map[details] = "Service temporarily down, please try again later";

        response.fromMap(map);
      } else if (res.statusCode == HttpStatus.notFound) {
        print(
            "****Validate OTP SERVICE**** Resource not found, please try again later");
        Map map = new Map();

        map[status] = "failure";
        map[details] = "Resource not found, please try again later";

        response.fromMap(map);
      } else {
        print(
            " ****SEND OTP SERVICE****   Connection erroR, please check your internet connection");
        Map map = json.decode(res.body);

        response.fromMap(map);
      }
    } catch (e) {
      print("****SEND OTP SERVICE**** connection error");
      Map map = new Map();

      map[status] = "failure";
      map[details] = "Connection Error, please check your internet connection";

      response.fromMap(map);
    }

    return response;
  }

  Future<ChargeBankResponse> getChargedBanks() async {
    print("Get charged banks request ----> ");

    String url =
        "${UrlConstants.RAVE_BASE_URL}/flwv3-pug/getpaidx/api/flwpbf-banks.js?json=1";

    ChargeBankResponse response = new ChargeBankResponse();

    try {
      http.Response res = await http.get(url);

      if (res.statusCode == HttpStatus.ok) {
        Map<String, dynamic> map = new Map();

        map["banks"] = json.decode(res.body);
        map[status] = "success";
        map[message] = "Banks successfully fetched";
        print("List of banks are ---> ${json.decode(res.body)}");

        response.fromMap(map);
      } else if (res.statusCode == HttpStatus.internalServerError) {
        print(
            "****Get charged banks request**** Service temporarily down, please try again late");
        Map map = new Map();

        map[status] = "failure";
        map[message] = "Service temporarily down, please try again later";

        response.fromMap(map);
      } else if (res.statusCode == HttpStatus.notFound) {
        print(
            "****Get charged banks request**** Resource not found, please try again later");
        Map map = new Map();

        map[status] = "failure";
        map[message] = "Resource not found, please try again later";

        response.fromMap(map);
      } else {
        print(
            " ****SEND OTP SERVICE****   Connection erroR, please check your internet connection");
        Map map = new Map();

        map[status] = "failure";
        map[message] =
            "Connection Error, please check your internet connection";

        response.fromMap(map);
      }
    } catch (e) {
      print("****Get charged banks request**** ${e.toString()}");
      Map map = new Map();

      map[status] = "failure";
      map[message] = "Connection Error, please check your internet connection";

      response.fromMap(map);
    }

    return response;
  }

  Future<AddAccountResponse> addAccount(AddAccountRequest request) async {
    print("Add account request ----> ${request.toMap()}");

    String url =
        "${UrlConstants.RAVE_BASE_URL}/flwv3-pug/getpaidx/api/resolve_account";

    AddAccountResponse response = new AddAccountResponse();

    try {
      http.Response res = await http.post(url,
          body: json.encode(request.toMap()),
          headers: {"Content-Type": "application/json"});
      print("response body is ---> ${json.decode(res.body)}");
      if (res.statusCode == HttpStatus.ok) {
        Map map = json.decode(res.body);

        response.fromMap(map);
      } else if (res.statusCode == HttpStatus.internalServerError) {
        print(
            "****Add account request**** Service temporarily down, please try again late");
        Map map = new Map();

        map["status"] = "failure";
        map["message"] = "Service temporarily down, please try again later";

        response.fromMap(map);
      } else if (res.statusCode == HttpStatus.notFound) {
        print(
            "****Add account request**** Resource not found, please try again later");
        Map map = new Map();

        map["status"] = "failure";
        map["message"] = "Resource not found, please try again later";

        response.fromMap(map);
      } else {
        print(
            " ****Add accounts request****   Connection error, please check your internet connection");
        Map map = new Map();

        map["status"] = "failure";
        map["message"] =
            "Connection Error, please check your internet connection";

        response.fromMap(map);
      }
    } catch (e) {
      print("****Add account request request**** ${e.toString()}");
      Map map = new Map();

      map["status"] = "failure";
      map["message"] =
          "Connection Error, please check your internet connection";

      response.fromMap(map);
    }

    return response;
  }

  Future<TransferBanksResponse> getTransferBanks(
      String country, String pubKey) async {
    print(
        "Get transfer banks request ----> country ->${country}  --> pubkey --> ${pubKey}");

    String url =
        "${UrlConstants.RAVE_BASE_URL}/v2/banks/$country?public_key=$pubKey";

    TransferBanksResponse response = new TransferBanksResponse();

    try {
      http.Response res =
          await http.get(url, headers: {"Content-Type": "application/json"});
      print(
          "response body for get transfer banks is ---> ${json.decode(res.body)}");
      if (res.statusCode == HttpStatus.ok) {
        Map<String, dynamic> map = json.decode(res.body);

        response.fromMap(map);
      } else if (res.statusCode == HttpStatus.internalServerError) {
        print(
            "****Get transfer banks request**** Service temporarily down, please try again late");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = "Service temporarily down, please try again later";

        response.fromMap(map);
      } else if (res.statusCode == HttpStatus.notFound) {
        print(
            "****Get transfer banks request**** Resource not found, please try again later");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = "Resource not found, please try again later";

        response.fromMap(map);
      } else {
        print(
            " ****Get transfer banks request****   Connection error, please check your internet connection");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] =
            "Connection Error, please check your internet connection";

        response.fromMap(map);
      }
    } catch (e) {
      print("****Get transfer banks request**** ${e.toString()}");
      Map<String, dynamic> map = new Map();

      map["status"] = "failure";
      map["message"] =
          "Connection Error, please check your internet connection";

      response.fromMap(map);
    }

    return response;
  }

  Future<http.Response> chargeCard({
    String cardNo,
    String cvv,
    String expMonth,
    String expYear,
    String currency,
    String country,
    String amount,
    String pin,
    String suggested_auth,
    String email,
    String billingzip,
    String billingcity,
    String billingaddress,
    String billingstate,
    String billingcountry,
    // String firstName,
    // String lastName,
    // String ip,
    String txtRef,
  }) async {
    try {
      String url =
          "${UrlConstants.RAVE_BASE_URL}/flwv3-pug/getpaidx/api/charge";
      dynamic body;
      if (suggested_auth == null) {
        body = {
          "PBFPubKey": UrlConstants.LIVE_PUBLIC_KEY,
          "cardno": cardNo,
          "cvv": cvv,
          "expirymonth": expMonth,
          "expiryyear": expYear,
          "currency": currency,
          "country": country,
          "amount": amount,
          "email": email,
          // "phonenumber": phoneNumber,
          // "firstname": firstName,
          // "lastname": lastName,
          // "IP": ip,
          "txRef": txtRef, // your unique merchant reference
          // "meta": new Map([{ metaname: "flightID", metavalue: "123949494DC"}]),
          "redirect_url": UrlConstants.FLUTTERWAVE_REDIRECT_URL,
          // "device_fingerprint": "69e6b7f0b72037aa8428b70fbe03986c"
        };
      } else {
        switch (suggested_auth) {
          case "PIN":
            body = {
              "PBFPubKey": UrlConstants.LIVE_PUBLIC_KEY,
              "cardno": cardNo,
              "cvv": cvv,
              "expirymonth": expMonth,
              "expiryyear": expYear,
              "currency": currency,
              "country": country,
              "amount": amount,
              "suggested_auth": suggested_auth,
              "pin": pin,
              "email": email,
              // "email": email,
              // "phonenumber": phoneNumber,
              // "firstname": firstName,
              // "lastname": lastName,
              // "IP": ip,
              "txRef": txtRef, // your unique merchant reference
              // "meta": new Map([{ metaname: "flightID", metavalue: "123949494DC"}]),
              "redirect_url":
                  "https://rave-webhook.herokuapp.com/receivepayment",
              // "device_fingerprint": "69e6b7f0b72037aa8428b70fbe03986c"
            };
            break;
          case "NOAUTH_INTERNATIONAL":
            body = {
              "PBFPubKey": UrlConstants.LIVE_PUBLIC_KEY,
              "cardno": cardNo,
              "cvv": cvv,
              "expirymonth": expMonth,
              "expiryyear": expYear,
              "currency": currency,
              "country": country,
              "amount": amount,
              "suggested_auth": suggested_auth,
              "pin": pin,
              "email": email,
              "suggested_auth": "NOAUTH_INTERNATIONAL",
              "billingzip": billingzip,
              "billingcity": billingcity,
              "billingaddress": billingaddress,
              "billingstate": billingstate,
              "billingcountry": billingcountry,
              "txRef": txtRef, // your unique merchant reference
              // "meta": new Map([{ metaname: "flightID", metavalue: "123949494DC"}]),
              "redirect_url":
                  "https://rave-webhook.herokuapp.com/receivepayment",
              // "device_fingerprint": "69e6b7f0b72037aa8428b70fbe03986c"
            };
            break;
          default:
            throw ("Card Not Supported");
        }
      }
      Encryption _encryption =
          new Encryption(secretKey: UrlConstants.LIVE_SECRET_KEY);

      String client = _encryption.encrypt(body);

      http.Response res = await http.post(url,
          body: json.encode({
            "PBFPubKey": UrlConstants.LIVE_PUBLIC_KEY,
            "client": client,
            "alg": "3DES-24"
          }),
          headers: {"Content-Type": "application/json"});

      return res;
    } catch (e) {
      print("Charging Card Error:--->$e");
      throw e;
    }
  }
  
  Future<http.Response> validateCharge({
    String transaction_reference,
    String otp,
  }) async {
    try {
      String url =
          "${UrlConstants.RAVE_BASE_URL}/flwv3-pug/getpaidx/api/validatecharge";
      dynamic body = {
          "PBFPubKey": UrlConstants.LIVE_PUBLIC_KEY,
          "transaction_reference": transaction_reference,
          "otp": otp
        };
      
      // Encryption _encryption =
      //     new Encryption(secretKey: UrlConstants.LIVE_SECRET_KEY);
      // String client = _encryption.encrypt(body);

      http.Response res = await http.post(url,
          body: json.encode(body),
          headers: {"Content-Type": "application/json"});

      return res;
    } catch (e) {
      print("Validating Card Charge Error:--->$e");
      throw e;
    }
  }

  Future<InitiatePaymentResponse> initiateAccountCharge(
      InitiatePaymentRequest request) async {
    print("Initiate charge request ----> ${request.toJson()}");

    String url = "${UrlConstants.RAVE_BASE_URL}/flwv3-pug/getpaidx/api/charge";
    InitiatePaymentResponse response = new InitiatePaymentResponse();

    try {
      http.Response res = await http.post(url,
          body: json.encode(request.toJson()),
          headers: {"Content-Type": "application/json"});
      print("response body is ---> ${json.decode(res.body)}");
      if (res.statusCode == HttpStatus.ok) {
        Map map = json.decode(res.body);

        response.fromJson(map);
      } else if (res.statusCode == HttpStatus.internalServerError) {
        print(
            "****Initiate charge**** Service temporarily down, please try again late");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = "Service temporarily down, please try again later";

        response.fromJson(map);
      } else if (res.statusCode == HttpStatus.notFound) {
        print(
            "****Initiate charge**** Resource not found, please try again later");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = "Resource not found, please try again later";

        response.fromJson(map);
      } else {
        print(
            " ****Initiate charge****   Connection error, please check your internet connection");
        Map mapp = json.decode(res.body);
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = mapp['message'];

        response.fromJson(map);
      }
    } catch (e) {
      print("****Initiate charge**** ${e.toString()}");
      Map<String, dynamic> map = new Map();

      map["status"] = "failure";
      map["message"] =
          "Connection Error, please check your internet connection";

      response.fromJson(map);
    }

    return response;
  }

  Future<ValidateChargeResponse> validateAccountCharge(
      ValidateChargeRequest request) async {
    print("Validate account request ----> ${request.toMap()}");

    String url =
        "${UrlConstants.RAVE_BASE_URL}/flwv3-pug/getpaidx/api/validate";
    ValidateChargeResponse response = new ValidateChargeResponse();

    try {
      http.Response res = await http.post(url,
          body: json.encode(request.toMap()),
          headers: {"Content-Type": "application/json"});
      print("response body is ---> ${json.decode(res.body)}");
      if (res.statusCode == HttpStatus.ok) {
        Map<String, dynamic> map = json.decode(res.body);

        response.fromJson(map);
      } else if (res.statusCode == HttpStatus.internalServerError) {
        print(
            "****Validate charge request**** Service temporarily down, please try again late");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = "Service temporarily down, please try again later";

        response.fromJson(map);
      } else if (res.statusCode == HttpStatus.notFound) {
        print(
            "****Validate charge request**** Resource not found, please try again later");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = "Resource not found, please try again later";

        response.fromJson(map);
      } else {
        print(
            " ****Validate charge request****   Connection error, please check your internet connection");
        Map mapp = json.decode(res.body);
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = mapp['message'];

        response.fromJson(map);
      }
    } catch (e) {
      print("****Validate charge**** ${e.toString()}");
      Map<String, dynamic> map = new Map();

      map["status"] = "failure";
      map["message"] =
          "Connection Error, please check your internet connection";

      response.fromJson(map);
    }

    return response;
  }

  Future<VerifyAccountChargeResponse> verifyAccountCharge(
      VerifyAccountChargeRequest request) async {
    print("Verify account request ----> ${request.toMap()}");

    String url =
        "${UrlConstants.RAVE_BASE_URL}/flwv3-pug/getpaidx/api/v2/verify";
    VerifyAccountChargeResponse response = new VerifyAccountChargeResponse();

    try {
      http.Response res = await http.post(url,
          body: json.encode(request.toMap()),
          headers: {"Content-Type": "application/json"});
      print("response body is ---> ${json.decode(res.body)}");
      if (res.statusCode == HttpStatus.ok) {
        Map<String, dynamic> map = json.decode(res.body);

        response.fromJson(map);
      } else if (res.statusCode == HttpStatus.internalServerError) {
        print(
            "****Verify charge request**** Service temporarily down, please try again late");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = "Service temporarily down, please try again later";

        response.fromJson(map);
      } else if (res.statusCode == HttpStatus.notFound) {
        print(
            "****Verify charge request**** Resource not found, please try again later");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = "Resource not found, please try again later";

        response.fromJson(map);
      } else {
        print(
            " ****Verify charge request****   Connection error, please check your internet connection");
        Map mapp = json.decode(res.body);
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = mapp['message'];

        response.fromJson(map);
      }
    } catch (e) {
      print("****Verify charge**** ${e.toString()}");
      Map<String, dynamic> map = new Map();

      map["status"] = "failure";
      map["message"] =
          "Connection Error, please check your internet connection";

      response.fromJson(map);
    }

    return response;
  }

  Future<InitiateTransferResponse> initiateTransfer(
      InitiateTransferRequest request) async {
    print("initiate Transfer request ----> ${request.toMap()}");

    String url = "${UrlConstants.RAVE_BASE_URL}/v2/gpx/transfers/create";
    InitiateTransferResponse response = new InitiateTransferResponse();

    try {
      http.Response res = await http.post(url,
          body: json.encode(request.toMap()),
          headers: {"Content-Type": "application/json"});
      print("response body is ---> ${json.decode(res.body)}");
      if (res.statusCode == HttpStatus.ok) {
        Map<String, dynamic> map = json.decode(res.body);

        response.fromJson(map);
      } else if (res.statusCode == HttpStatus.internalServerError) {
        print(
            "****initiate Transfer**** Service temporarily down, please try again late");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = "Service temporarily down, please try again later";

        response.fromJson(map);
      } else if (res.statusCode == HttpStatus.notFound) {
        print(
            "****initiate Transfer**** Resource not found, please try again later");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = "Resource not found, please try again later";

        response.fromJson(map);
      } else {
        print(
            " ****initiate Transfer****   Connection error, please check your internet connection");
        Map mapp = json.decode(res.body);
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = mapp['message'];

        response.fromJson(map);
      }
    } catch (e) {
      print("****initiate Transfer**** ${e.toString()}");
      Map<String, dynamic> map = new Map();

      map["status"] = "failure";
      map["message"] =
          "Connection Error, please check your internet connection";

      response.fromJson(map);
    }

    return response;
  }

  Future<FetchTransferResponse> fetchTransfer(String secKey) async {
    String url =
        "${UrlConstants.RAVE_BASE_URL}/v2/gpx/transfers?seckey=$secKey'";
    FetchTransferResponse response = new FetchTransferResponse();

    try {
      http.Response res =
          await http.get(url, headers: {"Content-Type": "application/json"});
      print("response body is ---> ${json.decode(res.body)}");
      if (res.statusCode == HttpStatus.ok) {
        Map<String, dynamic> map = json.decode(res.body);

        response.fromJson(map);
      } else if (res.statusCode == HttpStatus.internalServerError) {
        print(
            "****Fetch Transfer**** Service temporarily down, please try again late");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = "Service temporarily down, please try again later";

        response.fromJson(map);
      } else if (res.statusCode == HttpStatus.notFound) {
        print(
            "****Fetch Transfer**** Resource not found, please try again later");
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = "Resource not found, please try again later";

        response.fromJson(map);
      } else {
        print(
            " ****Fetch Transfer****   Connection error, please check your internet connection");
        Map mapp = json.decode(res.body);
        Map<String, dynamic> map = new Map();

        map["status"] = "failure";
        map["message"] = mapp['message'];

        response.fromJson(map);
      }
    } catch (e) {
      print("****Fetch charge**** ${e.toString()}");
      Map<String, dynamic> map = new Map();

      map["status"] = "failure";
      map["message"] =
          "Connection Error, please check your internet connection";

      response.fromJson(map);
    }

    return response;
  }
}
