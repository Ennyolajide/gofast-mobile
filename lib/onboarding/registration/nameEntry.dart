import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/onboarding/registration/introDashBoard.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';
import 'package:intl/intl.dart';

class NameEntry extends StatefulWidget {
  @override
  _NameEntryState createState() => _NameEntryState();
}

class _NameEntryState extends State<NameEntry> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _firstnameController = TextEditingController();
  TextEditingController _lastnameController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  bool _autoValidate = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  Firestore _firestore = Firestore.instance;
  FirebaseUser _currentUser;
  bool _isShowing = false;
  BuildContext _dialogContext;
  bool _isIos;
  String date;
  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('dd/MM/yyyy'),
    InputType.time: DateFormat("HH:mm"),
  };

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
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            color: Colors.white,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset(
              'assets/lock.png',
              width: 271,
              fit: BoxFit.contain,
              height: screenAwareSize(271, context),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            key: _scaffoldKey,
            body: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 5, right: 27, top: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        BackButton(color: AppColors.buttonColor),
                        Image.asset('assets/gofast_gold.png',
                            width: 122, height: 24),
                      ],
                    ),
                  ),
                  SizedBox(height: screenAwareSize(100, context)),
                  _buildTextContainer(),
                  SizedBox(height: screenAwareSize(36, context)),
                  buildFirstNameTextField(),
                  SizedBox(height: screenAwareSize(31, context)),
                  buildLastNameTextField(),
                  SizedBox(height: screenAwareSize(31, context)),
                  buildDobTextField(),
                  _buildDobText(),
                  buildNextButton(),
//                  _buildSkipButton()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContainer() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(20, context), left: 27),
      child: Text('Enter your names and date of birth',
          style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 19,
              fontFamily: 'MontserratBold',
              fontWeight: FontWeight.bold)),
    );
  }

  Widget buildFirstNameTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19),
      child: TextFormField(
          controller: _firstnameController,
          style: TextStyle(fontSize: 16),
          maxLines: null,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person_outline,
              color:
                  AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
            ),
            contentPadding: EdgeInsets.only(bottom: 12, left: 12),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
            ),
            labelText: 'Firstname',
            hasFloatingPlaceholder: false,
            labelStyle:
                TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
          ),
          autovalidate: _autoValidate,
          validator: (val) {
            if (val.isEmpty) {
              return 'Field is required';
            }
          }),
    );
  }

  Widget buildLastNameTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19),
      child: TextFormField(
          controller: _lastnameController,
          style: TextStyle(fontSize: 16),
          maxLines: null,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person_outline,
              color:
                  AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
            ),
            contentPadding: EdgeInsets.only(bottom: 12, left: 12),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
            ),
            labelText: 'Lastname',
            hasFloatingPlaceholder: false,
            labelStyle:
                TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
          ),
          autovalidate: _autoValidate,
          validator: (val) {
            if (val.isEmpty) {
              return 'Field is required';
            }
          }),
    );
  }

  Widget buildDobTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19),
      child: DateTimePickerFormField(
          controller: _dobController,
          inputType: InputType.date,
          format: formats[InputType.date],
          editable: false,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.date_range,
              color:
                  AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
            ),
            contentPadding: EdgeInsets.only(bottom: 12, left: 12),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
            ),
            labelText: 'Dob',
            hasFloatingPlaceholder: false,
            labelStyle:
                TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
          ),
          onChanged: (dt) {
            print("date is $date");
            print("date is ${_dobController.text}");
          },
          enabled: true,
          autovalidate: _autoValidate,
          validator: (val) {
            if (val == null) {
              return 'Field is required';
            }
          }),
    );
  }

  Widget _buildDobText() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19, vertical: 10),
      alignment: Alignment.center,
      child: Text(
        'Note: if you are a zenith bank account holder, enter date of birth that corresponds with your bank account.',
        style: TextStyle(color: AppColors.onboardingPlaceholderText),
      ),
    );
  }

  Widget buildNextButton() {
    return Container(
      margin: EdgeInsets.only(
          left: 19, right: 19, top: screenAwareSize(60, context)),
      child: RaisedButton(
        onPressed: () {
          _submit();
        },
        color: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Complete sign up',
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

  Widget _buildSkipButton() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(20, context)),
      child: InkWell(
        onTap: () {
          _moveToNext();
        },
        child: Center(
          child: Text(
            'Skip',
            style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.25,
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    setState(() {
      _autoValidate = true;
    });
    final form = _formKey.currentState;
    if (form.validate()) {
      _showDialog("Setting up...");
      Preferences.firstname = _firstnameController.text.trim();
      Preferences.lastname = _lastnameController.text.trim();
      Preferences.dob = _dobController.text.trim();
      Preferences.signedUpForCommunity = false;
      String email = Preferences.email;

      Map<String, dynamic> userData = Map();
      userData['email'] = email;
      userData['firstname'] = Preferences.firstname;
      userData['lastname'] = Preferences.lastname;
      userData['phoneNumber'] = Preferences.phoneNumber;
      userData['userId'] = _currentUser.uid;
      userData['deviceId'] = Preferences.deviceId;
      userData['DOB'] = Preferences.dob;
      userData['ProfilePicture'] = "";
      userData['signedUpForCommunity'] = false;

      try {
        _firestore
            .collection("Users")
            .document(_currentUser.uid)
            .updateData(userData)
            .then((data) {
          _removeDialog();
          Navigator.of(context, rootNavigator: false).push(
            CupertinoPageRoute<bool>(
              builder: (BuildContext context) => DashBoardIntro(),
            ),
          );
//          });
        });
      } catch (e) {
        _removeDialog();

        Utils.showSnackBar(e.message, _scaffoldKey);
      }
    }
  }

  void _moveToNext() {
    _showDialog("Setting Up");
    String email = Preferences.email;

    Map<String, dynamic> userData = Map();
    userData['email'] = email;
    userData['phoneNumber'] = Preferences.phoneNumber;
    userData['userId'] = _currentUser.uid;
    userData['deviceId'] = Preferences.deviceId;

    try {
      _firestore
          .collection("Users")
          .document(_currentUser.uid)
          .setData(userData)
          .then((data) {
        //data added successfully
        _removeDialog();
        Utils.showSnackBar("Set up complete", _scaffoldKey);
        Future.delayed(new Duration(seconds: 1), () {
          Utils.removeSnackBar(_scaffoldKey);
          Navigator.of(context, rootNavigator: false).push(
            CupertinoPageRoute<bool>(
              builder: (BuildContext context) => DashBoardIntro(),
            ),
          );
        });
      });
    } catch (e) {
      _removeDialog();

      Utils.showSnackBar(e.message, _scaffoldKey);
      Utils.removeSnackBar(_scaffoldKey);
    }
  }

  void _removeDialog() {
    Navigator.of(_dialogContext).pop();
    print("details updated");
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
