import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/utils/colors.dart';

const double baseHeight = 650.0;

//for handling different screen sizes
double screenAwareSize(double size, BuildContext context) {
  return size * MediaQuery.of(context).size.height / baseHeight;
}

List<String> getBanks() {
  return [
    'Access bank',
    'Access bank(Diamond)',
    'Ecobank',
    'Enterprise bank',
    'FCMB',
    'Fidelity bank',
    'First bank',
    'Citi bank',
    'Standard chartered bank',
    'GTB',
    'Heritage bank',
    'Jaiz bank',
    'Keystone bank',
    'Polaris bank',
    'Stanbic IBTC bank',
    'Sterling bank',
    'Union bank',
    'Unity bank',
    'Wema bank',
    'Zenith bank',
    'Providus bank',
    'Suntrust bank',
    'Gateway Mortgage bank'
  ];
}

class Utils {
  static BuildContext _dialogContext;

  static Widget buildLoadingBar(String text) {
    return Stack(
      key: Key('loader'),
      children: <Widget>[
        Opacity(
          opacity: 0.7,
          child: ModalBarrier(
            dismissible: false,
            color: Colors.white,
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.buttonColor)),
              SizedBox(height: 5),
              Text(
                text,
                style: TextStyle(
                    color: AppColors.onboardingPlaceholderText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        )
      ],
    );
  }

  static String getTimeAgo(int timestamp) {
    num seconds = (DateTime.now().millisecondsSinceEpoch - timestamp) / 1000;
    num interval = (seconds / 31536000).floor();
    if (interval >= 1) {
      String yearStr = interval == 1 ? 'year' : 'years';
      return "$interval $yearStr ago";
    }

    interval = (seconds / 2592000).floor();
    if (interval >= 1) {
      String month = interval == 1 ? 'month' : 'months';
      return "$interval $month ago";
    }

    interval = (seconds / 86400).floor();

    if (interval >= 1) {
      String postfix = "";
      if (interval >= 7) {
        int weeks = (interval / 7).floor();
        postfix = weeks == 1 ? 'week' : 'weeks';
        return "$weeks $postfix ago";
      } else {
        postfix = interval == 1 ? 'day' : 'days';
        return "$interval $postfix ago";
      }
    }

    interval = (seconds / 3600).floor();
    if (interval >= 1) {
      String hours = interval == 1 ? 'hour' : 'hours';
      return "$interval $hours ago";
    }

    interval = (seconds / 60).floor();
    if (interval >= 1) {
      String minutes = interval == 1 ? 'minute' : 'minutes';
      return "$interval $minutes";
    }
    return "just now";
  }

  static Future<Null> displayMessage(
    BuildContext context,
    String content, {
    String title,
    String buttonText = "Ok",
  }) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
              textTheme: Typography(platform: TargetPlatform.android)
                  .black
                  .copyWith()),
          child: new AlertDialog(
            title: new Text(title ?? ""),
            content: new Text(content ?? ""),
            actions: <Widget>[
              new FlatButton(
                child: new Text(buttonText),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void showSnackBar(String text, GlobalKey<ScaffoldState> _scaffoldKey) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(text ?? '',
          style: TextStyle(
            color: AppColors.onboardingPlaceholderText,
            fontFamily: 'MontserratBold',
            fontSize: 14,
          )),
      backgroundColor: AppColors.textFieldCursorColor,
    ));
  }

  static void removeSnackBar(GlobalKey<ScaffoldState> _scaffoldKey) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
  }

  static showToast(String message) {
//    Fluttertoast.showToast(
//        msg: message ?? '',
//        toastLength: Toast.LENGTH_SHORT,
//        gravity: ToastGravity.BOTTOM,
//        timeInSecForIos: 2,
//        backgroundColor: AppColors.goldColor,
//        textColor: Colors.white,
//        fontSize: 16.0);
  }

  static bool validateEmail(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(email);
  }

  static void showErrorDialog(
      BuildContext context, String title, String message) {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          return new AlertDialog(
            title: new Text(
              title ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(
                    message ?? '',
                    style: TextStyle(fontSize: 15, fontFamily: 'Montserrat'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return new CupertinoAlertDialog(
              title: Text(
                title ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(
                      message ?? '',
                      style: TextStyle(fontSize: 15, fontFamily: 'Montserrat'),
                    )
                  ],
                ),
              ));
        }
      },
    );
  }

  static void showMessageDialog(
      BuildContext context, String title, String message) {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          return new AlertDialog(
            title: new Text(
              title ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(
                    message ?? '',
                    style: TextStyle(fontSize: 15, fontFamily: 'Montserrat'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return new CupertinoAlertDialog(
              title: Text(
                title ?? '',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(
                      message ?? '',
                      style: TextStyle(fontSize: 15, fontFamily: 'Montserrat'),
                    )
                  ],
                ),
              ));
        }
      },
    );
  }

  static void showNormalMessage(
      BuildContext context, String title, String message) {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          return new AlertDialog(
            title: new Text(
              title ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(message ?? '',
                      style: TextStyle(fontSize: 15, fontFamily: 'Montserrat')),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                  'OK',
                  style: TextStyle(
                      color: AppColors.buttonColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        } else {
          return new CupertinoAlertDialog(
            title: Text(
              title ?? '',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text(message ?? '',
                      style: TextStyle(fontSize: 15, fontFamily: 'Montserrat'))
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                  'OK',
                  style: TextStyle(
                      color: AppColors.buttonColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      },
    );
  }

  static void showErrorDialogWithRetry(BuildContext context, String title,
      String message, VoidCallback callback) {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          return new AlertDialog(
              title: new Text(title ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(message ?? '', style: TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('Retry',
                      style: TextStyle(
                          color: AppColors.buttonColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        } else {
          return new CupertinoAlertDialog(
              title: Text(title ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(message ?? '', style: TextStyle(fontSize: 15))
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    'Retry',
                    style: TextStyle(
                        color: AppColors.buttonColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        }
      },
    );
  }

  static void removeLoadingDialog() {
    Navigator.of(_dialogContext).pop();
  }

  static void showLoadingDialog(String message, BuildContext context) {
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
