import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gofast/utils/colors.dart';

class ViewFullImage extends StatefulWidget {
  String imgUrl;

  ViewFullImage({this.imgUrl});

  @override
  _ViewFullImageState createState() => _ViewFullImageState();
}

class _ViewFullImageState extends State<ViewFullImage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: AppColors.buttonColor,
          elevation: 2,
          title: Text('Full Image',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ),
        body: ListView(
          children: <Widget>[
            Center(
              child: Container(
//                margin: EdgeInsets.symmetric(vertical: 10),
                child: CachedNetworkImage(
                  imageUrl: widget.imgUrl,
                  placeholder: (context, data) {
                    return Center(
                        child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
                    ));
                  },
                  fit: BoxFit.cover,
                  errorWidget: (context, data, obj) {
                    return Center(
                        child: Text(
                      'Could not load this image',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ));
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
