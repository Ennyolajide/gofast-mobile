import 'package:flutter/material.dart';
import 'package:gofast/utils/colors.dart';

class AppTheme {
  static ThemeData appTheme = ThemeData(
    primarySwatch: Colors.orange,
    // Colors.red,
    fontFamily: "Montserrat", // "Work Sans",
    primaryColor: const Color(0xFFFFAB40),
//    primaryColor: Colors.white,
    //
    textTheme: Typography.blackMountainView
        .copyWith(button: Typography.whiteMountainView.button),
    accentColor: AppColors.buttonColor,
    backgroundColor: Colors.black,
    scaffoldBackgroundColor: Colors.white,
    buttonColor: AppColors.buttonColor,
    hintColor: AppColors.onboardingTextFieldBorder,
    canvasColor: Colors.white,
    dialogBackgroundColor: Colors.white,
    brightness: Brightness.light,
    cursorColor: AppColors.textFieldCursorColor,
    inputDecorationTheme: InputDecorationTheme(
//      fill  Color: Colors.white10,

      filled: false,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent, width: 1.0),
      ),
      border: UnderlineInputBorder(
          borderSide: BorderSide(
              color: AppColors
                  .onboardingTextFieldBorder)), // OutlineInputBorder(),
    ),
    unselectedWidgetColor:
        Colors.grey, // used for checkbox/switchbox/radiobutton
    // dialogBackgroundColor:  const Color(0xFF2F444E),
    // indicatorColor: Colors.white,
    //canvasColor: const Color(0xFF5F138D),
    dialogTheme: DialogTheme(
      contentTextStyle: TextStyle(color: Colors.black),
    ),
  );
}
