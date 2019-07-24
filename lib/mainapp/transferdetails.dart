import 'package:flutter/material.dart';
import 'package:gofast/utils/colors.dart';

class TransferDetails extends StatefulWidget {
  String accountname;
  String accountNubmer;
  String amount;
  String bankName;
  String remarks;
  String time;

  TransferDetails(
      {this.accountname,
      this.accountNubmer,
      this.amount,
      this.bankName,
      this.remarks,
      this.time});

  @override
  _TransferDetailsState createState() => _TransferDetailsState();
}

class _TransferDetailsState extends State<TransferDetails> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: AppColors.buttonColor,
          title: Text('Transfer details',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: ListView(
            children: <Widget>[
              _buildAccountnameContainer(),
              _buildDivider(),
              _buildAccountNumberContainer(),
              _buildDivider(),
              _buildAmountContainer(),
              _buildDivider(),
              _buildBankNameContainer(),
              _buildDivider(),
              _buildRemarksContainer(),
              _buildDivider(),
              _buildTimeContainer(),
              _buildDivider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountnameContainer() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: Text(
        'Account name: ${widget.accountname}',
        style: TextStyle(
            color: AppColors.onboardingPlaceholderText,
            fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 0.0,
    );
  }

  Widget _buildAccountNumberContainer() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: Text(
        'Account number: ${widget.accountNubmer}',
        style: TextStyle(
            color: AppColors.onboardingPlaceholderText,
            fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
    );
  }

  Widget _buildAmountContainer() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: Text(
        'Amount: ${widget.amount}',
        style: TextStyle(
            color: AppColors.onboardingPlaceholderText,
            fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
    );
  }

  Widget _buildBankNameContainer() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: Text(
        'Bank name: ${widget.bankName}',
        style: TextStyle(
            color: AppColors.onboardingPlaceholderText,
            fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
    );
  }

  Widget _buildRemarksContainer() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: Text(
        'Remarks: ${widget.remarks}',
        style: TextStyle(
            color: AppColors.onboardingPlaceholderText,
            fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
    );
  }

  Widget _buildTimeContainer() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: Text(
        'Time: ${widget.time}',
        style: TextStyle(
            color: AppColors.onboardingPlaceholderText,
            fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
    );
  }
}
