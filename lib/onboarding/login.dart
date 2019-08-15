import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/config/CONFIG.dart';
import 'package:gofast/mainapp/maindashboard.dart';
import 'package:gofast/network/apiservice.dart';
import 'package:gofast/network/request/sendotprequest.dart';
import 'package:gofast/onboarding/registration/forgotpassword.dart';
import 'package:gofast/onboarding/registration/otpEntry.dart';
import 'package:gofast/onboarding/registration/phoneNumberEntry.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var passwordVisible = true;
  bool _autoValidate = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  bool _isIos;
  BuildContext _dialogContext;
  bool _isShowing = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _fireStore = Firestore.instance;

  @override
  void initState() {
    _initPreferences();
    super.initState();
  }

  void _initPreferences() {
    Preferences.init().then((prefs) {
      getDeviceId();
    });
  }

  Future<Null> getDeviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String _deviceId;
    String _model;
    bool _isPhysicalDevice;
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      _deviceId = build.androidId;
      _model = build.model;
      _isPhysicalDevice = build.isPhysicalDevice;
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      _deviceId = data.identifierForVendor; //UUID for iOS
      _isPhysicalDevice = data.isPhysicalDevice;
      _model = data.model;
    }

    Preferences.deviceId = _deviceId;
    Preferences.isPhysicalDevice = _isPhysicalDevice;

    print("deviceId -----> ${Preferences.deviceId}");
    print("is physical device -----> ${Preferences.isPhysicalDevice}");
    print("model is -----> ${_model}");
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            body: Stack(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 15, right: 27, top: 30),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Image.asset('assets/gofast_gold.png',
                                width: 122, height: 24),
                          ],
                        ),
                      ),
                      SizedBox(height: screenAwareSize(130, context)),
                      _buildEmailTextContainer(),
                      SizedBox(height: screenAwareSize(15, context)),
                      _buildEmailAddressTextField(),
                      buildPasswordtextContainer(),
                      SizedBox(height: screenAwareSize(15, context)),
                      buildPasswordTextField(),
                      buildLoginButton(),
                      buildRegisterLink(),
                      _buildForgotPasswordLink(),
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

  Widget buildPasswordtextContainer() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(32, context), left: 27),
      child: Text('Enter your password',
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
      child: TextFormField(
        style: TextStyle(fontSize: 16),
        maxLines: null,
        controller: _passwordController,
        keyboardType: TextInputType.text,
        obscureText: passwordVisible,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 12, left: 12),
          labelText: 'Password',
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: AppColors.onboardingTextFieldHintTextColor.withOpacity(0.2),
          ),
          hasFloatingPlaceholder: false,
          labelStyle:
              TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
          suffixIcon: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              !passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).buttonColor,
            ),
            onPressed: () {
              setState(() {
                passwordVisible = !passwordVisible;
              });
            },
          ),
        ),
        validator: (val) {
          if (val.isEmpty) {
            return 'Field is required';
          } else if (val.length < 8) {
            return 'Password must be at least 8 characters';
          }
        },
        autovalidate: _autoValidate,
      ),
    );
  }

  Widget buildLoginButton() {
    return Container(
      margin: EdgeInsets.only(
          top: screenAwareSize(32.2, context), left: 19, right: 19),
      child: RaisedButton(
        onPressed: () {
          _validateLogin();
        },
        color: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Login',
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

  Widget buildRegisterLink() {
    return Container(
      margin: EdgeInsets.only(
        top: screenAwareSize(22, context),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Don\'t have an Account ?',
            style: TextStyle(
                color: Colors.grey.shade700, fontSize: 15, letterSpacing: 0.23),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context, rootNavigator: false).push(
                CupertinoPageRoute<bool>(
                  builder: (BuildContext context) =>
                      PhoneNumberEntry("signUpType"),
                ),
              );
            },
            child: Text(
              ' Create Account',
              style: TextStyle(
                  color: AppColors.onboardingLoginColor,
                  fontSize: 15,
                  fontFamily: 'MontserratBold',
                  letterSpacing: 0.63),
            ),
          )
        ],
      ),
    );
  }

  void _validateLogin() {
    setState(() {
      _autoValidate = true;
    });
    final form = _formKey.currentState;
    if (form.validate()) {
      _signInUser();
    }
  }

  Future _signInUser() async {
    _showDialog("Please wait");
    try {
      FirebaseUser user = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      if (user != null) {
        Preferences.email = _emailController.text.trim();
        Preferences.passWord = _passwordController.text.trim();

        _fireStore
            .collection("Users")
            .document(user.uid)
            .get()
            .then((dataSnapshot) {
          // String onlineDeviceId = dataSnapshot.data['deviceId'];
          // print("Online user id=======> $onlineDeviceId");
          // print("current user id=======> ${user.uid}");

          if (dataSnapshot.data != null &&
              dataSnapshot.data['deviceId'] == Preferences.deviceId) {
            Preferences.phoneNumber = dataSnapshot.data['phoneNumber'];
            Preferences.firstname = dataSnapshot.data['firstname'];
            Preferences.lastname = dataSnapshot.data['lastname'];
            Preferences.dob = dataSnapshot.data['DOB'];
            Preferences.profilePicture = dataSnapshot.data['ProfilePicture'];
            Preferences.signedUpForCommunity =
                dataSnapshot.data['signedUpForCommunity'];
            Preferences.communityName = dataSnapshot.data['communityName'];
            Preferences.communityDesc = dataSnapshot.data['communityDesc'];

            _removeDialog();

            Utils.showSnackBar("Login successful", _scaffoldKey);
            Future.delayed(new Duration(seconds: 1), () {
              Utils.removeSnackBar(_scaffoldKey);
              Navigator.of(context, rootNavigator: false).pushAndRemoveUntil(
                  CupertinoPageRoute<bool>(
                    builder: (BuildContext context) => MainDashboard(),
                  ),
                  (Route<dynamic> route) => false);
            });
          } else {
            _removeDialog();
            _handleDeviceChange();
          }
        });
      }
    } catch (e) {
      print("Error message ocured");
      _removeDialog();

      Utils.showSnackBar(e.message, _scaffoldKey);
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

  Future<Null> _handleDeviceChange() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          return new AlertDialog(
            title: new Text(
              'New Device Found!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(
                    'Do you want to replace your old device with this device?',
                    style: TextStyle(fontSize: 16),
                  ),
                  new Text(
                      'By clicking yes, you will be required to enter an OTP.',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('YES'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _sendOtpToUser();
                },
              ),
              new FlatButton(
                child: new Text('NO'),
                onPressed: () {
                  _auth.signOut();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        } else {
          return new CupertinoAlertDialog(
              title: Text("New Device Found!",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(
                        'Do you want to replace your old device with this device?',
                        style: TextStyle(fontSize: 16)),
                    new Text(
                        'By clicking yes, you will be required to enter an OTP.',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              actions: <Widget>[
                CupertinoButton(
                    child: Text("YES"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _sendOtpToUser();
                    }),
                CupertinoButton(
                    child: Text("NO"),
                    onPressed: () {
                      _auth.signOut();
                      Navigator.of(context).pop();
                    })
              ]);
        }
      },
    );
  }

  void _sendOtpToUser() {
    _showDialog("Sending otp...");
    //send otp at this point

    _auth.currentUser().then((currentuser) {
      if (currentuser != null) {
        _fireStore
            .collection("Users")
            .document(currentuser.uid)
            .get()
            .then((snapshot) {
          String phoneNumber = snapshot.data['phoneNumber'];
          print("phonumber retrieve from fb is ---> $phoneNumber");

          //send otp to the phonenumber at this point with 2factor
          NetworkService networkService = new NetworkService();
          SendOtpRequest request =
              new SendOtpRequest(CONFIG.TWOFACTOR_API_KEY, '$phoneNumber');
          networkService.sendOtp(request).then((response) {
            if (response.status == "Success") {
              _removeDialog();
              Navigator.of(context, rootNavigator: false).push(
                CupertinoPageRoute<bool>(
                  builder: (BuildContext context) => OtpSetup(
                        type: "LoginChange",
                        phoneNumber: "$phoneNumber",
                        session: response.sessionKey,
                      ),
                ),
              );
            } else {
              _removeDialog();
              Utils.showErrorDialog(context, "Error", response.sessionKey);
            }
          }).catchError((e) {
            _removeDialog();
            Utils.showErrorDialog(
                context, "Error", "An error occured, try Again");
//
          });
        });
      }
    });
  }

  Widget _buildForgotPasswordLink() {
    return Container(
      margin: EdgeInsets.only(
        top: screenAwareSize(17, context),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context, rootNavigator: false).push(
            CupertinoPageRoute<bool>(
              builder: (BuildContext context) => ForgotPassword(),
            ),
          );
        },
        child: Text(
          'Forgot password?',
          style: TextStyle(
            color: AppColors.buttonColor,
            fontSize: 15,
            fontFamily: 'MontserratBold',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
