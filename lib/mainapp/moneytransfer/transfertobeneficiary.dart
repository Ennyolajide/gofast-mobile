import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/mainapp/beneficiaries/addbeneficiaries.dart';
import 'package:gofast/mainapp/moneytransfer/detailsforbeneficiarytransfer.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';

class TransferToBeneficiary extends StatefulWidget {
  @override
  _TransferToBeneficiaryState createState() => _TransferToBeneficiaryState();
}

class _TransferToBeneficiaryState extends State<TransferToBeneficiary> {
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  FirebaseUser _currentUser;
  bool _uidLoaded = false;

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
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: AppColors.buttonColor,
          title: Text('Select beneficiary(tap to select)',
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
                    .collection("Beneficiaries")
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
                        'An error occurred retrieving beneficiaries',
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
                                _moveToTransferDetailsInput(
                                    accountname: snapshot.data.documents[index]
                                        ['accountName'],
                                    accountNumber: snapshot
                                        .data.documents[index]['accountNumber'],
                                    bankCode: snapshot.data.documents[index]
                                        ['bankCode'],
                                    bankname: snapshot.data.documents[index]
                                        ['bankName'],
                                    currency: snapshot.data.documents[index]
                                        ['currency']);
                              },
                              child: _buildBeneficiaryItem(
                                  snapshot.data.documents[index]),
                            );
                          });
                    } else {
                      return Center(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Text(
                              'You have no beneficiaries',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                Navigator.of(context, rootNavigator: false)
                                    .push(CupertinoPageRoute<bool>(
                                        builder: (BuildContext context) =>
                                            AddBeneficiaries()));
                              },
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  "Add Beneficiaries",
                                  style: TextStyle(color: AppColors.textColor),
                                ),
                              ))
                        ],
                      ));
                    }
                  }
                },
              )
            : SizedBox(),
      ),
    );
  }

  Widget _buildBeneficiaryItem(DocumentSnapshot snapshot) {
    return Container(
      margin: EdgeInsets.only(top: 25, left: 20, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Icon(
                  Icons.account_balance,
                  size: 20,
                  color: AppColors.buttonColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 18),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    snapshot['accountName'],
                    style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 17,
                        fontFamily: 'MontserratSemiBold'),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        snapshot['accountNumber'],
                        style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 14,
                            fontFamily: 'MontserratSemiBold'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          snapshot['bankName'],
                          style: TextStyle(
                            color: AppColors.onboardingTextFieldHintTextColor,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 15),
              Divider(
                height: 0.0,
              )
            ],
          ))
        ],
      ),
    );
  }

  void _moveToTransferDetailsInput(
      {String accountname,
      String accountNumber,
      String bankCode,
      String bankname,
      String currency}) {
    Navigator.of(context, rootNavigator: false).push(
      CupertinoPageRoute<bool>(
        builder: (BuildContext context) => DetailsForbeneficiaryTransfer(
          accountname: accountname,
          accountnumber: accountNumber,
          bankcode: bankCode,
          bankname: bankname,
          currency: currency,
        ),
      ),
    );
  }
}
