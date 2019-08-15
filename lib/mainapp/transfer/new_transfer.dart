import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:gofast/mainapp/transfer/transfer_form.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NewTransfer extends StatefulWidget {
  @override
  _NewTransferState createState() => _NewTransferState();
}

class _NewTransferState extends State<NewTransfer> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                leading: BackButton(color: Colors.white),
                backgroundColor: AppColors.buttonColor,
                title: Text('Make Transfer',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700))),
            body: Material(
                type: MaterialType.card,
                child: Card(
                  margin: EdgeInsets.all(10),
                    child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(children: <Widget>[TransferForm()]))))));
  }
}
