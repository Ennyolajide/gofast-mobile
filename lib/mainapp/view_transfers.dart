import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/mainapp/transferdetails.dart';
import 'package:gofast/utils/colors.dart';
import 'package:intl/intl.dart';

class ViewTransfers extends StatefulWidget {
  @override
  _ViewTransfersState createState() => _ViewTransfersState();
}

class _ViewTransfersState extends State<ViewTransfers> {
  bool _uidLoaded = false;
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  FirebaseUser _currentUser;
  DateFormat _dateFormat = new DateFormat("EEE, MMM d, ''yy hh:mm aaa");

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
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
          title: Text('View Transfers',
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
                    .collection("Transfers")
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
                        'An error occurred retrieving transfer list',
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
                                _navigateToTransferDetails(
                                  snapshot.data.documents[index]['accountName'],
                                  snapshot.data.documents[index]
                                      ['accountNumber'],
                                  snapshot.data.documents[index]['amount'],
                                  snapshot.data.documents[index]['bankName'],
                                  snapshot.data.documents[index]['remarks'],
                                  snapshot.data.documents[index]['time'],
                                );
                              },
                              child: _buildTransferItem(
                                  snapshot.data.documents[index]),
                            );
                          });
                    } else {
                      return Center(
                        child: Container(
                          child: Text(
                            'You have no transfer history',
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

  Widget _buildTransferItem(DocumentSnapshot snapShot) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
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
                  size: 17,
                  color: AppColors.buttonColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 7),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Transfer to ${snapShot['accountName']}',
                          style: TextStyle(
                              color: AppColors.onboardingPlaceholderText,
                              fontFamily: 'MontserratSemiBold',
                              fontSize: 15),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${_dateFormat.format(DateTime.parse(snapShot['time']))}',
                            style: TextStyle(
                                color: AppColors.viewTransferColor,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'N${snapShot['amount']}',
                    style: TextStyle(
                        color: AppColors.onboardingPlaceholderText,
                        fontFamily: 'MontserratBold',
                        fontSize: 16),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 2),
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.onboardingPlaceholderText,
                      size: 20,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Divider(height: 0.0)
            ],
          ))
        ],
      ),
    );
  }

  void _navigateToTransferDetails(String accountName, String accountNumber,
      String amount, String bankName, String remarks, String time) {
    Navigator.of(context, rootNavigator: false).push(
      CupertinoPageRoute<bool>(
        builder: (BuildContext context) => TransferDetails(
              accountname: accountName,
              accountNubmer: accountNumber,
              amount: amount,
              remarks: remarks,
              bankName: accountName,
              time: _dateFormat.format(DateTime.parse(time)),
            ),
      ),
    );
  }
}
