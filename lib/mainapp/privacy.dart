import 'package:flutter/material.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:gofast/utils/colors.dart';


class Privacy extends StatefulWidget {
  @override
  _PrivacyState createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  List<Widget> widgets = new List();
  bool _isLoading = true;
  PDFDocument _document;

  @override
  void initState() {
    super.initState();
    loadFile();
  }


  void loadFile() async {
    _document = await PDFDocument.fromAsset('assets/terms.pdf');
    setState(() => _isLoading = false );
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: AppColors.buttonColor,
        title: Text('Privacy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700
          )
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : PDFViewer(document: _document),
          ),
      ),
    );
  }

}

