import 'package:flutter/widgets.dart';
import 'package:gofast/mainapp/components/form_components.dart';
import 'package:gofast/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PinDialog extends StatefulWidget {
  Function next;
  PinDialog({this.next});

  @override
  _PinDialogState createState() => _PinDialogState(next);
}

class _PinDialogState extends State<PinDialog> {
  final _pinFormKey = GlobalKey<FormState>();
  bool processing = false;
  String _error = "";
  Function next;
  TextEditingController pinController = new TextEditingController();

  _PinDialogState(this.next);

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
          key: _pinFormKey,
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
                        pinField(
                            textAlign: TextAlign.center,
                            maxLength: 4,
                            controller: pinController,
                            hintText: "****",
                            label: "Enter PIN")
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

                      if (_pinFormKey.currentState.validate()) {

                        await next(pinController.text.trim(), setError);
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
