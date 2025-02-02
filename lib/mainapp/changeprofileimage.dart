import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';
import 'package:image_picker/image_picker.dart';

class ChangeImage extends StatefulWidget {
  @override
  _ChangeImageState createState() => _ChangeImageState();
}

class _ChangeImageState extends State<ChangeImage> {
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  Firestore _firestore = Firestore.instance;
  FirebaseUser _currentUser;
  FirebaseAuth _auth = FirebaseAuth.instance;
  BuildContext _dialogContext;

  @override
  void initState() {
    _getCurrentUser();
    _initPreferences();
    super.initState();
  }

  void _getCurrentUser() {
    _auth.currentUser().then((user) {
      _currentUser = user;
    });
  }

  void _initPreferences() {
    Preferences.init().then((prefs) {});
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: AppColors.buttonColor,
          title: Text('Change image',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          actions: <Widget>[
            IconButton(
                tooltip: 'Update Image',
                icon: Icon(Icons.mode_edit, color: Colors.white),
                onPressed: () => uploadImage())
          ],
        ),
        body: Center(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            height: screenAwareSize(400, context),
            decoration:
                BoxDecoration(border: Border.all(color: AppColors.buttonColor)),
            child: (Preferences.profilePicture != "")
                ? CachedNetworkImage(
                    imageUrl: Preferences.profilePicture ?? '',
                    placeholder: (context, data) {
                      return Center(
                        child: Image.asset(
                        'assets/avatar.png',
                        width: 200,
                        color: Colors.grey,
                        height: 200,
                      ));
                    },
                    fit: BoxFit.cover,
                    errorWidget: (context, data, obj) {
                      return Center(
                        child: Image.asset(
                        'assets/avatar.png',
                        width: 200,
                        color: Colors.grey,
                        height: 200,
                      ));
                    },
                  )
                : Center(
                    child: Image.asset(
                    'assets/avatar.png',
                    width: 200,
                    color: Colors.grey,
                    height: 200,
                  )),
          ),
        ),
      ),
    );
  }

  Future uploadImage() async {
    File _image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (_image != null) {
      _showDialog("Updating image...");
      StorageReference ref = _firebaseStorage
          .ref()
          .child("Images/ProfileImage")
          .child(
              "${Preferences.communityName}${DateTime.now().millisecondsSinceEpoch}");

      StorageUploadTask uploadTask = ref.putFile(_image);
      var snapshot = await uploadTask.onComplete;
      snapshot.ref.getDownloadURL().then((imageUrl) {
        Map<String, dynamic> data = new Map();
        data['ProfilePicture'] = imageUrl;

        _firestore
            .collection("Users")
            .document(_currentUser.uid)
            .updateData(data)
            .then((doc) {
          _firestore
              .collection("Community")
              .where('userId', isEqualTo: _currentUser.uid)
              .getDocuments()
              .then((snapshot) {
            snapshot.documents.forEach((document) {
              String docId = document.documentID;
              _firestore
                  .collection("Community")
                  .document(docId)
                  .updateData(data);
            });
          }).then((data) {
            setState(() {
              Preferences.profilePicture = imageUrl;
            });
            _removeDialog();
          });
        });
      });
    }
  }

  void _removeDialog() {
    Navigator.of(_dialogContext).pop();
  }

  void _showDialog(String message) {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _dialogContext = context;
        return WillPopScope(
          onWillPop: () {},
          child: Dialog(
              insetAnimationCurve: Curves.easeInOut,
              insetAnimationDuration: Duration(milliseconds: 100),
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: SizedBox(
                  height: 100.0,
                  child: Row(children: <Widget>[
                    const SizedBox(width: 15.0),
                    SizedBox(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.buttonColor),
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    Expanded(
                        child: Text(message,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w700)))
                  ]))),
        );
      },
    );
  }
}
