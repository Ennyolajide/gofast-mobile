import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/onboarding/registration/phoneNumberEntry.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class PasswordSetup extends StatefulWidget {
  @override
  _PasswordSetupState createState() => _PasswordSetupState();
}

class _PasswordSetupState extends State<PasswordSetup> {
  var passwordVisible = true;

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
          backgroundColor: Colors.transparent,
          body: ListView(
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
              buildPasswordContainer(),
              SizedBox(height: screenAwareSize(20, context)),
              buildPasswordTextField(),
              SizedBox(height: screenAwareSize(20, context)),
              buildRenterPasswordTextField(),
              buildNextButton()
            ],
          ),
        ),
      ],
    ));
  }

  Widget buildPasswordContainer() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(20, context), left: 27),
      child: Text('Create your password',
          style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 19,
              fontFamily: 'MontserratBold',
              fontWeight: FontWeight.bold)),
    );
  }

  Widget buildPasswordTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19),
      child: TextField(
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
      ),
    );
  }

  Widget buildRenterPasswordTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19),
      child: TextField(
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
      ),
    );
  }

  Widget buildNextButton() {
    return Container(
      margin: EdgeInsets.only(
          left: 19, right: 19, top: screenAwareSize(100, context)),
      child: RaisedButton(
        onPressed: () {
          Navigator.of(context, rootNavigator: false).push(
            CupertinoPageRoute<bool>(
              builder: (BuildContext context) => PhoneNumberEntry(""),
            ),
          );
        },
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
}
