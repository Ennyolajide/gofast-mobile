import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gofast/utils/colors.dart';

Widget textField(
    {TextEditingController controller, String hintText, String label}) {
  return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
                  color: AppColors.onboardingPlaceholderText,
                  fontSize: 17,
                  fontFamily: 'MontserratSemiBold'),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
                // contentPadding: EdgeInsets.only(top: 5, bottom: 5),
                hintText: hintText,
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.buttonColor, width: 1.0),
                ),
                hintStyle: TextStyle(
                    color: AppColors.onboardingTextFieldHintTextColor),
                counterText: ''),
            validator: (value) {
              if (value.isEmpty) {
                return 'Field Cannot be empty';
              }
              return null;
            },
          ),
        ],
      ));
}

Widget numberField(
    {TextEditingController controller,
    String hintText,
    String label,
    int maxLength,
    Function validator,
    TextAlign textAlign}) {
  return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style:TextStyle(
                  color: AppColors.onboardingPlaceholderText,
                  fontSize: 17,
                  fontFamily: 'MontserratSemiBold'),
          ),
          TextFormField(
            textAlign: textAlign != null ? textAlign : null,
            maxLength: (maxLength != null ? maxLength : null),
            keyboardType: TextInputType.number,
            controller: controller,
            decoration: InputDecoration(
                // contentPadding: EdgeInsets.only(top: 5, bottom: 5),
                hintText: hintText,
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.buttonColor, width: 1.0),
                ),
                hintStyle: TextStyle(
                    color: AppColors.onboardingTextFieldHintTextColor),
                counterText: ''),
            validator: (value) {
              if (value.isEmpty) {
                return 'Field Cannot be empty';
              }
              if (validator != null) {
                return validator(value);
              }
              return null;
            },
          ),
        ],
      ));
}

Widget pinField(
    {TextEditingController controller,
    String hintText,
    String label,
    int maxLength,
    Function validator,
    TextAlign textAlign}) {
  return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
                  color: AppColors.onboardingPlaceholderText,
                  fontSize: 17,
                  fontFamily: 'MontserratSemiBold'),
          ),
          TextFormField(
            textAlign: textAlign != null ? textAlign : null,
            obscureText: true,
            maxLength: (maxLength != null ? maxLength : null),
            keyboardType: TextInputType.number,
            controller: controller,
            decoration: InputDecoration(
                // contentPadding: EdgeInsets.only(top: 5, bottom: 5),
                hintText: hintText,
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.buttonColor, width: 1.0),
                ),
                hintStyle: TextStyle(
                    color: AppColors.onboardingTextFieldHintTextColor),
                counterText: ''),
            validator: (value) {
              if (value.isEmpty) {
                return 'Field Cannot be empty';
              }
              if (validator != null) {
                return validator(value);
              }
              return null;
            },
          ),
        ],
      ));
}

Widget dateField(
    {TextEditingController controller,
    String hintText,
    String label,
    int maxLength,
    Function validator}) {
  int position = 0;
  controller.addListener(() {
    print("direct ${controller.text.length - position}");
    if (controller.text.length == 2 &&
        (controller.text.length - position > 0)) {
      print(controller.text.length - position);
      String text = "${controller.text}/";
      controller.value = controller.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    }
    position = controller.text.length;
  });

  return Container(
      padding: EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
                  color: AppColors.onboardingPlaceholderText,
                  fontSize: 17,
                  fontFamily: 'MontserratSemiBold'),
          ),
          TextFormField(
            keyboardType: TextInputType.number,
            maxLength: (maxLength != null ? maxLength : null),
            controller: controller,
            decoration: InputDecoration(
                // contentPadding: EdgeInsets.only(top: 5, bottom: 5),
                hintText: hintText,
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.buttonColor, width: 1.0),
                ),
                hintStyle: TextStyle(
                    color: AppColors.onboardingTextFieldHintTextColor),
                counterText: ''),
            validator: (value) {
              if (value.isEmpty) {
                return 'Field Cannot be empty';
              }
              if (validator != null) {
                return validator(value);
              }
              return null;
            },
          ),
        ],
      ));
}
