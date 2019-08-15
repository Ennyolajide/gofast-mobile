import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class TransferForm extends StatefulWidget {
  @override
  _TransferFormFormState createState() {
    return _TransferFormFormState();
  }
}

class _TransferFormFormState extends State<TransferForm> {
  final _formKey = GlobalKey<FormState>();
  String _result;

  void chargeCard() async {
    setState(() {
      _result = "result";
    });
  }

  TextEditingController _accountNumberController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _textField(
              controller: _accountNumberController,
              hintText: "e.g First Bank",
              label: "Bank"),
          _textField(
              controller: _accountNumberController,
              hintText: "e.g 0123456789",
              label: "Acount Number"),
          _textField(
              controller: _accountNumberController,
              hintText: "e.g Dollars \$",
              label: "Currency"),
          _textField(
              controller: _accountNumberController,
              hintText: "e.g 1000",
              label: "Amount"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
                child: RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  chargeCard();
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text(_accountNumberController.text)));
                }
              },
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            )),
          ),
          Text('Working?: $_result\n'),
        ],
      ),
    );
  }
}

Widget _textField(
    {TextEditingController controller, String hintText, String label}) {
  return Container(
      padding: EdgeInsets.only(top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
                color: AppColors.onboardingPlaceholderText,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 10, bottom: 10),
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
