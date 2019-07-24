import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/mainapp/maindashboard.dart';
import 'package:gofast/onboarding/bankAccountSetup/addbank.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class DashBoardIntro extends StatefulWidget {
  @override
  _DashBoardIntroState createState() => _DashBoardIntroState();
}

class _DashBoardIntroState extends State<DashBoardIntro> {
  @override
  void initState() {
    _initPreferences();
    super.initState();
  }

  void _initPreferences() {
    Preferences.init().then((prefs) {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            buildHeaderSection(),
            buildWelcomeMessage(),
            buildTextSection(),
            buildButtonSection()
          ],
        ),
      ),
    );
  }

  Widget buildHeaderSection() {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.only(top: 10),
            child: Image.asset(
              'assets/vacation.png',
              height: MediaQuery.of(context).size.height / 2,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 5, right: 27, top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              BackButton(color: AppColors.buttonColor),
              Image.asset('assets/gofast_gold.png', width: 122, height: 24),
            ],
          ),
        )
      ],
    );
  }

  Widget buildWelcomeMessage() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(25, context)),
      alignment: Alignment.center,
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            TextSpan(
                text: 'Hi',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'MontserratSemiBold',
                    color: AppColors.onboardingPlaceholderText)),
            TextSpan(
                text: ' ${Preferences.firstname}, ' ?? ', ',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'MontserratSemiBold',
                    color: AppColors.textColor)),
            TextSpan(
                text: 'welcome to GoFast',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'MontserratSemiBold',
                    color: AppColors.onboardingPlaceholderText))
          ])),
    );
  }

  Widget buildTextSection() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: 28, vertical: screenAwareSize(32, context)),
      child: Text(
        'Gofast app helps people transfer money from any of their bank accounts to any another bank account. ',
        style: TextStyle(
          color: AppColors.dashboardTextDescriptionColor,
          letterSpacing: 0.71,
          height: 1.2,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget buildButtonSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          splashColor: AppColors.goldColor,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16, vertical: screenAwareSize(16, context)),
            child: Text(
              ' Add bank ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          color: AppColors.buttonColor,
          onPressed: () {
            Navigator.of(context, rootNavigator: false).push(
              CupertinoPageRoute<bool>(
                builder: (BuildContext context) => AddAccount(
                      fromOnboarding: true,
                    ),
              ),
            );
          },
        ),
        SizedBox(width: 16),
        FlatButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: AppColors.buttonColor, width: 1)),
          splashColor: AppColors.buttonColor,
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: screenAwareSize(16, context), horizontal: 16),
            child: Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
          ),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context, rootNavigator: false).pushAndRemoveUntil(
                CupertinoPageRoute<bool>(
                  builder: (BuildContext context) => MainDashboard(),
                ),
                (Route<dynamic> route) => false);
          },
        )
      ],
    );
  }
}
