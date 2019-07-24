import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/network/apiservice.dart';
import 'package:gofast/network/request/addaccountrequest.dart';
import 'package:gofast/network/response/addaccountresponse.dart';
import 'package:gofast/network/response/getchargebanksresponse.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class AddAccount extends StatefulWidget {
  bool fromOnboarding = false;

  AddAccount({this.fromOnboarding});

  @override
  _AddAccountState createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  BuildContext _dialogContext;
  bool _isShowing = false;
  Firestore _firestore = Firestore.instance;
  FirebaseUser fbUser;
  bool _bankRetrieved = false;
  bool _showIndicator = true;
  List<Bank> bankList = List();
  String _selectedBank;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _accountNumberController = new TextEditingController();
  bool _autoValidate = false;
  final _formKey = new GlobalKey<FormState>();
  String _bankCode;
  List<Bank> _banks; //to enable us get the bank code

  @override
  void initState() {
    _initPreferences();
    _retrieveBankList();
    _getFirebaseUser();
    super.initState();
  }

  void _getFirebaseUser() {
    _mAuth.currentUser().then((user) {
      setState(() {
        fbUser = user;
      });
    });
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  void _retrieveBankList() {
    NetworkService service = NetworkService();

    service.getChargedBanks().then((response) {
      //update build methods
      if (response.status == "success") {
        setState(() {
          _showIndicator = false;
          _bankRetrieved = true;
        });

        bankList = response.banks;
        _selectedBank = bankList.elementAt(0).bankname;
        setState(() {
          _bankCode = bankList.elementAt(0).bankcode;
        });
      } else {
        //show a dialog message with retry
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
      if (mounted) {
        setState(() {
          _showIndicator = false;
        });
      }
      _showErrorDialog(context, "Error", "An error occured try Again");
//      Utils.
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
                    _retrieveBankList();
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
                    _retrieveBankList();
                  },
                ),
              ]);
        }
      },
    );
  }

  void _initPreferences() {
    Preferences.init().then((prefs) {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: AppColors.buttonColor,
          title: Text('Add Bank',
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
                ? Form(
                    key: _formKey,
                    child: ListView(
                      children: <Widget>[
                        _buildAccountNumberContainer(),
                        _buildBankName(),
                        _buildNextButton()
                      ],
                    ))
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _buildAccountNumberContainer() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 44, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Enter account number',
            style: TextStyle(
                color: AppColors.onboardingPlaceholderText,
                fontSize: 17,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: screenAwareSize(10, context)),
          TextFormField(
            controller: _accountNumberController,
            style: TextStyle(fontSize: 16),
            maxLines: null,
            maxLength: 10,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.only(bottom: 12, left: 12),
                hintText: 'Account Number',
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

  Widget _buildBankName() {
    return Container(
      margin: EdgeInsets.only(
          left: 16,
          right: 16,
          top: screenAwareSize(30, context),
          bottom: screenAwareSize(30, context)),
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
          SizedBox(height: screenAwareSize(10, context)),
          Container(
            child: DropdownButton(
              isExpanded: true,
              hint: Text('select bank'), // Not necessary for Option 1
              value: _selectedBank,
              onChanged: (newValue) {
                setState(() {
                  _selectedBank = newValue.toString();
                  _banks = bankList
                      .where((bank) => bank.bankname == _selectedBank)
                      .toList();
                  _bankCode = _banks[0].bankcode;
                });
              },
              items: bankList.map((bank) {
                return DropdownMenuItem(
                  child: new Text(bank.bankname),
                  value: bank.bankname,
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      margin: EdgeInsets.only(
          left: 19, right: 19, top: screenAwareSize(90, context)),
      child: RaisedButton(
        onPressed: () {
          setState(() {
            _autoValidate = true;
          });
          final form = _formKey.currentState;

          if (form.validate()) {
            if (widget.fromOnboarding) {
              _verifyAccount();
            } else {
              _performVerificationFirst();
            }
          }
        },
        color: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Add Account',
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

  void _performVerificationFirst() {
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
      }).catchError((e) {
        _removeDialog();
        Utils.showErrorDialog(context, "Error", "An error occured");
      });
    } else {
      _removeDialog();
      Utils.showErrorDialog(context, "Authentication failed!",
          "You have been signed out of this device.");
    }
  }

  void _verifyAccount() {
    if (widget.fromOnboarding) {
      _showDialog("Verifying Account");
    }
    print("selected bank code is ---> ${_bankCode}");

    NetworkService service = NetworkService();
    AddAccountRequest accountRequest =
        new AddAccountRequest(_accountNumberController.text.trim(), _bankCode);

    service.addAccount(accountRequest).then((response) {
      if (response.responseCode == "00" && response.status == "success") {
        _firestore
            .collection("Users")
            .document(fbUser.uid)
            .collection("Accounts")
            .getDocuments()
            .then((data) {
          if (data.documents.length > 0) {
            print("here");
            _firestore
                .collection("Users")
                .document(fbUser.uid)
                .collection("Accounts")
                .where('AccountNumber',
                    isEqualTo: _accountNumberController.text)
                .getDocuments()
                .then((snapshot) {
              if (snapshot.documents.length > 0) {
                _removeDialog();
                Utils.showErrorDialog(
                    context, "Error", "Account already exist!.");
              } else {
                print("here again");
                _addAccountToFirestore(response);
              }
            });
          } else {
            _addAccountToFirestore(response);
          }
        });
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

  void _addAccountToFirestore(AddAccountResponse response) {
    Map<String, dynamic> data = new Map();
    data['AccountName'] = response.account.accountName;
    data['AccountNumber'] = response.account.accountNumber;
    data['Bankname'] = _selectedBank;
    data['BankCode'] = _bankCode;
    data['isDefault'] = false;

    _firestore
        .collection("Users")
        .document(fbUser.uid)
        .collection("Accounts")
        .add(data)
        .then((ref) {
      _removeDialog();
      _accountNumberController.clear();
      setState(() {
        _autoValidate = false;
      });
      Utils.showNormalMessage(context, "Account verified successfully",
          "Your account(${response.account.accountName}, ${response.account.accountNumber}, ${_selectedBank}) has been verified and added sucessfully.");
    });
  }

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

//this method will be in charge of verifying a bank account
