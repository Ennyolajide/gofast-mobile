import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gofast/utils/colors.dart';

class Milestones extends StatefulWidget {
  @override
  _MilestonesState createState() => _MilestonesState();
}

class _MilestonesState extends State<Milestones> {
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  FirebaseUser _currentUser;
  List<Widget> widgets = new List();
  bool loadData = false;

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
      }
      _firestore
          .collection("Users")
          .document(_currentUser.uid)
          .collection("Transfers")
          .getDocuments()
          .then((documents) {
        if (documents.documents.length > 0) {
          if (documents.documents.length >= 10) {
            widgets.add(_buildMilestoneItem('You completed 10 transactions'));
          } else if (documents.documents.length >= 20) {
            widgets.add(_buildMilestoneItem('You completed 20 transactions'));
          } else if (documents.documents.length >= 30) {
            widgets.add(_buildMilestoneItem('You completed 30 transactions'));
          } else if (documents.documents.length >= 40) {
            widgets.add(_buildMilestoneItem('You completed 40 transactions'));
          } else if (documents.documents.length >= 50) {
            widgets.add(_buildMilestoneItem('You completed 50 transactions'));
          } else if (documents.documents.length >= 60) {
            widgets.add(_buildMilestoneItem('You completed 60 transactions'));
          } else if (documents.documents.length >= 70) {
            widgets.add(_buildMilestoneItem('You completed 70 transactions'));
          } else if (documents.documents.length >= 80) {
            widgets.add(_buildMilestoneItem('You completed 80 transactions'));
          } else if (documents.documents.length >= 90) {
            widgets.add(_buildMilestoneItem('You completed 90 transactions'));
          } else if (documents.documents.length >= 100) {
            widgets.add(_buildMilestoneItem('You completed 100 transactions'));
          } else {
            widgets.add(Container(
              margin: EdgeInsets.only(top: 200),
              child: Text('You have not reached any milestone yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ));
          }
          setState(() {
            loadData = true;
          });
        } else {
          widgets.add(Container(
            margin: EdgeInsets.only(top: 200),
            child: Text('You have not made any transaction yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ));
          setState(() {
            loadData = true;
          });
        }
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
        title: Text('Milestones',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: (loadData)
            ? ListView(
                children: widgets,
              )
            : Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.buttonColor)),
              ),
      ),
    ));
  }

  Widget _buildMilestoneItem(String mileStone) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Card(
        elevation: 8,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(mileStone,
                  style: TextStyle(
                      color: AppColors.onboardingPlaceholderText,
                      fontSize: 17)),
              Image.asset(
                'assets/checked.png',
                width: 18,
                height: 18,
              )
            ],
          ),
        ),
      ),
    );
  }
}
