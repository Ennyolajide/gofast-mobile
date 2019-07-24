import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/mainapp/maindashboard.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';

class ConfirmTransfer extends StatefulWidget {
  @override
  _ConfirmTransferState createState() => _ConfirmTransferState();
}

class _ConfirmTransferState extends State<ConfirmTransfer> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: AppColors.buttonColor,
        title: Text('Confirm transfer',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 18),
        child: ListView(
          children: <Widget>[
            _buildCard("Account Number", "2009384783"),
            _buildCard("Account Name", "Abraham Davido Ike"),
            _buildCard("Bank", "Diamond Bank"),
            _buildCard("Amount", "N 20,000.00"),
            _buildTransferMoneyBtn()
          ],
        ),
      ),
    ));
  }

  Widget _buildCard(String header, String content) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Card(
        elevation: 8,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 16, vertical: screenAwareSize(15, context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                header,
                style: TextStyle(fontSize: 12, color: AppColors.textColor),
              ),
              SizedBox(height: 10),
              Text(
                content,
                style: TextStyle(
                    fontSize: 17,
                    color: AppColors.onboardingPlaceholderText,
                    fontFamily: 'MontserratSemiBold'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransferMoneyBtn() {
    return Container(
      margin: EdgeInsets.only(
        top: screenAwareSize(100, context),
      ),
      child: RaisedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainDashboard()),
              (Route<dynamic> route) => false);
        },
        color: AppColors.buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Transfer Money',
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
}
