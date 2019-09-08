import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/config/urlconstants.dart';
import 'package:gofast/network/apiservice.dart';
import 'package:gofast/network/request/addaccountrequest.dart';
import 'package:gofast/network/response/gettransferbanksresponse.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

Map<String, dynamic> countrySymbol = {
  "Nigeria": "NG",
  "Ghana": "GH",
  "Kenya": "KE",
  "Uganda": "UG",
  "Tanzania": "TZ",
};

Map<String, dynamic> currencies = {
  "Nigeria": "NGN",
  "Ghana": "GHS",
  "Kenya": "KES",
  "Uganda": "UGX",
  "Tanzania": "TZS",
};

class AddBeneficiaries extends StatefulWidget {
  @override
  _AddBeneficiariesState createState() => _AddBeneficiariesState();
}

class _AddBeneficiariesState extends State<AddBeneficiaries> {
  var _selectedBank;
  bool _autoValidate = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  FirebaseUser fbUser;
  List<Bank> _banks; //for bank code
  String _bankCode;
  String _selectedCountry = "Nigeria";
  bool _bankRetrieved = false;
  bool _showIndicator = true;
  List<Bank> _bankList;
  BuildContext _dialogContext;

  @override
  void initState() {
    _getBanks("Nigeria");
    _initPreferences();
    _getFirebaseUser();
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

  void _getBanks(String bankName) {
    NetworkService _networkService = new NetworkService();

    _networkService
        .getTransferBanks(countrySymbol[bankName], UrlConstants.LIVE_PUBLIC_KEY)
        .then((response) {
      if (response.status == "success") {
        setState(() {
          _showIndicator = false;
          _bankRetrieved = true;
        });

        _bankList = response.banks;
        _selectedBank = _bankList.elementAt(0).name;
        setState(() {
          _bankCode = _bankList.elementAt(0).code;
        });
      } else {
        setState(() {
          _showIndicator = false;
        });
        _showErrorDialog(
          context,
          "Banks Retrieval failed!",
          response.message,
        );
      }
    }).catchError((e) {
      print("error occurred while getting banks");
      setState(() {
        _showIndicator = false;
      });
      _showErrorDialog(context, "Error",
          "An error occured while retrieving banks, try Again");
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
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    print("recalled");
                    setState(() {
                      _showIndicator = true;
                    });
                    _getBanks("Nigeria");
                  },
                ),
              ]);
        } else {
          return new CupertinoAlertDialog(
              title: Text(title ?? ''),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[new Text(message ?? '')],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    'Retry',
                    style: TextStyle(
                        color: AppColors.buttonColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    print("recalled");
                    setState(() {
                      _showIndicator = true;
                    });
                    _getBanks("Nigeria");
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: AppColors.buttonColor,
          title: Text('Add beneficiary',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ),
        body: Stack(
          children: <Widget>[
            _showIndicator
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.buttonColor),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Retrieving banks',
                          style: TextStyle(
                              color: AppColors.buttonColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )
                : SizedBox(),
            _bankRetrieved
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 18),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: <Widget>[
                          _buildAccountNumberContainer(),
                          _selectCountrySection(),
                          _buildBankSelection(),
                          _buildNextButton()
                        ],
                      ),
                    ),
                  )
                : SizedBox()
          ],
        ),
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
          Text('Enter beneficiary account number',
              style: TextStyle(
                  color: AppColors.onboardingPlaceholderText,
                  fontSize: 17,
                  fontFamily: 'MontserratSemiBold')),
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
              }
            },
            autovalidate: _autoValidate,
          )
        ],
      ),
    );
  }

  Widget _selectCountrySection() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(30, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Select country',
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
              value: _selectedCountry,
              onChanged: (newValue) {
                setState(() {
                  _selectedCountry = newValue;
                  _showIndicator = true;
                  _bankRetrieved = false;
                  _getBanks(_selectedCountry);
                });
              },
              items: countrySymbol.keys.map((country) {
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

  Widget _buildBankSelection() {
    return Container(
        margin: EdgeInsets.only(top: screenAwareSize(30, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Select bank name',
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
                value: _selectedBank,
                onChanged: (newValue) {
                  setState(() {
                    _selectedBank = newValue;
                    _banks = _bankList
                        .where((bank) => bank.name == _selectedBank)
                        .toList();
                    _bankCode = _banks[0].code;
                  });
                },
                items: _bankList.map((bank) {
                  return DropdownMenuItem(
                    child: new Text(bank.name),
                    value: bank.name,
                  );
                }).toList(),
              ),
            )
          ],
        ));
  }

  Widget _buildNextButton() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(70, context), bottom: 10),
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
          'Add beneficiary',
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
        print(snapShot.data);
        print(Preferences.deviceId);
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
    NetworkService service = NetworkService();
    AddAccountRequest accountRequest =
        new AddAccountRequest(_accountNumberController.text.trim(), _bankCode);

    service.addAccount(accountRequest).then((response) {
      if (response.responseCode == "00" && response.status == "success") {
        _firestore
            .collection("Users")
            .document(fbUser.uid)
            .collection("Beneficiaries")
            .getDocuments()
            .then((data) {
          if (data.documents.length > 0) {
            _firestore
                .collection("Users")
                .document(fbUser.uid)
                .collection("Beneficiaries")
                .where('accountNumber',
                    isEqualTo: _accountNumberController.text)
                .getDocuments()
                .then((snapshot) {
              if (snapshot.documents.length > 0) {
                _removeDialog();
                Utils.showErrorDialog(
                    context, "Error", "Account already exist!.");
              } else {
                _addbeneficiary(response.account.accountName);
              }
            });
          } else {
            _addbeneficiary(response.account.accountName);
          }
        });

        setState(() {
          _autoValidate = false;
        });
        print("Account verified successfully");
      } else {
        _removeDialog();
        Utils.showErrorDialog(
          context,
          "Error!",
          response.responseMessage,
        );
      }
    }).catchError((e) {
      //if it crashes
      _removeDialog();
      Utils.showErrorDialog(context, "Error", "An error occured, try again");
    });
  }

  void _addbeneficiary(String accountName) {
    Map<String, dynamic> map = new Map();
    map['accountName'] = accountName;
    map['accountNumber'] = _accountNumberController.text;
    map['bankName'] = _selectedBank;
    map['currency'] = currencies[_selectedCountry];
    map['bankCode'] = _bankCode;

    _firestore
        .collection("Users")
        .document(fbUser.uid)
        .collection("Beneficiaries")
        .add(map)
        .then((data) {
      _removeDialog();
      _accountNumberController.clear();
      setState(() {
        _autoValidate = false;
      });
      Utils.showNormalMessage(context, "Beneficiary added",
          "Beneficiary has been added sucessfully.");
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
