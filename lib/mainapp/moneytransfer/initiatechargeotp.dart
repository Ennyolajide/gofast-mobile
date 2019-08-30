import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/config/urlconstants.dart';
import 'package:gofast/mainapp/maindashboard.dart';
import 'package:gofast/network/apiservice.dart';
import 'package:gofast/network/request/initiatetransferrequest.dart';
import 'package:gofast/network/request/validatechargerequest.dart';
import 'package:gofast/network/request/verifyaccchargerequest.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class InitiateChargeOtp extends StatefulWidget {
  String txRef;
  String accountNumber;
  String amount;
  String transferAmount;
  String remarks;
  String bankCode;
  String currency;
  String beneficiaryName;

  InitiateChargeOtp(
      {this.txRef,
      this.accountNumber,
      this.amount,
      this.transferAmount,
      this.remarks,
      this.bankCode,
      this.currency,
      this.beneficiaryName});

  @override
  _InitiateChargeOtpState createState() => _InitiateChargeOtpState();
}

class _InitiateChargeOtpState extends State<InitiateChargeOtp> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  TextEditingController _otpController = new TextEditingController();
  bool _autoValidate = false;
  bool _isShowing = false;
  BuildContext _dialogContext;
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  FirebaseUser _currentUser;

  @override
  void initState() {
    _getCurrentUser();
    super.initState();
  }

  void _getCurrentUser() {
    _mAuth.currentUser().then((user) {
      if (user != null) {
        setState(() {
          _currentUser = user;
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
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildHeader(),
              SizedBox(height: screenAwareSize(130, context)),
              _buildPhoneNumberTextContainer(),
              SizedBox(
                height: screenAwareSize(25, context),
              ),
              _buildOtpTextField(),
              SizedBox(
                height: screenAwareSize(49, context),
              ),
              _buildContinueButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 27, top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          BackButton(color: AppColors.buttonColor),
          Image.asset('assets/gofast_gold.png', width: 122, height: 24),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberTextContainer() {
    return Container(
        margin: EdgeInsets.only(
            top: screenAwareSize(20, context), left: 19, right: 19, bottom: 10),
        child: Text('Enter OTP(one time password) sent to your mobile number',
            style: TextStyle(
                color: AppColors.onboardingPlaceholderText,
                fontSize: 22,
                fontFamily: 'MontserratSemiBold',
                fontWeight: FontWeight.bold)));
  }

  Widget _buildOtpTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: TextFormField(
        controller: _otpController,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          letterSpacing: 20.0,
        ),
        maxLines: null,
        maxLength: 10,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.only(bottom: 12, left: 12),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
            ),
            counterText: ''),
        validator: (val) {
          if (val.isEmpty) {
            return 'Field is required';
          } else if (val.length < 3) {
            return 'Value must be at 3 least digits';
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      margin: EdgeInsets.only(
          left: 19, right: 19, top: screenAwareSize(50, context)),
      child: RaisedButton(
        color: AppColors.buttonColor,
        onPressed: () {
          _performVerification();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.25,
          ),
        ),
      ),
    );
  }

  void _performVerification() {
    setState(() {
      _autoValidate = true;
    });
    final form = _formKey.currentState;
    if (form.validate()) {
      _showDialog("Validating payment..");
      if (_currentUser != null) {
        _firestore
            .collection("Users")
            .document(_currentUser.uid)
            .get()
            .then((snapShot) {
          String onlineUserId = snapShot.data['deviceId'];
          if (onlineUserId == Preferences.deviceId) {
            validatePayment();
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
  }

  void validatePayment() {
    ValidateChargeRequest request = new ValidateChargeRequest();
    request.PBFPubKey = UrlConstants.LIVE_PUBLIC_KEY;
    request.otp = _otpController.text.trim();
    request.transactionreference = widget.txRef;

    NetworkService networkService = new NetworkService();
    networkService.validateAccountCharge(request).then((response) {
      if (response?.data != null) {
        if (response.status == "success" &&
            response?.data?.acctvalrespcode == "00") {
          _otpController.clear();
          setState(() {
            _autoValidate = false;
          });
          _verifyTransaction(response?.data?.txRef);
        } else {
          _removeDialog();
          print(
              "message -->${response.message} and ${response?.data?.acctvalrespmsg}");
          Utils.showErrorDialog(
              context, "Error", "${response?.data?.acctvalrespmsg}");
        }
      } else {
        _removeDialog();
        print("message -->${response.message}");
        Utils.showErrorDialog(context, "Error", "An error occured, try again");
      }
    }).catchError((e) {
      _removeDialog();
      Utils.showErrorDialog(context, "Error", "An error occured, try again");
    });
  }

  void _verifyTransaction(String txRef) {
    VerifyAccountChargeRequest request = new VerifyAccountChargeRequest();
    request.secretKey = UrlConstants.LIVE_SECRET_KEY;
    request.txref = txRef;

    NetworkService networkService = new NetworkService();
    networkService.verifyAccountCharge(request).then((response) {
      if (response?.data != null) {
        if (response.status == "success" &&
            response?.data?.status == "successful") {
          if (widget.currency == "GHS") {
            _initiateGhanaTransfer();
          } else {
            _initiateTransfer();
          }
        } else {
          _removeDialog();
          print("message -->${response.message}");
          Utils.showErrorDialog(context, "Error", "${response.message}");
        }
      } else {
        _removeDialog();
        print("message -->${response.message}");
        Utils.showErrorDialog(context, "Error", "An error occured, try again");
      }
    }).catchError((e) {
      _removeDialog();
      Utils.showErrorDialog(context, "Error", "An error occured, try again");
    });
  }

  void _initiateGhanaTransfer() {}

  void _initiateTransfer() {
    InitiateTransferRequest request = new InitiateTransferRequest();

    request.account_bank = widget.bankCode;
    request.account_number = widget.accountNumber;
    // request.amount = double.parse(widget.transferAmount).truncate();
    request.narration = widget.remarks;
    request.seckey = UrlConstants.LIVE_SECRET_KEY;
    request.reference = widget.txRef;
    request.currency = widget.currency;
    request.beneficiary_name = widget.beneficiaryName;

    NetworkService networkService = new NetworkService();
    networkService.initiateTransfer(request).then((response) {
      if (response?.data != null) {
        if (response.status == "success" && response?.data?.status == "NEW") {
          _addTransferToFirebase(
              response?.data?.reference,
              response?.data?.dateCreated,
              response?.data?.narration,
              response?.data?.bankName,
              response?.data?.currency);
        } else {
          _removeDialog();
          print("message -->${response.message}");
          Utils.showErrorDialog(context, "Error", "${response.message}");
        }
      } else {
        _removeDialog();
        print("message -->${response.message}");
        Utils.showErrorDialog(context, "Error", "An error occured, try again");
      }
    });
  }

  void _showConfirmDialog(String title, String message) {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          return new AlertDialog(
            title: new Text(
              title ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(message ?? '',
                      style: TextStyle(fontSize: 15, fontFamily: 'Montserrat')),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text(
                  'OK',
                  style: TextStyle(
                      color: AppColors.buttonColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _moveToHome();
                },
              )
            ],
          );
        } else {
          return new CupertinoAlertDialog(
            title: Text(
              title ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(message ?? '',
                      style: TextStyle(fontSize: 15, fontFamily: 'Montserrat'))
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text(
                  'OK',
                  style: TextStyle(
                      color: AppColors.buttonColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _moveToHome();
                },
              )
            ],
          );
        }
      },
    );
  }

  void _moveToHome() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainDashboard()),
        (Route<dynamic> route) => false);
  }

  void _addTransferToFirebase(String ref, String dateCreated, String remarks,
      String bankname, String currency) {
    Map<String, dynamic> map = new Map();
    map['accountNumber'] = widget.accountNumber;
    map['accountName'] = widget.beneficiaryName;
    map['bankName'] = bankname;
    map['time'] = dateCreated;
    map['amount'] = double.parse(widget.transferAmount).truncate().toString();
    map['transactionRef'] = widget.txRef;
    map['transferRef'] = ref;
    map['remarks'] = widget.remarks;
    map['narration'] = remarks;
    map['currency'] = currency;

    _firestore
        .collection("Users")
        .document(_currentUser.uid)
        .collection("Transfers")
        .add(map)
        .then((snapShot) {
      _removeDialog();
      _showConfirmDialog(
        "Transfer successful",
        "Amount was transferred successfully",
      );
      print("Transfer added successfully");
    });
  }

//  void _fetchTransfer() {
//    NetworkService networkService = new NetworkService();
//    networkService.fetchTransfer(UrlConstants.LIVE_SECRET_KEY).then((response) {
//      if (response?.data != null) {
//        if (response.status == "success") {
//          _addTransferToFirebase();
//          _removeDialog();
//          response.data.transfers.forEach((transfer) {
//            print(
//                "transfer to ${transfer.accountNumber} -->amount: ${transfer.amount} --> status: ${transfer.status}");
//            Utils.showErrorDialog(
//                context, "Success", "Amount transferred successfully");
//          });
//        } else {
//          _removeDialog();
//          print("message -->${response.message}");
//          Utils.showErrorDialog(context, "Error", "${response.message}");
//        }
//      } else {
//        _removeDialog();
//        print("message -->${response.message}");
//        Utils.showErrorDialog(context, "Error", "An error occured, try again");
//      }
//    });
//  }

  void _removeDialog() {
    Navigator.of(_dialogContext).pop();
    setState(() {
      _isShowing = false;
    });
  }

  void _showDialog(String message) {
    setState(() {
      _isShowing = true;
    });
    showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _dialogContext = context;
        return WillPopScope(
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
            onWillPop: () {});
      },
    );
  }
}
