import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/config/CONFIG.dart';
import 'package:gofast/network/apiservice.dart';
import 'package:gofast/network/request/sendotprequest.dart';
import 'package:gofast/onboarding/registration/otpEntry.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class PhoneNumberEntry extends StatefulWidget {
  String _type;

  PhoneNumberEntry(this._type);

  @override
  _PhoneNumberEntryState createState() => _PhoneNumberEntryState();
}

class _PhoneNumberEntryState extends State<PhoneNumberEntry> {
  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('90');
  bool _autoValidate = false;
  TextEditingController _phoneNumberController = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  String _phoneNumber;
  BuildContext _dialogContext;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

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
            'assets/smartphone.png',
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
              buildPhoneNumberTextContainer(),
              SizedBox(height: screenAwareSize(20, context)),
              buildPhoneNumberTextField(),
              SizedBox(height: screenAwareSize(10, context)),
              buildTextContainer(),
              buildNextButton()
            ],
          ),
        ),
      ],
    ));
  }

  Widget buildPhoneNumberTextContainer() {
    return Container(
      margin: EdgeInsets.only(top: screenAwareSize(20, context), left: 21),
      child: Text('Enter your phone number',
          style: TextStyle(
              color: AppColors.onboardingPlaceholderText,
              fontSize: 19,
              fontFamily: 'MontserratBold',
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDialogItem(Country country) => Container(
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(width: 4.0),
            Text("+${country.phoneCode}"),
            SizedBox(width: 3.0),
          ],
        ),
      );

  Widget buildPhoneNumberTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 19),
      child: Form(
        key: _formKey,
        child: TextFormField(
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 16),
          maxLength: 10,
          maxLines: null,
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.only(bottom: 12, left: 12),
            labelText: 'Phone number',
            prefixText: '+234',
            prefixStyle: TextStyle(fontSize: 16),
            prefixIcon: Icon(Icons.phone_android,
                color: AppColors.onboardingTextFieldHintTextColor
                    .withOpacity(0.2)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.buttonColor, width: 1.0),
            ),
            hasFloatingPlaceholder: false,
            labelStyle:
                TextStyle(color: AppColors.onboardingTextFieldHintTextColor),
          ),
          validator: (val) {
            if (val.isEmpty) {
              return 'Phone number is required';
            } else if (val.length != 10) {
              return 'Invalid phone number length';
            }
          },
          onSaved: (val) {
            _phoneNumber = val;
          },
          autovalidate: _autoValidate,
          controller: _phoneNumberController,
        ),
      ),
    );
  }

  Widget buildTextContainer() {
    return Container(
      margin: EdgeInsets.only(
          left: 19, right: 19, top: screenAwareSize(10, context)),
      child: Text(
          'Make sure you enter your phone number connected with your bank account, we will send a one time password(OTP) to your phone.',
          style: TextStyle(
              color: AppColors.onboardingTextFieldHintTextColor, fontSize: 14)),
    );
  }

  Widget buildNextButton() {
    return Container(
      margin: EdgeInsets.only(
          left: 19, right: 19, top: screenAwareSize(120, context)),
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

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
            data: Theme.of(context).copyWith(primaryColor: AppColors.goldColor),
            child: CountryPickerDialog(
                titlePadding: EdgeInsets.all(8.0),
                searchCursorColor: AppColors.goldColor,
                searchInputDecoration: InputDecoration(hintText: 'Search...'),
                isSearchable: true,
                title: Text(
                  'Select your phone number code',
                  style: TextStyle(fontSize: 16),
                ),
                onValuePicked: (Country country) =>
                    setState(() => _selectedDialogCountry = country),
                itemBuilder: _buildDialogItem)),
      );

  void _submit() {
    setState(() {
      _autoValidate = true;
    });
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      print("phonenumber => $_phoneNumber");
      //send otp here
      _showDialog("Sending otp..");
      NetworkService networkService = new NetworkService();
      SendOtpRequest request =
          new SendOtpRequest(CONFIG.TWOFACTOR_API_KEY, '+234$_phoneNumber');
      networkService.sendOtp(request).then((response) {
        if (response.status == "Success") {
          _removeDialog();
          Navigator.of(context, rootNavigator: false).push(
            CupertinoPageRoute<bool>(
              builder: (BuildContext context) => OtpSetup(
                    type: widget._type,
                    phoneNumber: "+234$_phoneNumber",
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
        Utils.showErrorDialog(context, "Error", "An error occured, try Again");
//
      });
    }
  }

  void _removeDialog() {
    Navigator.of(_dialogContext).pop();
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
