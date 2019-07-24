import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/config/CONFIG.dart';
import 'package:gofast/mainapp/maindashboard.dart';
import 'package:gofast/network/apiservice.dart';
import 'package:gofast/network/request/sendotprequest.dart';
import 'package:gofast/network/request/validateotprequest.dart';
import 'package:gofast/onboarding/registration/transactionpin.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';

class OtpSetup extends StatefulWidget {
  String phoneNumber;
  String type;
  String session;

  OtpSetup({this.phoneNumber, this.type, this.session});

  @override
  _OtpSetupState createState() => _OtpSetupState();
}

class _OtpSetupState extends State<OtpSetup> {
  bool _isButtonDisabled = true;
  int _timerSecond = 120;
  Timer _timer;
  PinEditingController _pinEditingController = PinEditingController();
  PinDecoration _pinDecoration = UnderlineDecoration(
      color: AppColors.buttonColor,
      lineHeight: 1,
      textStyle: TextStyle(
          fontSize: 24,
          color: Colors.black87,
          fontFamily: "MontserratSemiBold"));
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  Firestore _firestore = Firestore.instance;
  FirebaseUser _currentUser;
  BuildContext _dialogContext;
  bool _isIos;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _mAuth.currentUser().then((user) {
      _currentUser = user;
    });

    if (widget.type == "LoginChange") {
      _mAuth.signOut();
    }

    _countdown();
    _initPreferences();
  }

  void _initPreferences() {
    Preferences.init().then((val) {});
  }

  @override
  void dispose() {
    _pinEditingController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _moveToEmail() {
    Preferences.phoneNumber = widget.phoneNumber;
    //verify otp
    print("PhoneNumber in preferences is ${Preferences.phoneNumber}");

    Navigator.of(context, rootNavigator: false).push(
      CupertinoPageRoute<bool>(
        builder: (BuildContext context) => TransactionPin(),
      ),
    );
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
            body: ListView(
              children: <Widget>[
                _buildHeader(),
                SizedBox(height: screenAwareSize(130, context)),
                _buildPhoneNumberTextContainer(),
                SizedBox(
                  height: screenAwareSize(25, context),
                ),
                _buildOtpTextField(),
                SizedBox(
                  height: screenAwareSize(49, context),
                ),
                noCodeSection(),
                _buildVerifyButton(),
                _buildResetButton()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 27, top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          BackButton(color: AppColors.buttonColor),
          Image.asset('assets/gofast_gold.png', width: 122, height: 24),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberTextContainer() {
    return Container(
        margin: EdgeInsets.only(
            top: screenAwareSize(20, context), left: 19, right: 19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Enter the 6-digit code sent to ',
                style: TextStyle(
                    color: AppColors.onboardingPlaceholderText,
                    fontSize: 22,
                    fontFamily: 'MontserratSemiBold',
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.phoneNumber,
                  style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 22,
                      fontFamily: "MontserratSemiBold"),
                ),
                Text(
                  '$_timerSecond',
                  style: TextStyle(
                      color: AppColors.onboardingTextFieldHintTextColor,
                      fontSize: 18),
                )
              ],
            )
          ],
        ));
  }

  Widget _buildOtpTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: PinInputTextField(
        pinLength: 6,
        decoration: _pinDecoration,
        width: 40,
        pinEditingController: _pinEditingController,
        autoFocus: false,
        onSubmit: (pin) {},
      ),
    );
  }

  Widget noCodeSection() {
    return InkWell(
      onTap: () {},
      child: Container(
        alignment: Alignment.center,
        child: Text(
          'I haven\'t received a code',
          style: TextStyle(
              color: AppColors.textColor,
              fontSize: 15,
              fontFamily: 'MontserratSemiBold'),
        ),
      ),
    );
  }

  void verifyOtp() {
    if (_pinEditingController.text.length == 6) {
      NetworkService networkService = new NetworkService();
      ValidateOtpRequest validateOtpRequest = new ValidateOtpRequest(
          CONFIG.TWOFACTOR_API_KEY, widget.session, _pinEditingController.text);

      if (widget.type == "LoginChange") {
        //perform otp verification
        //if otp verification was successful
        _showDialog("Validating otp...");
        networkService.validateOtp(validateOtpRequest).then((response) {
          if (response.status == "Success" &&
              response.message != "OTP Expired") {
            _removeDialog();
            _moveToHomeScreen();
          } else if (response.status == "Success" &&
              response.message == "OTP Expired") {
            _removeDialog();
            Utils.showErrorDialog(
                context, "Error", response.message + ", click resend otp");
          } else {
            _removeDialog();
            Utils.showErrorDialog(context, "Error", response.message);
          } //for sign up process
          _pinEditingController.text = "";
        }).catchError((e) {
          _removeDialog();
          Utils.showErrorDialog(context, "Error", "An error occured try Again");
        });
      } else {
        //perform otp verification
        _showDialog("Validating otp...");

        networkService.validateOtp(validateOtpRequest).then((response) {
          if (response.status == "Success" &&
              response.message != "OTP Expired") {
            _removeDialog();
            Utils.showSnackBar(
                "Phone number verified successfully.", _scaffoldKey);
            Utils.removeSnackBar(_scaffoldKey);
            _moveToEmail();
          } else if (response.status == "Success" &&
              response.message == "OTP Expired") {
            _removeDialog();
            Utils.showErrorDialog(
                context, "Error", response.message + ", click resend otp");
          } else {
            _removeDialog();
            Utils.showErrorDialog(context, "Error", response.message);
          } //for sign up process
          _pinEditingController.text = "";
        }).catchError((e) {
          _removeDialog();
          Utils.showErrorDialog(context, "Error", "An error occured try Again");
        });
      }
    } else {
      Utils.showErrorDialog(context, "Error", "OTP must be six digits");
    }
  }

  Widget _buildVerifyButton() {
    return Container(
      margin: EdgeInsets.only(
          left: 19, right: 19, top: screenAwareSize(50, context)),
      child: RaisedButton(
        onPressed: () {
          verifyOtp();
        },
        color: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Verify otp',
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

  Widget _buildResetButton() {
    return Container(
      margin: EdgeInsets.only(
          left: 19, right: 19, top: screenAwareSize(20, context)),
      child: RaisedButton(
        onPressed: _isButtonDisabled ? null : resendotp,
        color: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Resend otp',
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

  void resendotp() {
    if (this.mounted) {
      setState(() {
        _isButtonDisabled = true;
        _timerSecond = 120;
      });
    }
    _countdown();
    _showDialog("Sending otp..");
    NetworkService networkService = new NetworkService();
    SendOtpRequest request =
        new SendOtpRequest(CONFIG.TWOFACTOR_API_KEY, widget.phoneNumber);
    networkService.sendOtp(request).then((response) {
      if (response.status == "Success") {
        _removeDialog();
        Utils.showSnackBar(
            "A one time password(OTP) has been sent to your device",
            _scaffoldKey);
        Future.delayed(new Duration(seconds: 1), () {
          Utils.removeSnackBar(_scaffoldKey);
        });
      } else {
        _removeDialog();
        Utils.showErrorDialog(context, "Error", response.sessionKey);
      }
    }).catchError((e) {
      _removeDialog();
      Utils.showErrorDialog(context, "Error", "An error occured try Again");
    });
  }

  void _countdown() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_timerSecond < 1) {
                timer.cancel();
                _isButtonDisabled = false;
              } else {
                setState(() {
                  _timerSecond = _timerSecond - 1;
                });
              }
            }));
  }

  Future _moveToHomeScreen() async {
    _showDialog("Updating your data...");
    try {
      Map<String, dynamic> updateData = Map();
      updateData['deviceId'] = Preferences.deviceId;

      FirebaseUser user = await _mAuth.signInWithEmailAndPassword(
          email: Preferences.email, password: Preferences.passWord);

      if (user != null) {
        _firestore
            .collection("Users")
            .document(user.uid)
            .updateData(updateData)
            .then((data) {
          //retrieve other details
          _firestore
              .collection("Users")
              .document(user.uid)
              .get()
              .then((dataSnapshot) {
            setState(() {
              Preferences.phoneNumber = dataSnapshot.data['phoneNumber'];
              Preferences.firstname = dataSnapshot.data['firstname'];
              Preferences.lastname = dataSnapshot.data['lastname'];
              Preferences.dob = dataSnapshot.data['DOB'];
              Preferences.profilePicture = dataSnapshot.data['ProfilePicture'];
              Preferences.signedUpForCommunity =
                  dataSnapshot.data['signedUpForCommunity'];
              Preferences.communityName = dataSnapshot.data['communityName'];
              Preferences.communityDesc = dataSnapshot.data['communityDesc'];
            });

            _removeDialog();
            _pinEditingController.text = "";
            Utils.showSnackBar("Details updated", _scaffoldKey);
            Future.delayed(new Duration(seconds: 1), () {
              Utils.removeSnackBar(_scaffoldKey);
              Navigator.of(context, rootNavigator: false).pushAndRemoveUntil(
                  CupertinoPageRoute<bool>(
                    builder: (BuildContext context) => MainDashboard(),
                  ),
                  (Route<dynamic> route) => false);
            });
          });
        });
      }
    } catch (e) {
      _removeDialog();

      Utils.showSnackBar(e.message, _scaffoldKey);
      Future.delayed(new Duration(seconds: 1), () {
        Utils.removeSnackBar(_scaffoldKey);
      });
    }
  }

  void _removeDialog() {
    Navigator.of(_dialogContext).pop();
    print("details updated");
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
