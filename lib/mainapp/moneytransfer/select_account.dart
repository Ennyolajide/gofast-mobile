import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/config/urlconstants.dart';
import 'package:gofast/mainapp/moneytransfer/initiatechargeotp.dart';
import 'package:gofast/network/apiservice.dart';
import 'package:gofast/network/request/chargeaccountrequest.dart';
import 'package:gofast/network/request/initiatepaymentrequest.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/encryption.dart';
import 'package:gofast/utils/utils.dart';

Map<String, dynamic> countrySymbol = {
  "Nigeria": "NGN",
  "Ghana": "GHS",
  "Kenya": "KES",
  "Uganda": "UGX",
  "Tanzania": "TZS",
  "South Africa": "ZAR",
};

class SelectAccount extends StatefulWidget {
  String accountNumber;
  String amount;
  String transferAmount;
  String remarks;
  String bvn;
  String bankCode;
  String currency;
  String beneficiaryName;

  SelectAccount(
      {this.accountNumber,
      this.amount,
      this.transferAmount,
      this.remarks,
      this.bvn,
      this.bankCode,
      this.currency,
      this.beneficiaryName});

  @override
  _SelectAccountState createState() => _SelectAccountState();
}

class _SelectAccountState extends State<SelectAccount>
    with TickerProviderStateMixin {
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  FirebaseUser _currentUser;
  bool _uidLoaded = false;
  bool _isShowing = false;
  BuildContext _dialogContext;
  String _dialogMessage = "Initiating charge...";
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _initPreferences();
  }

  _initPreferences() {
    Preferences.init().then((prefs) {});
  }

  void _getCurrentUser() {
    _mAuth.currentUser().then((user) {
      if (user != null) {
        setState(() {
          _currentUser = user;
          _uidLoaded = true;
        });
        print("user id is ---->${_currentUser.uid}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: AppColors.buttonColor,
          title: Text('Select Account(Tap to select)',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ),
        body: (_uidLoaded)
            ? StreamBuilder(
                stream: _firestore
                    .collection("Users")
                    .document(_currentUser.uid)
                    .collection("Accounts")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.buttonColor)));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'An error occurred retrieving accounts',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: AppColors.textColor, fontSize: 16),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data.documents.length > 0) {
                      return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                _performVerification(
                                    bankCode: snapshot.data.documents[index]
                                        ['BankCode'],
                                    accountNumber: snapshot
                                        .data.documents[index]['AccountNumber'],
                                    bvn: widget.bvn);
                              },
                              child: _buildAccountItem(
                                  snapshot.data.documents[index]),
                            );
                          });
                    } else {
                      return Center(
                        child: Container(
                          child: Text(
                            'You have no accounts',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }
                  }
                },
              )
            : SizedBox(),
      ),
    );
  }

  void _performVerification(
      {String bankCode, String accountNumber, String bvn}) {
    _showDialog(_dialogMessage);
    if (_currentUser != null) {
      _firestore
          .collection("Users")
          .document(_currentUser.uid)
          .get()
          .then((snapShot) {
        String onlineUserId = snapShot.data['deviceId'];
        if (onlineUserId == Preferences.deviceId) {
          _initiateCharge(
              bankCode: bankCode, bvn: bvn, accountNumber: accountNumber);
        } else {
          _removeDialog();
          Utils.showErrorDialog(context, "Authentication failed!",
              "You have been signed out of this device.");
        }
      });
//          .catchError((e) {
//        _removeDialog();
//        Utils.showErrorDialog(context, "Error", "An error occured try Again");
//      });
    } else {
      _removeDialog();
      Utils.showErrorDialog(context, "Authentication failed!",
          "You have been signed out of this device.");
    }
  }

  void _initiateCharge({String bankCode, String accountNumber, String bvn}) {
    print("Account number and code is $accountNumber and $bankCode");
    String transactionRef =
        '${new DateTime.now().millisecondsSinceEpoch.toString()}${new DateTime.now().millisecondsSinceEpoch}';

    InitiateChargeAccountRequest chargeAccountRequest =
        new InitiateChargeAccountRequest();
    String passcode = Preferences.dob.toString().replaceAll("/", '');
    print("passcode is ---> $passcode");

    chargeAccountRequest.bankCode = bankCode;
    chargeAccountRequest.lastname = Preferences.lastname;
    chargeAccountRequest.firstname = Preferences.firstname;
    chargeAccountRequest.txRef = transactionRef;
    chargeAccountRequest.phoneNumber = Preferences.phoneNumber;
    chargeAccountRequest.email = Preferences.email;
    chargeAccountRequest.passCode = passcode;
    chargeAccountRequest.amount = widget.amount;
    chargeAccountRequest.accountnumber = accountNumber;
    chargeAccountRequest.paymentType = "account";
    chargeAccountRequest.bvn = bvn;
    chargeAccountRequest.country = "NG";

    Encryption _encryption =
        new Encryption(secretKey: UrlConstants.LIVE_SECRET_KEY);
    String client = _encryption.encrypt(chargeAccountRequest.toMap());
    print("Encrypted info is --> $client");
//
    InitiatePaymentRequest request = new InitiatePaymentRequest(
        pbfPubKey: UrlConstants.LIVE_PUBLIC_KEY,
        client: client,
        alg: "3DES-24");

    NetworkService networkService = new NetworkService();
    networkService.initiateAccountCharge(request).then((response) async {
      if (response?.data != null) {
        if (response.status == "success" &&
            response?.data?.chargeResponseCode == "02") {
          _removeDialog();
          print("success message -->${response?.data?.chargeResponseMessage}");
//          Utils.showSnackBar(
//              response?.data?.chargeResponseMessage, _scaffoldKey);

//          if (response?.data.authurl != "NO-URL") {
//            const url = 'https://flutter.io';
//            if (await canLaunch(url)) {
//              await launch(url);
//            } else {
//              throw 'Could not launch $url';
//            }
//          }
//          else {
          _navigateToValidateOtpPage(response?.data?.flwRef);
//          }
        } else {
          _removeDialog();
          print("message -->${response.message}");
          Utils.showErrorDialog(context, "Error", "${response.message}");
        }
      } else {
        _removeDialog();
        print("message -->${response.message}");
        Utils.showErrorDialog(context, "Error", "${response.message}");
      }
    }).catchError((e) {
      _removeDialog();
      Utils.showErrorDialog(context, "Error", "An error occured, try again");
    });
  }

  void _navigateToValidateOtpPage(String transactionRef) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return InitiateChargeOtp(
        txRef: transactionRef,
        accountNumber: widget.accountNumber,
        amount: widget.amount,
        transferAmount: widget.transferAmount,
        remarks: widget.remarks,
        bankCode: widget.bankCode,
        currency: countrySymbol[widget.currency],
        beneficiaryName: widget.beneficiaryName,
      );
    }));
  }

  Widget _buildAccountItem(DocumentSnapshot snapShot) {
    return Container(
      margin: EdgeInsets.only(top: 21, left: 19, right: 19),
      child: Card(
        elevation: 8,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.accountBorderColor, width: 0.5),
            borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 19, vertical: screenAwareSize(14, context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(
                    Icons.account_balance,
                    color: AppColors.buttonColor,
                  ),
                  Text(snapShot['Bankname'], style: TextStyle(fontSize: 10)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'ACCOUNT NAME',
                          style: TextStyle(
                              color: AppColors.transferHistoryItemTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 9),
                        ),
                        Text(snapShot['AccountName'],
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'MontserratSemiBold',
                            ))
                      ],
                    ),
                  ),
//                  SizedBox(width: 20),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'ACCOUNT NUMBER',
                        style: TextStyle(
                            color: AppColors.transferHistoryItemTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 9),
                      ),
                      Text(snapShot['AccountNumber'],
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'MontserratSemiBold',
                          ))
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _removeDialog() {
    Navigator.of(_dialogContext).pop();
  }

  void _showDialog(String message) {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _dialogContext = context;
        return WillPopScope(
          onWillPop: () {},
          child: Dialog(
              insetAnimationCurve: Curves.easeInOut,
              insetAnimationDuration: Duration(milliseconds: 100),
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: SizedBox(
                  height: 100.0,
                  child: Row(children: <Widget>[
                    const SizedBox(width: 15.0),
                    SizedBox(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.buttonColor),
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    Expanded(
                        child: Text(message,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w700)))
                  ]))),
        );
      },
    );
  }
}
