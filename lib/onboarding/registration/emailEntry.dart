import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/config/urlconstants.dart';
import 'package:gofast/onboarding/registration/nameEntry.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/encryption.dart';
import 'package:gofast/utils/utils.dart';

class EmailSetup extends StatefulWidget {
  String transactionPin;

  EmailSetup(this.transactionPin);

  @override
  _EmailSetupState createState() => _EmailSetupState();
}

class _EmailSetupState extends State<EmailSetup> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _reEnterPasswordController =
      new TextEditingController();
  bool _autoValidate = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;
  bool _isIos;
  bool _isShowing = false;
  BuildContext _dialogContext;

  @override
  void initState() {
    _initPreferences();
    super.initState();
  }

  void _initPreferences() {
    Preferences.init().then((prefs) {});
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _reEnterPasswordController.dispose();
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
            key: _scaffoldKey,
            backgroundColor: Colors.transparent,
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
                  SizedBox(height: screenAwareSize(130, context)),
                  buildEmailTextContainer(),
                  buildEmailTextField(),
                  SizedBox(height: screenAwareSize(10, context)),
                  _buildPasswordContainer(),
                  _buildPasswordTextField(),
                  SizedBox(height: screenAwareSize(10, context)),
                  _buildReenterPasswordContainer(),
                  _buildRenterPasswordTextField(),
                  buildNextButton()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmailTextContainer() {
    return Container(
      margin: EdgeInsets.only(left: 27),
      child: Text('Enter your email',
          style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 19,
              fontFamily: 'MontserratBold',
              fontWeight: FontWeight.bold)),
    );
  }

  Widget buildEmailTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(fontSize: 16),
        maxLines: null,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.mail_outline,
            color: AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
          ),
          contentPadding: EdgeInsets.only(bottom: 12, left: 12),
          labelText: 'Email address',
          hasFloatingPlaceholder: false,
          labelStyle:
              TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
        ),
        validator: (val) {
          if (val.isEmpty) {
            return 'Email Address is required';
          } else if (!Utils.validateEmail(val)) {
            return 'Please enter valid email Address';
          }else{
            return null;
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Widget _buildPasswordContainer() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(20, context), left: 27),
      child: Text('Enter your password',
          style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 19,
              fontFamily: 'MontserratBold',
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildReenterPasswordContainer() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(20, context), left: 27),
      child: Text('Re-enter your password',
          style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 19,
              fontFamily: 'MontserratBold',
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPasswordTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19),
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        keyboardType: TextInputType.text,
        style: TextStyle(fontSize: 16),
        maxLines: null,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outline,
            color: AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
          ),
          contentPadding: EdgeInsets.only(bottom: 12, left: 12),
          labelText: 'Password',
          hasFloatingPlaceholder: false,
          labelStyle: TextStyle(
              color: AppColors.onboardingTextFieldHintTextColor, height: 1),
        ),
        validator: (val) {
          if (val.isEmpty) {
            return 'Field is required';
          } else if (val.length < 8) {
            return 'Password must be at least 8 characters';
          }else{
            return null;
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Widget _buildRenterPasswordTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19),
      child: TextFormField(
        controller: _reEnterPasswordController,
        obscureText: true,
        keyboardType: TextInputType.text,
        style: TextStyle(fontSize: 16),
        maxLines: null,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outline,
            color: AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
          ),
          contentPadding: EdgeInsets.only(bottom: 12, left: 12),
          labelText: 'Re-enter password',
          hasFloatingPlaceholder: false,
          labelStyle:
              TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
        ),
        validator: (val) {
          if (val.isEmpty) {
            return 'Field is required';
          } else if (val.length < 8) {
            return 'Password must be at least 8 characters';
          }else{
            return null;
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Widget buildNextButton() {
    return Container(
      margin: EdgeInsets.only(
          left: 19,
          right: 19,
          top: screenAwareSize(80, context),
          bottom: screenAwareSize(20, context)),
      child: RaisedButton(
        onPressed: _submit,
        color: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Next',
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

  void _submit() {
    if (_passwordController.text != _reEnterPasswordController.text) {
      Utils.showSnackBar("Passwords do not match", _scaffoldKey);
    } else {
      setState(() {
        _autoValidate = true;
      });
      final form = _formKey.currentState;

      if (form.validate()) {
        _signUpUser();
      }
    }
  }

  Future _signUpUser() async {
    _showDialog("Please wait");
    try {
      FirebaseUser user = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      print(user);
      if (user != null) {
        Encryption encryption =
            new Encryption(secretKey: UrlConstants.LIVE_SECRET_KEY);
        Map<String, dynamic> data = new Map();

        data['transactionPin'] =
            encryption.encryptTransactionPin(widget.transactionPin);
        _firestore
            .collection("Users")
            .document(user.uid)
            .setData(data)
            .then((data) {
          Preferences.email = _emailController.text.trim();

          Navigator.of(context, rootNavigator: false).push(
            CupertinoPageRoute<bool>(
              builder: (BuildContext context) => NameEntry(),
            ),
          );
        });
      }
    } catch (e) {
      removeDialog();

      Utils.showSnackBar(e.message, _scaffoldKey);

      print("Error-------->: ${e.message}");
      print(e);
    }
  }

  void removeDialog() {
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
      builder: (BuildContext context) {s
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
