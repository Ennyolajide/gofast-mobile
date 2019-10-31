import 'package:flutter/widgets.dart';
import 'package:gofast/mainapp/components/form_components.dart';
import 'package:gofast/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class OTPDialog extends StatefulWidget {
  Function next;
  OTPDialog({this.next});

  @override
  _OTPDialogState createState() => _OTPDialogState(next);
}

class _OTPDialogState extends State<OTPDialog> {
  final _otpFormKey = GlobalKey<FormState>();
  bool processing = false;
  String _error = "";
  Function next;
  TextEditingController otpController = new TextEditingController();

  _OTPDialogState(this.next);

  void setError(error) {
    setState(() {
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(25),
      // title: const Text('Amount'),
      children: <Widget>[
        Form(
          key: _otpFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.lock,
                size: 30.0,
              ),
              Container(
                  padding: EdgeInsets.only(top: 25),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        numberField(
                            textAlign: TextAlign.center,
                            maxLength: 5,
                            controller: otpController,
                            hintText: "*****",
                            label: "Enter OTP sent to your mobile phone")
                      ])),
              SizedBox(
                  width: double.infinity,
                  child: MaterialButton(
                    color: processing ? Colors.grey : AppColors.buttonColor,
                    onPressed: () async {
                      setState(() {
                        processing = true;
                        _error = "";
                      });

                      if (_otpFormKey.currentState.validate()) {

                        await next(otpController.text.trim(), setError);
                      }

                      setState(() {
                        processing = false;
                      });
                    },
                    child: Text(
                      processing ? "Processing.." : "Continue",
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
                  Text(
                      _error,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    )
            ],
          ),
        )
      ],
    );
    ;
  }
}
