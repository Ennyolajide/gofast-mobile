import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/mainapp/beneficiaries/addbeneficiaries.dart';
import 'package:gofast/utils/colors.dart';

class Beneficiaries extends StatefulWidget {
  @override
  _BeneficiariesState createState() => _BeneficiariesState();
}

class _BeneficiariesState extends State<Beneficiaries> {
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  FirebaseUser fbUser;
  bool _uidLoaded = false;

  @override
  void initState() {
    _getFirebaseUser();
    super.initState();
  }

  void _getFirebaseUser() {
    _mAuth.currentUser().then((user) {
      setState(() {
        fbUser = user;
        _uidLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: AppColors.buttonColor,
        title: Text('Beneficiaries',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 12),
        child: (_uidLoaded)
            ? StreamBuilder(
                stream: _firestore
                    .collection("Users")
                    .document(fbUser.uid)
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
                        'An error occurred retrieving beneficiaries.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.buttonColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data.documents.length > 0) {
                      return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            return _buildBeneficiaryItem(
                                snapshot.data.documents[index]);
                          });
                    } else {
                      return Center(
                        child: Text(
                          'You have no beneficiaries.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.buttonColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                  }
                })
            : SizedBox(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: false).push(
            CupertinoPageRoute<bool>(
              builder: (BuildContext context) => AddBeneficiaries(),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: AppColors.buttonColor,
      ),
    ));
  }

  Widget _buildBeneficiaryItem(DocumentSnapshot snapshot) {
    return Container(
      margin: EdgeInsets.only(top: 25),
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
}
