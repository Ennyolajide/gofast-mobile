import 'package:flutter/material.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
      backgroundColor: AppColors.settingsBgColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: AppColors.buttonColor,
        title: Text('About',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        children: <Widget>[
//          _buildNotification(),
//          SizedBox(height: 30),
          _buildAboutGofast()
        ],
      ),
    ));
  }

  Widget _buildNotification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 20),
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Text(
            'NOTIFICATION',
            style: TextStyle(
                color: AppColors.onboardingPlaceholderText,
                fontSize: 16,
                fontFamily: 'MontserratBold'),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(
                      color: AppColors.onboardingTextFieldBorder, width: 1),
                  bottom:
                      BorderSide(color: AppColors.onboardingTextFieldBorder))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Divider(height: 0.0),
//              Padding(
//                padding: const EdgeInsets.symmetric(vertical: 15),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: <Widget>[
//                    Text('After Each Transaction',
//                        style: TextStyle(
//                            color: AppColors.onboardingPlaceholderText,
//                            fontSize: 15,
//                            fontFamily: 'MontserratSemiBold',
//                            fontWeight: FontWeight.bold)),
//                    Switch(
//                      value: Preferences.notificationAfterEachTransaction,
//                      onChanged: (value) {
//                        setState(() {
//                          Preferences.notificationAfterEachTransaction = value;
//                        });
//                      },
//                      activeColor: AppColors.buttonColor,
//                    )
//                  ],
//                ),
//              ),
              Divider(height: 0.0),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('After transfer success',
                        style: TextStyle(
                            color: AppColors.onboardingPlaceholderText,
                            fontSize: 15,
                            fontFamily: 'MontserratSemiBold',
                            fontWeight: FontWeight.bold)),
                    Switch(
                      value: Preferences.notificationAfterTransactionSuccess,
                      onChanged: (value) {
                        Preferences.notificationAfterTransactionSuccess = value;
                      },
                      activeColor: AppColors.buttonColor,
                    )
                  ],
                ),
              ),
              Divider(height: 0.0),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAboutGofast() {
    return InkWell(
      onTap: () {
        showAboutDialog(
            context: context,
            applicationName: "Gofast",
            applicationVersion: "1.0",
            applicationIcon: Image.asset(
              'assets/app_logo.png',
              fit: BoxFit.cover,
              width: 60,
              height: 60,
            ),
            children: [
              Text(
                  'Gofast is about a unique app that incorporate business, fun and many other interesting features that are geared towards easing the daily transaction of anybody; either individual or corporate organization.'),
              Text(
                  'Gofast app helps people transfer money from any of their bank accounts to any other bank account.')
            ]);
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(
                    color: AppColors.onboardingTextFieldBorder, width: 1),
                bottom:
                    BorderSide(color: AppColors.onboardingTextFieldBorder))),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('About GoFast',
                style: TextStyle(
                    color: AppColors.onboardingPlaceholderText,
                    fontFamily: 'MontserratSemiBold',
                    fontSize: 16)),
            Icon(
              Icons.chevron_right,
              color: AppColors.buttonColor,
            )
          ],
        ),
      ),
    );
  }
}
