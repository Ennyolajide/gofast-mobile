import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';
import 'package:intl/intl.dart';

class UpdateProfile extends StatefulWidget {
  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  TextEditingController _firstnameController;
  TextEditingController _lastnameController;
  TextEditingController _dobController;
  TextEditingController _phoneNumberController;
  TextEditingController _communityNameController;
  TextEditingController _communityDescController;
  bool _autoValidate = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  FirebaseUser _fbUser;
  String _initialDate = "";
  String displayedDate;

  @override
  void initState() {
    _initPreferences();
    _getCurrentUser();
    super.initState();
  }

  _initPreferences() {
    Preferences.init().then((prefs) {
      if (Preferences.dob.toString().isNotEmpty) {
        setState(() {
          displayedDate = Preferences.dob;
        });
        print("dob is --> Preferences.dob");
        _initialDate = Preferences.dob
            .toString()
            .replaceAll("/", "")
            .split('')
            .reversed
            .join('');
      }
      print("initial date of birth  is --> $_initialDate");

      _firstnameController =
          TextEditingController(text: Preferences.firstname ?? "");
      _lastnameController =
          TextEditingController(text: Preferences.lastname ?? "");
      _dobController = TextEditingController(text: Preferences.dob ?? "");
      _phoneNumberController =
          TextEditingController(text: Preferences.phoneNumber ?? "");
      if (Preferences.signedUpForCommunity) {
        _communityNameController =
            TextEditingController(text: Preferences.communityName ?? "");
        _communityDescController =
            TextEditingController(text: Preferences.communityDesc ?? "");
      }
      print("Date of birth --> ${Preferences.dob}");
    });
  }

  _getCurrentUser() {
    _mAuth.currentUser().then((user) {
      setState(() {
        _fbUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: AppColors.buttonColor,
          title: Text('Update Profile',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 20),
              _buildNameContainer("Firstname"),
              _buildFirstnameSection(),
              _buildNameContainer("Lastname"),
              _buildLastnameSection(),
              _buildNameContainer("Date of birth"),
              _buildDObSection(),
              _buildNameContainer("Phone number"),
              _buildPhoneNumberSection(),
              Preferences.signedUpForCommunity
                  ? _buildNameContainer("Community name")
                  : SizedBox(),
              Preferences.signedUpForCommunity
                  ? _buildCommunityNameSection()
                  : SizedBox(),
              Preferences.signedUpForCommunity
                  ? _buildNameContainer("Community description")
                  : SizedBox(),
              Preferences.signedUpForCommunity
                  ? _buildCommunityDescSection()
                  : SizedBox(),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameContainer(String name) {
    return Container(
      margin: EdgeInsets.only(left: 19, right: 19, top: 10, bottom: 10),
      child: Text(name,
          style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 16,
              fontFamily: 'MontserratBold',
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFirstnameSection() {
    return Container(
      margin: EdgeInsets.only(left: 19, right: 19, bottom: 30),
      child: TextFormField(
        style: TextStyle(fontSize: 16),
        maxLines: null,
        keyboardType: TextInputType.text,
        controller: _firstnameController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 12, left: 12),
          labelText: 'Firstname',
          prefixIcon: Icon(
            Icons.person_outline,
            color: AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
          ),
          hasFloatingPlaceholder: false,
          labelStyle:
              TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
        ),
        validator: (val) {
          if (val.isEmpty) {
            return 'Field is required';
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Widget _buildLastnameSection() {
    return Container(
      margin: EdgeInsets.only(left: 19, right: 19, bottom: 30),
      child: TextFormField(
        style: TextStyle(fontSize: 16),
        maxLines: null,
        keyboardType: TextInputType.text,
        controller: _lastnameController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 12, left: 12),
          labelText: 'Lastname',
          prefixIcon: Icon(
            Icons.person_outline,
            color: AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
          ),
          hasFloatingPlaceholder: false,
          labelStyle:
              TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
        ),
        validator: (val) {
          if (val.isEmpty) {
            return 'Field is required';
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime.now());

    if (result == null) return;

    setState(() {
      displayedDate = DateFormat('dd/MM/yyyy').format(result);
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  Widget _buildDObSection() {
    return InkWell(
      onTap: () {
        _chooseDate(context, displayedDate);
      },
      child: Container(
        margin: EdgeInsets.only(left: 19, right: 19, bottom: 30),
        padding: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: AppColors.onboardingTextFieldBorder, width: 1))),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.date_range,
              color:
                  AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
            ),
            SizedBox(width: 10),
            Expanded(
                child: Container(
              child: Text(
                displayedDate ?? "",
                style: TextStyle(fontSize: 16),
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberSection() {
    return Container(
      margin: EdgeInsets.only(left: 19, right: 19, bottom: 30),
      child: TextFormField(
        style: TextStyle(fontSize: 16),
        maxLines: null,
        keyboardType: TextInputType.number,
        controller: _phoneNumberController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 12, left: 12),
          labelText: 'Phone number',
          prefixIcon: Icon(
            Icons.person_outline,
            color: AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
          ),
          hasFloatingPlaceholder: false,
          labelStyle:
              TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
        ),
        validator: (val) {
          if (val.isEmpty) {
            return 'Field is required';
          } else if (val.length != 11) {
            return 'Field must be 11 characters';
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Widget _buildCommunityNameSection() {
    return Container(
      margin: EdgeInsets.only(left: 19, right: 19, bottom: 30),
      child: TextFormField(
        style: TextStyle(fontSize: 16),
        maxLines: null,
        keyboardType: TextInputType.text,
        controller: _communityNameController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 12, left: 12),
          labelText: 'Community name',
          prefixIcon: Icon(
            Icons.person_outline,
            color: AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
          ),
          hasFloatingPlaceholder: false,
          labelStyle:
              TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
        ),
        validator: (val) {
          if (val.isEmpty) {
            return 'Field is required';
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Widget _buildCommunityDescSection() {
    return Container(
      margin: EdgeInsets.only(left: 19, right: 19, bottom: 10),
      child: TextFormField(
        style: TextStyle(fontSize: 16),
        maxLines: null,
        keyboardType: TextInputType.text,
        controller: _communityDescController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 12, left: 12),
          labelText: 'Community description',
          prefixIcon: Icon(
            Icons.person_outline,
            color: AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
          ),
          hasFloatingPlaceholder: false,
          labelStyle:
              TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
        ),
        validator: (val) {
          if (val.isEmpty) {
            return 'Field is required';
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 19, right: 19, bottom: 10),
      child: RaisedButton(
        onPressed: () {
          _validateDetails();
        },
        color: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Update Profile',
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

  void _validateDetails() {
    setState(() {
      _autoValidate = true;
    });
    final form = _formKey.currentState;
    if (form.validate()) {
      Utils.showLoadingDialog("Updating profile...", context);
      Map<String, dynamic> data = new Map();
      data['firstname'] = _firstnameController.text.trim();
      data['lastname'] = _lastnameController.text.trim();
      data['phoneNumber'] = _phoneNumberController.text.trim();
      data['DOB'] = displayedDate;
      if (Preferences.signedUpForCommunity) {
        data['communityName'] = _communityNameController.text.trim();
        data['communityDesc'] = _communityDescController.text.trim();
      }

      _firestore
          .collection("Users")
          .document(_fbUser.uid)
          .updateData(data)
          .then((data) {
        if (Preferences.signedUpForCommunity) {
          _firestore
              .collection("Community")
              .where('userId', isEqualTo: _fbUser.uid)
              .getDocuments()
              .then((snapshot) {
            Map<String, dynamic> map = new Map();
            map['username'] = _communityNameController.text.trim();

            snapshot.documents.forEach((document) {
              String docId = document.documentID;
              _firestore
                  .collection("Community")
                  .document(docId)
                  .updateData(map);
            });
          }).then((data) {
            setState(() {
              Preferences.firstname = _firstnameController.text.trim();
              Preferences.lastname = _lastnameController.text.trim();
              Preferences.phoneNumber = _phoneNumberController.text.trim();
              Preferences.dob = displayedDate;
              Preferences.communityName = _communityNameController.text.trim();
              Preferences.communityDesc = _communityDescController.text.trim();
            });
            Utils.removeLoadingDialog();
            Utils.showSnackBar("Details updated successfully", _scaffoldKey);
          });
        } else {
          setState(() {
            Preferences.firstname = _firstnameController.text.trim();
            Preferences.lastname = _lastnameController.text.trim();
            Preferences.phoneNumber = _phoneNumberController.text.trim();
            Preferences.dob = displayedDate;
          });
          Utils.removeLoadingDialog();
          Utils.showSnackBar("Details updated successfully", _scaffoldKey);
        }
      }).catchError((e) {
        print("error is ${e.toString()}");
      });
    }
  }
}
