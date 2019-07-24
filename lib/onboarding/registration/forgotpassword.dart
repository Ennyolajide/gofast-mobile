import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool _autoValidate = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _isIos;
  TextEditingController _emailController = new TextEditingController();
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  BuildContext _dialogContext;
  bool _isShowing = false;

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
            body: Stack(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: ListView(
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
                      _buildEmailTextContainer(),
                      SizedBox(height: screenAwareSize(15, context)),
                      _buildEmailAddressTextField(),
                      _buildResetButton()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailTextContainer() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(20, context), left: 27),
      child: Text('Enter your email',
          style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 19,
              fontFamily: 'MontserratBold',
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmailAddressTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19),
      child: TextFormField(
        style: TextStyle(fontSize: 16),
        maxLines: null,
        keyboardType: TextInputType.emailAddress,
        controller: _emailController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 12, left: 12),
          labelText: 'Email',
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
            return 'Email Address is required';
          } else if (!Utils.validateEmail(val)) {
            return 'Please enter valid email Address';
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      margin: EdgeInsets.only(
          top: screenAwareSize(100, context), left: 19, right: 19),
      child: RaisedButton(
        onPressed: () {
          setState(() {
            _autoValidate = true;
          });
          final form = _formKey.currentState;
          if (form.validate()) {
            _resetPassword();
          }
        },
        color: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Reset Password',
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

  Future _resetPassword() async {
    try {
      _showDialog("Please wait...");
      await _mAuth.sendPasswordResetEmail(email: _emailController.text.trim());
      _removeDialog();
      Utils.showSnackBar(
          "Check your email to complete the process", _scaffoldKey);
    } catch (e) {
      _removeDialog();

      Utils.showSnackBar(e.message, _scaffoldKey);

      print("Error-------->: ${e.message}");
    }
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
            onWillPop: () {});
      },
    );
  }
}
