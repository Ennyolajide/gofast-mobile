import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/mainapp/community/community.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class Services extends StatefulWidget {
  @override
  _ServicesState createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  bool _autoValidate = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  BuildContext _dialogContext;
  Firestore _firestore = Firestore.instance;
  FirebaseUser _currentUser;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isIos;
  TextEditingController _communityNameController = TextEditingController();
  TextEditingController _communityDescController = TextEditingController();

  @override
  void initState() {
    _getCurrentUser();
    _initPreferences();
    super.initState();
  }

  void _getCurrentUser() {
    _auth.currentUser().then((user) {
      _currentUser = user;
    });
  }

  void _initPreferences() {
    Preferences.init().then((prefs) {});
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: AppColors.buttonColor,
          title: Text('Services ',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 19),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                _buildHeader(),
                SizedBox(
                  height: screenAwareSize(50, context),
                ),
                _buildServiceName(),
                SizedBox(height: screenAwareSize(50, context)),
                _buildServiceDescription(),
                _buildConnectButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              'Join other individuals who have shared their services and are ready to connect.',
              style: TextStyle(
                  color: AppColors.onboardingPlaceholderText, fontSize: 16)),
          Text('Set up your services profile now',
              style: TextStyle(
                  color: AppColors.onboardingPlaceholderText,
                  fontSize: 16,
                  fontFamily: 'MontserratSemiBold'))
        ],
      ),
    );
  }

  Widget _buildServiceName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Enter service name',
            style: TextStyle(
                color: AppColors.onboardingPlaceholderText,
                fontSize: 19,
                fontFamily: 'MontserratBold',
                fontWeight: FontWeight.bold)),
        SizedBox(height: screenAwareSize(10, context)),
        TextFormField(
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 16),
            maxLines: null,
            controller: _communityNameController,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.buttonColor, width: 1.0),
              ),
              contentPadding: EdgeInsets.only(bottom: 12, left: 12),
              labelText: 'Service name',
              hasFloatingPlaceholder: false,
              labelStyle:
                  TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
            ),
            autovalidate: _autoValidate,
            validator: (val) {
              if (val.isEmpty) {
                return 'Field is required';
              }
            })
      ],
    );
  }

  Widget _buildServiceDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Enter service description',
            style: TextStyle(
                color: AppColors.onboardingPlaceholderText,
                fontSize: 19,
                fontFamily: 'MontserratBold',
                fontWeight: FontWeight.bold)),
        SizedBox(height: screenAwareSize(10, context)),
        TextFormField(
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 16),
            maxLines: null,
            controller: _communityDescController,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.buttonColor, width: 1.0),
              ),
              contentPadding: EdgeInsets.only(bottom: 12, left: 12),
              labelText: 'Description',
              hasFloatingPlaceholder: false,
              labelStyle:
                  TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
            ),
            autovalidate: _autoValidate,
            validator: (val) {
              if (val.isEmpty) {
                return 'Field is required';
              }
            })
      ],
    );
  }

  Widget _buildConnectButton() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(100, context)),
      child: RaisedButton(
        onPressed: () {
          handleCommunitySignIn();
        },
        color: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Connect with community',
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

  void handleCommunitySignIn() {
    setState(() {
      _autoValidate = true;
    });
    final form = _formKey.currentState;
    if (form.validate()) {
      _showDialog("Setting up...");

      if (_currentUser != null) {
        _firestore
            .collection("Users")
            .document(_currentUser.uid)
            .get()
            .then((snapShot) {
          String onlineUserId = snapShot.data['deviceId'];
          if (onlineUserId == Preferences.deviceId) {
            _firestore
                .collection("Users")
                .where('communityName',
                    isEqualTo: _communityNameController.text)
                .getDocuments()
                .then((snapshots) {
              if (snapshots.documents.length > 0) {
                _removeDialog();
                Utils.showErrorDialog(context, "Error",
                    "Oops, Community name already taken, try again");
              } else {
                Map<String, dynamic> userData = Map();
                userData['signedUpForCommunity'] = true;
                userData['communityName'] = _communityNameController.text;
                userData['communityDesc'] = _communityDescController.text;

                try {
                  _firestore
                      .collection("Users")
                      .document(_currentUser.uid)
                      .updateData(userData)
                      .then((data) {
                    setState(() {
                      Preferences.signedUpForCommunity = true;
                      Preferences.communityName = _communityNameController.text;
                      Preferences.communityDesc = _communityDescController.text;
                    });
                    _removeDialog();
                    Navigator.pop(context);
                    Navigator.of(context, rootNavigator: false).push(
                      CupertinoPageRoute<bool>(
                        builder: (BuildContext context) => CommunityPage(),
                      ),
                    );
//          });
                  });
                } catch (e) {
                  _removeDialog();

                  Utils.showSnackBar(e.message, _scaffoldKey);
                }
              }
            });
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
