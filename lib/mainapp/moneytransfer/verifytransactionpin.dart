import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/config/urlconstants.dart';
import 'package:gofast/mainapp/moneytransfer/select_account.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/encryption.dart';
import 'package:gofast/utils/utils.dart';

class TransactionPinVerification extends StatefulWidget {
  String accountNumber;
  String amount;
  String transferAmount;
  String remarks;
  String bvn;
  String bankCode;
  String currency;
  String beneficiaryName;

  TransactionPinVerification(
      {this.accountNumber,
      this.amount,
      this.transferAmount,
      this.remarks,
      this.bvn,
      this.bankCode,
      this.currency,
      this.beneficiaryName});

  @override
  _TransactionPinVerificationState createState() =>
      _TransactionPinVerificationState();
}

class _TransactionPinVerificationState
    extends State<TransactionPinVerification> {
  bool _autoValidate = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _pinController = new TextEditingController();
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  FirebaseUser _currentUser;
  Firestore _firestore = Firestore.instance;
  BuildContext _dialogContext;

  @override
  void initState() {
    _getCurrentuser();
    super.initState();
  }

  void _getCurrentuser() {
    _mAuth.currentUser().then((user) {
      if (user != null) {
        _currentUser = user;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                'assets/lock.png',
                width: 271,
                fit: BoxFit.contain,
                height: screenAwareSize(271, context),
              ),
            ),
            Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.transparent,
              body: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 5, right: 27, top: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          BackButton(color: AppColors.buttonColor),
                          Image.asset('assets/gofast_gold.png',
                              width: 122, height: 24),
                        ],
                      ),
                    ),
                    SizedBox(height: screenAwareSize(130, context)),
                    _buildPinTextContainer(),
                    _buildPinTextField(),
                    _buildNextButton()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinTextContainer() {
    return Container(
      margin: EdgeInsets.only(left: 19, right: 19),
      child: Text('Enter your transaction pin',
          style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 19,
              fontFamily: 'MontserratBold',
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPinTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19, vertical: 20),
      child: TextFormField(
        controller: _pinController,
        keyboardType: TextInputType.number,
        obscureText: true,
        style: TextStyle(fontSize: 16),
        maxLines: null,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outline,
            color: AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
          ),
          contentPadding: EdgeInsets.only(bottom: 12, left: 12),
          labelText: 'Pin',
          hasFloatingPlaceholder: false,
          labelStyle:
              TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
        ),
        validator: (val) {
          if (val.isEmpty) {
            return 'Pin is required';
          } else if (val.length < 5) {
            return 'Pin must be at least 5 characters long';
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      margin: EdgeInsets.only(
          left: 19,
          right: 19,
          top: screenAwareSize(80, context),
          bottom: screenAwareSize(20, context)),
      child: RaisedButton(
        onPressed: _submit,
        color: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Verify',
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

  void _submit() {
    setState(() {
      _autoValidate = true;
    });
    final form = _formKey.currentState;

    if (form.validate()) {
      _showDialog("Verifying pin..");
      if (_currentUser != null) {
        _firestore
            .collection("Users")
            .document(_currentUser.uid)
            .get()
            .then((snapShot) {
          String onlineUserId = snapShot.data['deviceId'];
          if (onlineUserId == Preferences.deviceId) {
            Encryption encryption =
                new Encryption(secretKey: UrlConstants.LIVE_SECRET_KEY);
            _firestore
                .collection("Users")
                .document(_currentUser.uid)
                .get()
                .then((snapShot) {
              if (_pinController.text.trim() ==
                  encryption
                      .decryptTransactionPin(snapShot.data['transactionPin'])) {
                _removeDialog();
                _pinController.clear();
                setState(() {
                  _autoValidate = false;
                });
                _moveSelectAccount();
              } else {
                _removeDialog();
                Utils.showErrorDialog(context, "Pin verification failed",
                    "Transaction pin is invalid!");
              }
            });
          } else {
            _removeDialog();
            Utils.showErrorDialog(context, "Authentication failed!",
                "You have been signed out of this device.");
          }
        });
      } else {
        _removeDialog();
        Utils.showErrorDialog(context, "Authentication failed!",
            "You have been signed out of this device.");
      }
    }
  }

  void _moveSelectAccount() {
    Navigator.of(context, rootNavigator: false).push(
      CupertinoPageRoute<bool>(
        builder: (BuildContext context) => SelectAccount(
              accountNumber: widget.accountNumber,
              amount: widget.amount,
              transferAmount: widget.transferAmount,
              bankCode: widget.bankCode,
              bvn: widget.bvn,
              remarks: widget.remarks,
              currency: widget.currency,
              beneficiaryName: widget.beneficiaryName,
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
