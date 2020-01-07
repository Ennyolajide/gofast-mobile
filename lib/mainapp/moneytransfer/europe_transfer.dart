import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/config/urlconstants.dart';
import 'package:gofast/mainapp/components/form_components.dart';
import 'package:gofast/mainapp/moneytransfer/verifytransactionpin.dart';
import 'package:gofast/network/apiservice.dart';
import 'package:gofast/network/response/gettransferbanksresponse.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

Map<String, dynamic> countrySymbol = {
  "Europe": "EUR"
};

Map<String, dynamic> currencies = {
  "Europe": "EUR"
};

Map<String, String> europeCountries = {
  'Germany' : 'DE',
  'United Kindom' : 'GB' ,
  'Italy' : 'IT',
  'France' : 'FR',
};

class TransferEurope extends StatefulWidget {
  @override
  _TransferEuropeState createState() => _TransferEuropeState();
}

class _TransferEuropeState extends State<TransferEurope> {
  bool _autoValidate = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();

  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _swiftCodeController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _beneficiaryPostalCodeController = TextEditingController();
  final _beneficiaryStreetNumberController = TextEditingController();
  final _beneficiaryStreetNameController = TextEditingController();
  final _beneficiaryCityController = TextEditingController();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();
  final _beneficiaryAddressController = TextEditingController();
  final _beneficiaryNameController = TextEditingController();


  String _selectedCountry = "Europe";
  bool _showIndicator = true;
  BuildContext _dialogContext;
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  FirebaseUser fbUser;
  String _bankCode;
  double _charge = 0.0;
  double _percentageCharge = 0.0;
  double _countryTranxCharge = 0.0;
  String _selectedEuropeanCountry = 'United Kindom';
  Map<String, dynamic> _charges;

  _TransferEuropeState() {
    _amountController.addListener(() {
      String amountText =
          _amountController.text.trim().replaceAll(",", "").replaceAll("-", "");

      if (_amountController.text.isNotEmpty && double.parse(amountText) >= 200) {
        setState(() {
          _charge =  _countryTranxCharge + (_percentageCharge/100 * double.parse(amountText));
        });
      } else {
        setState(() {
          _charge = 0.0;
        });
      }
    });
  }

  @override
  void initState() {
    _initPreferences();
    _getFirebaseUser();
    _loadCharges();
    _getTranxCharge(_selectedCountry);
    super.initState();
  }

  void _initPreferences() {
    Preferences.init().then((prefs) {});
  }

  void _getFirebaseUser() {
    _mAuth.currentUser().then((user) {
      setState(() {
        fbUser = user;
      });
    });
  }

  void _loadCharges() async {
    print("Loading Charges");

    _charges = {
      "Europe": {
        "charge" : 5, "currency" : "EUR", "percentageCharge" : 2,
      }
    };

  }

  void _getTranxCharge(String countryName){
    Map<String, dynamic> tranxCharge = _charges[countryName];
    var _fee =  tranxCharge['charge'];
    var _percentCharge = tranxCharge['percentageCharge'];
    setState(() {
      _countryTranxCharge = _fee.toDouble();
      _percentageCharge = _percentCharge.toDouble();
    });
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          return new AlertDialog(
              title: new Text(title ?? ''),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(message ?? ''),
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('Retry',
                      style: TextStyle(
                          color: AppColors.buttonColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    print("recalled");
                    setState(() {
                      _showIndicator = true;
                    });
                    //_getBanks("United States");
                  },
                ),
              ]);
        } else {
          return new CupertinoAlertDialog(
              title: Text(title ?? ''),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    Text(message ?? '')
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    'Retry',
                    style: TextStyle(
                        color: AppColors.buttonColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    print("recalled");
                    setState(() {
                      _showIndicator = true;
                    });
                    //_getBanks("United States");
                  },
                ),
              ]);
        }
      },
    );
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: AppColors.buttonColor,
        title: Text('Transfer EURO',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700
            ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 18),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  //SizedBox(height: 5.0),
                  _buildBeneficiaryCountry(),
                  textField( hintText: "Enter Account Number | IBAN", label: "Account Number", controller: _accountNumberController),
                  textField(hintText: "Enter Routing Number", label: "Routing Number", controller: _routingNumberController),
                  textField(hintText: "Enter Swift Code", label: "Swift Code", controller: _swiftCodeController),
                  textField(hintText: "Enter Bank Name", label: "Bank Name", controller: _bankNameController),
                  textField( hintText: "Enter Account Name", label: "Account Name", controller: _beneficiaryNameController),
                  textField( hintText: "Enter Recipient Postal Code", label: "Recipient Postal Code", controller: _beneficiaryPostalCodeController),
                  textField( hintText: "Enter Recipient Street Number", label: "Recipient Street Number", controller: _beneficiaryStreetNumberController),
                  textField( hintText: "Enter Recipient Street Name", label: "Recipient Street Name", controller: _beneficiaryStreetNameController),
                  textField( hintText: "Enter Recipient City", label: "Recipient City", controller: _beneficiaryCityController),
                  _buildServiceFeeCharge(),
                  _buildAmountEntry(),
                  _buildTransferReasonEntry(),
                  //_buildServiceFeeCharge(),
                  _buildNextButton()
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }

  Widget _buildServiceFeeCharge() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 15),
      child: Text('Service fee: ${_charge.toStringAsFixed(2)}',
          style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 17,
              fontFamily: 'MontserratSemiBold'
          ),
      ),
    );
  }

  Widget _buildBeneficiaryCountry(){
      return Container(
        margin: EdgeInsets.only(top: screenAwareSize(30, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Select destination country',
              style: TextStyle(
                  color: AppColors.onboardingPlaceholderText,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: screenAwareSize(15, context)),
            Container(
              child: DropdownButton(
                isExpanded: true,
                hint: Text('select bank'), // Not necessary for Option 1
                value: _selectedEuropeanCountry,
                onChanged: (newValue) {
                  setState(() {
                    _selectedEuropeanCountry = newValue;
                  });
                },
                items: europeCountries.keys.map((country) {
                  return DropdownMenuItem(
                    child: new Text(country),
                    value: country,
                  );
                }).toList(),
              ),
            )
          ],
        ),
      );
  }

   Widget _buildAccountNumberContainer() {
    return Container(
      margin: EdgeInsets.only(
        top: screenAwareSize(24, context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Enter Account number',
              style: TextStyle(
                  color: AppColors.onboardingPlaceholderText,
                  fontSize: 17,
                  fontFamily: 'MontserratSemiBold'
              ),
          ),
          SizedBox(height: screenAwareSize(5, context)),
          TextFormField(
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 16),
            maxLines: null,
            maxLength: 10,
            controller: _accountNumberController,
            decoration: InputDecoration(
              counterText: '',
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.buttonColor, width: 1.0),
              ),
              contentPadding: EdgeInsets.only(bottom: 12, left: 12),
              labelText: 'Account number',
              hasFloatingPlaceholder: false,
              labelStyle: TextStyle(
                  color: AppColors.onboardingTextFieldHintTextColor,
                  fontSize: 14),
            ),
            validator: (val) {
              if (val.isEmpty) {
                return 'Field is required';
              } else if (val.length < 10) {
                return 'Value must be 10 digits';
              }else{
                return null;
              }
            },
            autovalidate: _autoValidate,
          )
        ],
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
                fontWeight: FontWeight.w600
            ),
          ),
          SizedBox(height: screenAwareSize(10, context)),
          TextFormField(
            // controller: _bvnController,
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
              }else{
                return null;
              }
            },
            autovalidate: _autoValidate,
          )
        ],
      ),
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
                  fontFamily: 'MontserratSemiBold'
              ),
          ),
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
                  fontSize: 14
              ),
            ),
            validator: (val) {
              if (val.isEmpty) {
                return 'Field is required';
              } else if (double.parse(
                      val.trim().replaceAll(",", "").replaceAll("-", "")) <
                  200.0) {
                return 'Amount must be at least EUR 200';
              } else if(double.parse(
                      val.trim().replaceAll(",", "").replaceAll("-", "")) >
                  5000.0) {
                return 'Amount cannot be more than EUR 5,000';
              }
              return null;
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
                  fontFamily: 'MontserratSemiBold'
              ),
          ),
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
                  fontSize: 14
              ),
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
            //_performAccountVerification();
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
    _showDialog("Verifying Account");

    if (fbUser != null) {
      _firestore
          .collection("Users")
          .document(fbUser.uid)
          .get()
          .then((snapShot) {
        String onlineUserId = snapShot.data['deviceId'];
        if (onlineUserId == Preferences.deviceId) {
          _verifyAccount();
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

  void _verifyAccount() {
    print("selected bank code is ---> $_bankCode");
    NetworkService service = NetworkService();
    _removeDialog();

    String amountText =
        _amountController.text.trim().replaceAll(",", "").replaceAll("-", "");

    double amountEntered = double.parse(amountText);

    double finalAmountCharge = _charge + amountEntered;
    Map<String, dynamic> meta = new Map();

    meta["AccountNumber"] = _accountNumberController.text.trim();
    meta["RoutingNumber"] = _routingNumberController.text.trim();
    meta["SwiftCode"] = _swiftCodeController.text.trim();
    meta["BankName"] = _bankNameController.text.trim();
    meta["BeneficiaryName"] = _beneficiaryNameController.text.trim();
    meta["BeneficiaryAddress"] = _beneficiaryAddressController.text.trim();
    meta["BeneficiaryCountry"] = _selectedEuropeanCountry;

    print("final amount charge is ->> $finalAmountCharge");
    print("final final amount to transfer --> $amountEntered");

    Navigator.of(context, rootNavigator: false).push(
      CupertinoPageRoute<bool>(
        builder: (BuildContext context) => TransactionPinVerification(
          accountNumber: _accountNumberController.text,
          amount: "$finalAmountCharge",
          transferAmount: amountEntered.toString(),
          remarks: _remarksController.text,
          bankCode: _bankCode,
          // bvn: _bvnController.text,
          meta: meta,
          currency: currencies[_selectedCountry],
          beneficiaryName: _beneficiaryNameController.text,
        ),
      ),
    );
//        _accountNumberController.clear();
//        _amountController.clear();
//        _remarksController.clear();
    setState(() {
      _autoValidate = false;
    });
    print("Account verified successfully");
    //   } else {
    //     _removeDialog();
    //     Utils.showErrorDialog(
    //       context,
    //       "Error!",
    //       response.responseMessage,
    //     );
    //   }
    // }).catchError((e) {
    //   //if it crashes
    //   _removeDialog();
    //   Utils.showErrorDialog(context, "Error", "An error occured, try again");
    // });
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
                  borderRadius: BorderRadius.all(Radius.circular(10.0),
                  ),
              ),
              child: SizedBox(
                  height: 100.0,
                  child: Row(children: <Widget>[
                    const SizedBox(width: 15.0),
                    SizedBox(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.buttonColor
                        ),
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    Expanded(
                        child: Text(message,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w700
                            ),
                        ),
                    )
                  ]),
              ),
          ),
        );
      },
    );
  }
}
