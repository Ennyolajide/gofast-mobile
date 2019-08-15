import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:gofast/mainapp/fund_wallet/fund_wallet_form.dart';
import 'package:gofast/mainapp/transfer/transfer_form.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FundWallet extends StatefulWidget {
  @override
  _FundWalletState createState() => _FundWalletState();
}

class _FundWalletState extends State<FundWallet> {
  final _formKey = GlobalKey<FormState>();

  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                leading: BackButton(color: Colors.white),
                backgroundColor: AppColors.buttonColor,
                title: Text('Fund Your Wallet',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700))),
            body: Material(
                child: Card(
                    margin: EdgeInsets.all(10),
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            padding: EdgeInsets.all(20),
                            child: FundWalletForm()))))));
  }
}
