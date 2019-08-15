import 'package:flutter/widgets.dart';
import 'package:gofast/mainapp/components/form_components.dart';
import 'package:gofast/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AVSDialog extends StatefulWidget {
  Function next;
  AVSDialog({this.next});

  @override
  _AVSDialogState createState() => _AVSDialogState(next);
}

class _AVSDialogState extends State<AVSDialog> {
  final _AVSFormKey = GlobalKey<FormState>();
  bool processing = false;
  String _error = "";
  Function next;
  TextEditingController billingzipController = new TextEditingController();
  TextEditingController billingcityController = new TextEditingController();
  TextEditingController billingaddressController = new TextEditingController();
  TextEditingController billingstateController = new TextEditingController();
  TextEditingController billingcountryController = new TextEditingController();

  _AVSDialogState(this.next);

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
          key: _AVSFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.lock,
                    size: 30.0,
                  ),
                ],
              ),
              Container(
                  padding: EdgeInsets.only(top: 25),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        textField(
                            controller: billingzipController,
                            hintText: "e.g 100011",
                            label: "Enter Billing Zip"),
                        textField(
                            controller: billingaddressController,
                            hintText: "e.g 100011",
                            label: "Enter Billing Address"),
                        textField(
                            controller: billingcityController,
                            hintText: "e.g 100011",
                            label: "Enter Billing City"),
                        textField(
                            controller: billingstateController,
                            hintText: "e.g 100011",
                            label: "Enter Billing State"),
                        textField(
                            controller: billingcountryController,
                            hintText: "e.g 100011",
                            label: "Enter Billing Country"),
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

                      if (_AVSFormKey.currentState.validate()) {
                        Map<String, dynamic> data = new Map();
                        data["billingzip"] = billingzipController.text.trim();
                        data["billingcity"] = billingcityController.text.trim();
                        data["billingaddress"] =
                            billingaddressController.text.trim();
                        data["billingstate"] =
                            billingstateController.text.trim();
                        data["billingcountry"] =
                            billingcountryController.text.trim();

                        await next(data, setError);
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
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              )
            ],
          ),
        )
      ],
    );
  }
}
