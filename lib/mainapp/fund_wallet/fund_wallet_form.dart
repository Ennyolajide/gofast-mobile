import 'dart:convert';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gofast/config/urlconstants.dart';
import 'package:gofast/mainapp/fund_wallet/avs_dialog.dart';
import 'package:gofast/mainapp/fund_wallet/otp_dialog.dart';
import 'package:gofast/mainapp/fund_wallet/pin_dialog.dart';
import 'package:gofast/mainapp/maindashboard.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';
import 'package:credit_card_number_validator/credit_card_number_validator.dart';
import 'package:gofast/network/apiservice.dart';
import 'package:http/http.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class FundWalletForm extends StatefulWidget {
  @override
  _FundWalletFormFormState createState() {
    return _FundWalletFormFormState();
  }
}

class _FundWalletFormFormState extends State<FundWalletForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountFormKey = GlobalKey<FormState>();

  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  StreamSubscription<String> _onUrlChanged;

  Firestore _firestore = Firestore.instance;
  FirebaseAuth _mAuth = FirebaseAuth.instance;
  FirebaseUser _currentUser;
  bool _uidLoaded = false;

  String card = "";
  String _error = "";
  bool processing = false;
  // InAppWebViewController webView;
  String url = "";
  double progress = 0;

  String currency = 'NGN';
  TextEditingController _cardNumberController;
  TextEditingController _cvvController;
  TextEditingController _expiresController;
  TextEditingController _amountController;

  void initiateTransaction(Map<String, dynamic> details) async {
    Map<String, dynamic> data = Map();

    data["status"] = "pending";
    data["user_id"] = _currentUser.uid;
    data["type"] = details["type"];
    data["amount"] = details["amount"];
    _firestore.collection("Transactions").document(details["id"]).setData(data);
  }

  void cancelTransaction(id) async {}

  void _charge() async {
    setState(() {
      processing = true;
      _error = "";
    });

    try {
      String txtRef =
          "MAR_${_cardNumberController.text.trim()}_${DateTime.now()}";

      NetworkService networkService = new NetworkService();
      print("User ${_currentUser.email}");
      Map<String, dynamic> details = Map();
      details["id"] = txtRef;
      details["amount"] = _amountController.text.trim();
      details["type"] = "FUND_WALLET";
      initiateTransaction(details);
      Response res = await networkService.chargeCard(
          cardNo: _cardNumberController.text.trim(),
          cvv: _cvvController.text,
          expMonth: _expiresController.text.substring(0, 2),
          expYear: _expiresController.text.substring(3),
          currency: currency,
          country: "NG",
          amount: _amountController.text.trim(),
          txtRef: txtRef,
          email: _currentUser.email);

      print("res: ${res.body}");
      dynamic body = json.decode(res.body);
      if (body["status"] == "error") {
        setState(() {
          _error = body["message"];
        });
      }

      if (body["status"] == "success") {
        if (body["message"] == "AUTH_SUGGESTION") {
          switch (body["data"]["suggested_auth"]) {
            case "PIN":
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    PinDialog(next: (pin, setError) async {
                      print("pin :: $pin");
                      Response res = await networkService.chargeCard(
                          cardNo: _cardNumberController.text.trim(),
                          cvv: _cvvController.text,
                          expMonth: _expiresController.text.substring(0, 2),
                          expYear: _expiresController.text.substring(3),
                          currency: currency,
                          country: "NG",
                          pin: pin,
                          suggested_auth: "PIN",
                          amount: _amountController.text.trim(),
                          txtRef: txtRef,
                          email: _currentUser.email);

                      print("2 ${res.body}");
                      dynamic body = json.decode(res.body);
                      if (body["status"] == "error") {
                        setError(body["message"]);
                      }
                      if (body["data"]["chargeResponseCode"] == "00") {
                        Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => SimpleDialog(
                                  contentPadding: EdgeInsets.all(25),
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Icon(
                                        Icons.done_outline,
                                        color: Colors.green,
                                        size: 30.0,
                                      ),
                                    ),
                                    Center(
                                      child:
                                          Text("Transaction was Successfull"),
                                    ),
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context,
                                                  rootNavigator: false)
                                              .push(CupertinoPageRoute<bool>(
                                                  builder:
                                                      (BuildContext context) =>
                                                          MainDashboard()));
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 40),
                                          child: Text(
                                            "Okay",
                                            style: TextStyle(
                                                color: AppColors.buttonColor),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ));
                      } else if (body["data"]["chargeResponseCode"] == "02") {
                        Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => OTPDialog(
                                  next: (otp, setError) async {
                                    Response otpRes =
                                        await networkService.validateCharge(
                                      transaction_reference: body["data"]
                                          ["flwRef"],
                                      otp: otp,
                                    );

                                    dynamic data = json.decode(otpRes.body);
                                    if (data["data"]["data"]["responsecode"] ==
                                        "00") {
                                      Navigator.of(context).pop();
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              SimpleDialog(
                                                contentPadding:
                                                    EdgeInsets.all(25),
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.all(20),
                                                    child: Icon(
                                                      Icons.done_outline,
                                                      color: Colors.green,
                                                      size: 30.0,
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                        "Transaction was Successfull"),
                                                  ),
                                                  Center(
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    false)
                                                            .push(CupertinoPageRoute<
                                                                    bool>(
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    MainDashboard()));
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 20,
                                                                horizontal: 40),
                                                        child: Text(
                                                          "Okay",
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .buttonColor),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ));
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              SimpleDialog(
                                                contentPadding:
                                                    EdgeInsets.all(25),
                                                children: <Widget>[
                                                  Padding(
                                                    padding: EdgeInsets.all(20),
                                                    child: Icon(
                                                      Icons.error_outline,
                                                      color: Colors.red,
                                                      size: 30.0,
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                        "Transaction was not successfull"),
                                                  ),
                                                  Center(
                                                    child: InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 20,
                                                                horizontal: 40),
                                                        child: Text(
                                                          "retry",
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .buttonColor),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ));
                                    }
                                  },
                                ));
                      }
                    }),
              );
              break;
            case "NOAUTH_INTERNATIONAL":
              showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      AVSDialog(next: (data, setError) async {
                        Response res = await networkService.chargeCard(
                            cardNo: _cardNumberController.text.trim(),
                            cvv: _cvvController.text,
                            expMonth: _expiresController.text.substring(0, 2),
                            expYear: _expiresController.text.substring(3),
                            currency: currency,
                            country: "NG",
                            suggested_auth: "NOAUTH_INTERNATIONAL",
                            billingzip: data["billingzip"],
                            billingcity: data["billingcity"],
                            billingaddress: data["billingaddress"],
                            billingstate: data["billingstate"],
                            billingcountry: data["billingcountry"],
                            amount: _amountController.text.trim(),
                            txtRef: txtRef,
                            email: _currentUser.email);

                        print("2 ${res.body}");
                        dynamic body = json.decode(res.body);
                        if (body["status"] == "error") {
                          setError(body["message"]);
                        }
                        if (body["data"]["chargeResponseCode"] == "00") {
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => SimpleDialog(
                                    contentPadding: EdgeInsets.all(25),
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Icon(
                                          Icons.done_outline,
                                          color: Colors.green,
                                          size: 30.0,
                                        ),
                                      ),
                                      Center(
                                        child:
                                            Text("Transaction was Successfull"),
                                      ),
                                      Center(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context,
                                                    rootNavigator: false)
                                                .push(CupertinoPageRoute<bool>(
                                                    builder: (BuildContext
                                                            context) =>
                                                        MainDashboard()));
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 40),
                                            child: Text(
                                              "Okay",
                                              style: TextStyle(
                                                  color: AppColors.buttonColor),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ));
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => SimpleDialog(
                                    contentPadding: EdgeInsets.all(25),
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                          size: 30.0,
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                            "Transaction was not successfull"),
                                      ),
                                      Center(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 40),
                                            child: Text(
                                              "retry",
                                              style: TextStyle(
                                                  color: AppColors.buttonColor),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ));
                        }
                      }));
              break;
          }
        } else if (body["message"] == "V-COMP") {
          switch (body["data"]["authModelUsed"]) {
            case "VBVSECURECODE":
              Navigator.of(context, rootNavigator: false).push(
                CupertinoPageRoute<bool>(
                    builder: (BuildContext context) => WebviewScaffold(
                          url: body["data"]["authurl"],
                          appBar: new AppBar(
                            title: new Text(
                              "Payment Verification",
                              style: TextStyle(color: Colors.white),
                            ),
                            actions: <Widget>[
                              InkWell(
                                child: Icon(Icons.refresh),
                                onTap: () {
                                  flutterWebviewPlugin
                                      .reloadUrl(body["data"]["authurl"]);
                                  // flutterWebviewPlugin.reloadUrl("any link");
                                },
                              ),
                            ],
                          ),
                          withJavascript: true,
                          hidden: true,
                          initialChild: Container(
                            child: const Center(
                              child: Text('Waiting.....'),
                            ),
                          ),
                        )),
              );
              // flutterWebviewPlugin.launch(body["data"]["authurl"],);
              break;
            case "ACCESS_OTP":
              showDialog(
                  context: context,
                  builder: (BuildContext context) => OTPDialog(
                        next: (otp, setError) async {
                          Response otpRes = await networkService.validateCharge(
                            transaction_reference: body["data"]["flwRef"],
                            otp: otp,
                          );

                          dynamic data = json.decode(otpRes.body);
                          if (data["data"]["data"]["responsecode"] == "00") {
                            Navigator.of(context).pop();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => SimpleDialog(
                                      contentPadding: EdgeInsets.all(25),
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Icon(
                                            Icons.done_outline,
                                            color: Colors.green,
                                            size: 30.0,
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                              "Transaction was Successfull"),
                                        ),
                                        Center(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context,
                                                      rootNavigator: false)
                                                  .push(
                                                      CupertinoPageRoute<bool>(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              MainDashboard()));
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20, horizontal: 40),
                                              child: Text(
                                                "Okay",
                                                style: TextStyle(
                                                    color:
                                                        AppColors.buttonColor),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ));
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => SimpleDialog(
                                      contentPadding: EdgeInsets.all(25),
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 30.0,
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                              "Transaction was not successfull"),
                                        ),
                                        Center(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 20, horizontal: 40),
                                              child: Text(
                                                "retry",
                                                style: TextStyle(
                                                    color:
                                                        AppColors.buttonColor),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ));
                          }
                        },
                      ));
              break;
          }
        }
      }
    } catch (e) {
      print("error::$e");
      setState(() {
        _error = "Please try again! an error occured!";
        // 4187427415564246
      });
    }

    setState(() {
      processing = false;
    });

    // Navigator.of(context, rootNavigator: true).pop();
  }

  void _getCurrentUser() {
    _mAuth.currentUser().then((user) {
      if (user != null) {
        setState(() {
          _currentUser = user;
          _uidLoaded = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        print("url: $url");
        if (url.contains(UrlConstants.FLUTTERWAVE_REDIRECT_URL)) {
          Uri uri = Uri.parse(url);
          Map params = uri.queryParameters;

          print("-----------------------------------------------------");
          print(params["response"]);
          print("-----------------------------------------------------");

          String response = params["response"];

          int startIndex = response.indexOf("status");
          int endIndex = response.indexOf(",", startIndex);
          String status =
              response.substring(startIndex + 8, endIndex).replaceAll("\"", "");

          if (status == "success" || status == "successful") {
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (BuildContext context) => SimpleDialog(
                      contentPadding: EdgeInsets.all(25),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Icon(
                            Icons.done_outline,
                            color: Colors.green,
                            size: 30.0,
                          ),
                        ),
                        Center(
                          child: Text("Transaction was Successfull"),
                        ),
                        Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context, rootNavigator: false).push(
                                  CupertinoPageRoute<bool>(
                                      builder: (BuildContext context) =>
                                          MainDashboard()));
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 40),
                              child: Text(
                                "Okay",
                                style: TextStyle(color: AppColors.buttonColor),
                              ),
                            ),
                          ),
                        )
                      ],
                    ));
          } else {
            Navigator.of(context).pop();

            int start = response.indexOf("vbvrespmessage");
            int end = response.indexOf(",", start);
            String message =
                response.substring(start + 16, end).replaceAll("\"", "");

            showDialog(
                context: context,
                builder: (BuildContext context) => SimpleDialog(
                      contentPadding: EdgeInsets.all(25),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 30.0,
                          ),
                        ),
                        Center(
                          child: Text("Transaction was not successfull"),
                        ),
                        Center(
                          child: Text(
                            message != null ? message : "",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 40),
                              child: Text(
                                "retry",
                                style: TextStyle(color: AppColors.buttonColor),
                              ),
                            ),
                          ),
                        )
                      ],
                    ));
          }
        }

        // setState(() {
        //   _history.add('onUrlChanged: $url');
        // });
      }
    });
    _cardNumberController = new TextEditingController();
    _cvvController = new TextEditingController();
    _expiresController = new TextEditingController();
    _amountController = new TextEditingController();
    _cardNumberController.addListener(() {
      Map<String, dynamic> cardData =
          CreditCardValidator.getCard(_cardNumberController.text.trim());
      String cardType = cardData[CreditCardValidator.cardType];
      // bool isValid = cardData[CreditCardValidator.isValidCard];
      setState(() {
        card = cardType;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.credit_card,
                size: 30.0,
              ),
              Container(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  card == "UNKNOWN" ? "" : card,
                ),
              )
            ],
          ),
          _numberField(
              controller: _cardNumberController,
              hintText: "e.g 000123456789",
              label: "Card Number",
              validator: (value) {
                // Map<String, dynamic> cardData =
                //     CreditCardValidator.getCard(value);
                // String cardType = cardData[CreditCardValidator.cardType];
                // bool isValid = cardData[CreditCardValidator.isValidCard];
                // if (!isValid) {
                //   print("card:: $value");
                //   return "Invalid card number.";
                // }
                return null;
              }),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: _dateField(
                    maxLength: 5,
                    controller: _expiresController,
                    hintText: "MM/YY",
                    label: "Expires"),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 3,
                child: _numberField(
                    maxLength: 3,
                    controller: _cvvController,
                    hintText: "e.g 123",
                    label: "CVV/CVC"),
              ),
            ],
          ),
          Container(
              padding: EdgeInsets.only(top: 25),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Currency",
                      style: TextStyle(
                          color: AppColors.onboardingPlaceholderText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: currency,
                      onChanged: (String newValue) {
                        setState(() {
                          currency = newValue;
                        });
                      },
                      items: <String>[
                        'NGN',
                        'USD',
                        'GHS',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ])),
          _numberField(
              controller: _amountController,
              hintText: "e.g 2000",
              label: "Enter Amount",
              validator: (value) {
                if (int.parse(value) < 50) {
                  return "Minimum transaction is 50";
                }
                return null;
              }),
          SizedBox(
            height: 10,
          ),
          SizedBox(
              width: double.infinity,
              child: MaterialButton(
                color: processing ? Colors.grey : AppColors.buttonColor,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _charge();
                  }
                },
                child: Text(
                  processing ? "Processing.." : "Continue",
                  style: TextStyle(color: Colors.white),
                ),
              )),
          Text(
            _error,
            style:
                TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}

Widget _textField(
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
                fontSize: 12,
                fontWeight: FontWeight.w600),
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

Widget _numberField(
    {TextEditingController controller,
    String hintText,
    String label,
    int maxLength,
    Function validator}) {
  return Container(
      padding: EdgeInsets.only(top: 10),
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

Widget _dateField(
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
                fontSize: 12,
                fontWeight: FontWeight.w600),
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
