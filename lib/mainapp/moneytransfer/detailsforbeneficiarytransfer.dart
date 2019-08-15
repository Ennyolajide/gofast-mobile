import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/mainapp/moneytransfer/verifytransactionpin.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class DetailsForbeneficiaryTransfer extends StatefulWidget {
  String accountname;
  String accountnumber;
  String bankcode;
  String bankname;
  String currency;

  DetailsForbeneficiaryTransfer(
      {this.accountname,
      this.accountnumber,
      this.bankcode,
      this.bankname,
      this.currency});

  @override
  _DetailsForbeneficiaryTransferState createState() =>
      _DetailsForbeneficiaryTransferState();
}

class _DetailsForbeneficiaryTransferState
    extends State<DetailsForbeneficiaryTransfer> {
  TextEditingController _bvnController = new TextEditingController();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  BuildContext _dialogContext;
  double _charge = 0.0;

  _DetailsForbeneficiaryTransferState() {
    _amountController.addListener(() {
      String amountText =
          _amountController.text.trim().replaceAll(",", "").replaceAll("-", "");
      print("amount $amountText");
      if (_amountController.text.isNotEmpty &&
          double.parse(amountText) >= 100) {
        double chargingFee = (1.43 / 100) * ((double.parse(amountText) + 55));
        setState(() {
          _charge = chargingFee + 55;
        });
      } else {
        setState(() {
          _charge = 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    _bvnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: AppColors.buttonColor,
          title: Text('Transfer details',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                _buildBvnContainer(),
                _buildServiceFeeCharge(),
                _buildAmountEntry(),
                _buildTransferReasonEntry(),
                _buildNextButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBvnContainer() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(30, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Enter your BVN(Bank Verification Number), your bvn is not saved anywhere',
            style: TextStyle(
                color: AppColors.onboardingPlaceholderText,
                fontSize: 17,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: screenAwareSize(10, context)),
          TextFormField(
            controller: _bvnController,
            style: TextStyle(fontSize: 16),
            maxLines: null,
            maxLength: 11,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.only(bottom: 12, left: 12),
                hintText: 'Bvn',
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.buttonColor, width: 1.0),
                ),
                hintStyle: TextStyle(
                    color: AppColors.onboardingTextFieldHintTextColor),
                counterText: ''),
            validator: (val) {
              if (val.isEmpty) {
                return 'Field is required';
              } else if (val.length < 11) {
                return 'Value must be 11 digits';
              }
            },
            autovalidate: _autoValidate,
          )
        ],
      ),
    );
  }

  Widget _buildServiceFeeCharge() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 15),
      child: Text('Service fee: ${_charge.toStringAsFixed(2)}',
          style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 17,
              fontFamily: 'MontserratSemiBold')),
    );
  }

  Widget _buildAmountEntry() {
    return Container(
      margin: EdgeInsets.only(
        top: screenAwareSize(15, context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('How much do you want to send,',
              style: TextStyle(
                  color: AppColors.onboardingPlaceholderText,
                  fontSize: 17,
                  fontFamily: 'MontserratSemiBold')),
          SizedBox(height: screenAwareSize(5, context)),
          TextFormField(
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 16),
            maxLines: null,
            controller: _amountController,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.buttonColor, width: 1.0),
              ),
              contentPadding: EdgeInsets.only(bottom: 12, left: 12),
              labelText: 'Amount',
              hasFloatingPlaceholder: false,
              labelStyle: TextStyle(
                  color: AppColors.onboardingTextFieldHintTextColor,
                  fontSize: 14),
            ),
            validator: (val) {
              if (val.isEmpty) {
                return 'Field is required';
              } else if (double.parse(
                      val.trim().replaceAll(",", "").replaceAll("-", "")) <
                  100.0) {
                return 'Amount must be at least 100 naira';
              }
            },
            autovalidate: _autoValidate,
          )
        ],
      ),
    );
  }

  Widget _buildTransferReasonEntry() {
    return Container(
      margin: EdgeInsets.only(
        top: screenAwareSize(30, context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('What is this transfer for',
              style: TextStyle(
                  color: AppColors.onboardingPlaceholderText,
                  fontSize: 17,
                  fontFamily: 'MontserratSemiBold')),
          SizedBox(height: screenAwareSize(5, context)),
          TextField(
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 16),
            maxLines: null,
            controller: _remarksController,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.buttonColor, width: 1.0),
              ),
              contentPadding: EdgeInsets.only(bottom: 12, left: 12),
              labelText: 'Payment remarks',
              hasFloatingPlaceholder: false,
              labelStyle: TextStyle(
                  color: AppColors.onboardingTextFieldHintTextColor,
                  fontSize: 14),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(30, context), bottom: 10),
      child: RaisedButton(
        onPressed: () {
          setState(() {
            _autoValidate = true;
          });
          final form = _formKey.currentState;
          if (form.validate()) {
            _performAccountVerification();
          }
        },
        color: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Next',
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

  void _performAccountVerification() {
    _mAuth.currentUser().then((currentUser) {
      _firestore
          .collection("Users")
          .document(currentUser.uid)
          .get()
          .then((snapShot) {
        String onlineUserId = snapShot.data['deviceId'];
        if (onlineUserId == Preferences.deviceId) {
          String amountText = _amountController.text
              .trim()
              .replaceAll(",", "")
              .replaceAll("-", "");

          double amountEntered = double.parse(amountText);

          double finalAmountCharge = _charge + amountEntered;

          Navigator.of(context, rootNavigator: false).push(
            CupertinoPageRoute<bool>(
              builder: (BuildContext context) => TransactionPinVerification(
                    accountNumber: widget.accountnumber,
                    amount: "$finalAmountCharge",
                    transferAmount: amountEntered.toString(),
                    remarks: _remarksController.text,
                    bankCode: widget.bankcode,
                    bvn: _bvnController.text,
                    currency: widget.currency,
                    beneficiaryName: widget.accountname,
                  ),
            ),
          );
        } else {
          _removeDialog();
          Utils.showErrorDialog(context, "Authentication failed!",
              "You have been signed out of this device.");
        }
      });
    });
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
