import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/onboarding/bankAccountSetup/addbank.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  FirebaseUser _currentUser;
  bool _uidLoaded = false;

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
          _uidLoaded = true;
        });
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
          title: Text('My Accounts',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: false).push(
              CupertinoPageRoute<bool>(
                builder: (BuildContext context) => AddAccount(
                      fromOnboarding: false,
                    ),
              ),
            );
          },
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: AppColors.buttonColor,
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
                            return _buildAccountItem(
                                snapshot.data.documents[index]);
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
                  Text(snapShot['Bankname'],
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'ACCOUNT NAME',
                    style: TextStyle(
                        color: AppColors.transferHistoryItemTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 9),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: Text(
                      'ACCOUNT NUMBER',
                      style: TextStyle(
                          color: AppColors.transferHistoryItemTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
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
}
