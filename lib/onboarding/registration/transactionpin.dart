import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/onboarding/registration/emailEntry.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class TransactionPin extends StatefulWidget {
  @override
  _TransactionPinState createState() => _TransactionPinState();
}

class _TransactionPinState extends State<TransactionPin> {
  bool _autoValidate = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _pinController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                  _buildPinTextContainer(),
                  _buildPinTextField(),
                  _buildNextButton()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinTextContainer() {
    return Container(
      margin: EdgeInsets.only(left: 19, right: 19),
      child: Text(
          'Enter your transaction pin (you will be required to input this pin when carrying out transactions)',
          style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 19,
              fontFamily: 'MontserratBold',
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPinTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19, vertical: 15),
      child: TextFormField(
        controller: _pinController,
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 16),
        maxLines: null,
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.lock_outline,
            color: AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
          ),
          contentPadding: EdgeInsets.only(bottom: 12, left: 12),
          labelText: 'Pin',
          hasFloatingPlaceholder: false,
          labelStyle:
              TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
        ),
        validator: (val) {
          if (val.isEmpty) {
            return 'Pin is required';
          } else if (val.length < 5) {
            return 'Pin must be at least 5 characters long';
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Widget _buildNextButton() {
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
    setState(() {
      _autoValidate = true;
    });
    final form = _formKey.currentState;

    if (form.validate()) {
      _moveToEmail();
    }
  }

  void _moveToEmail() {
    Navigator.of(context, rootNavigator: false).push(
      CupertinoPageRoute<bool>(
        builder: (BuildContext context) =>
            EmailSetup(_pinController.text.trim()),
      ),
    );
  }
}
