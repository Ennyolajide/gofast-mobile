import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:gofast/mainapp/maindashboard.dart';
import 'package:gofast/onboarding/login.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  TargetPlatform _platform;
  FirebaseAuth mAuth = FirebaseAuth.instance;
  AnimationController _animationController;
  Animation animation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: Duration(seconds: 6), vsync: this);
    animation = new CurvedAnimation(
        parent: _animationController, curve: Curves.bounceInOut);
    _animationController.forward();
    _animationController.addListener(() {
      setState(() {});
    });
    _initPreferences();

    setUpTimer();
    buildStatusBar();
  }

  Future buildStatusBar() async {
    await FlutterStatusbarcolor.setStatusBarColor(AppColors.textColor);
  }

  void _initPreferences() {
    Preferences.init().then((prefs) {
//      getDeviceId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.buttonColor,
        body: Center(
            child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/gofast_logo_white.png',
                fit: BoxFit.cover,
                width: animation.value * 101,
                height: animation.value * 90,
              ),
              SizedBox(height: animation.value * 15),
              Image.asset(
                'assets/gofast_splash.png',
                fit: BoxFit.cover,
                width: animation.value * 130,
                height: animation.value * 30,
              ),
            ],
          ),
        )));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void setUpTimer() {
    Timer(Duration(seconds: 6), () {
      mAuth.currentUser().then((currentUser) {
        if (currentUser != null) {
          Navigator.of(context, rootNavigator: false).pushReplacement(
            CupertinoPageRoute<bool>(
              builder: (BuildContext context) => MainDashboard(),
            ),
          );
        } else {
          Navigator.of(context, rootNavigator: false).pushReplacement(
            CupertinoPageRoute<bool>(
              builder: (BuildContext context) => Login(),
            ),
          );
        }
      });
    });
  }

  Future<Null> getDeviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String _deviceId;
    String _model;
    bool _isPhysicalDevice;
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      _deviceId = build.id;
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
}
