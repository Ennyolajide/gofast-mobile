import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/messagetype.dart';
import 'package:gofast/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  bool _autoValidate = false;
  final _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  BuildContext _dialogContext;
  Firestore _firestore = Firestore.instance;
  FirebaseUser _currentUser;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isIos;
  TextEditingController _postController = TextEditingController();
  final textFocusNode = FocusNode();
  bool _canSend = false;
  bool _canPickImage = true;
  bool _canRecordAudio = true;
  File image;
  var _audioFile;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  FlutterSound flutterSound = new FlutterSound();
  bool _isRecording = false;
  bool _isPlaying = false;
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';
  double _dbLevel;

  _AddPostState() {
    _postController.addListener(() {
      if (_postController.text.length > 0) {
        setState(() {
          _canSend = true;
          _canRecordAudio = false;
        });
      }
    });
  }

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
    FocusScope.of(context).requestFocus(textFocusNode);
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: AppColors.buttonColor,
          title: Text('Add post',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          actions: <Widget>[
            IconButton(
                tooltip: 'Send',
                icon: Icon(Icons.send,
                    color: _canSend ? Colors.white : Colors.grey),
                onPressed: () => _canSend ? _performVerification() : null)
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Flexible(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      _buildTextField(),
                      image != null ? _buildImage() : SizedBox()
                    ],
                  ),
                ),
              ),
              _buildActionsContainer()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 10),
        child: Stack(
          children: <Widget>[
            Image.file(image, height: 400),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                child: Icon(Icons.highlight_off, color: Colors.grey),
                onTap: () {
                  setState(() {
                    image = null;
                    setState(() {
                      _canRecordAudio = true;
                    });
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      height: screenAwareSize(150, context),
      child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: TextFormField(
              keyboardType: TextInputType.text,
              style: TextStyle(fontSize: 16),
              maxLines: null,
              focusNode: textFocusNode,
              controller: _postController,
              decoration: InputDecoration(
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 12, left: 12),
                hintText: ' Type message',
                hintStyle: TextStyle(
                    color: AppColors.onboardingTextFieldHintTextColor),
              ),
              autovalidate: _autoValidate,
              validator: (val) {
                if (val.isEmpty) {
                  return 'Field is required';
                }
              })),
    );
  }

  Widget _buildActionsContainer() {
    return Container(
      color: AppColors.buttonColor,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: IconButton(
                tooltip: 'Upload image',
                padding: EdgeInsets.zero,
                icon: Icon(Icons.image,
                    color: _canPickImage ? Colors.white : Colors.grey),
                onPressed: () => _canPickImage ? _selectImage() : null),
          ),
//          Container(
//            child: IconButton(
//                tooltip: "Record audio",
//                padding: EdgeInsets.zero,
//                icon: Icon(Icons.keyboard_voice,
//                    color: _canRecordAudio ? Colors.white : Colors.grey),
//                onPressed: () => _canRecordAudio ? _handleAudio() : null),
//          )
        ],
      ),
    );
  }

  _sendMessage() {
    if (_postController.text.isNotEmpty && image != null) {
      _sendImageAndText();
    } else if (_postController.text.isNotEmpty && _audioFile != null) {
      _sendAudioAndText();
    } else if (_postController.text.isNotEmpty &&
        (image == null || _audioFile == null)) {
      _sendTextOnly();
    } else if (image != null && _postController.text.isEmpty) {
      _sendImageOnly();
    } else if (_audioFile != null && _postController.text.isEmpty) {
      _sendAudioOnly();
    }
  }

  void _performVerification() {
    _showDialog("Uploading post...");
    if (_currentUser != null) {
      _firestore
          .collection("Users")
          .document(_currentUser.uid)
          .get()
          .then((snapShot) {
        String onlineUserId = snapShot.data['deviceId'];
        if (onlineUserId == Preferences.deviceId) {
          _sendMessage();
        } else {
          _removeDialog();
          Utils.showErrorDialog(context, "Authentication failed!",
              "You have been signed out of this device.");
        }
      }).catchError((e) {
        _removeDialog();
        Utils.showErrorDialog(context, "Error", "An error occured");
      });
    } else {
      _removeDialog();
      Utils.showErrorDialog(context, "Authentication failed!",
          "You have been signed out of this device.");
    }
  }

  Future _selectImage() async {
    File _image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (_image != null) {
      setState(() {
        image = _image;
        _canRecordAudio = false;
        _canSend = true;
      });
    }
  }

  Future _sendImageAndText() async {
    StorageReference ref = _firebaseStorage.ref().child("Images/Community").child(
        "${Preferences.communityName}${DateTime.now().millisecondsSinceEpoch}");

    StorageUploadTask uploadTask = ref.putFile(image);
    var snapshot = await uploadTask.onComplete;
    snapshot.ref.getDownloadURL().then((imageUrl) {
      Map<String, dynamic> data = new Map();
      data['type'] = MessageTypes.IMAGETEXT.toString();
      data['timeStamp'] = DateTime.now().millisecondsSinceEpoch;
      data['userId'] = _currentUser.uid;
      data['text'] = _postController.text;
      data['username'] = Preferences.communityName;
      data['ProfilePicture'] = Preferences.profilePicture;
      data['imageUrl'] = imageUrl;

      _firestore.collection("Community").add(data).then((data) {
        _removeDialog();
        Navigator.pop(context);
      });
    });
  }

  void _sendAudioAndText() {}

  void _sendTextOnly() {
    Map<String, dynamic> data = new Map();
    data['type'] = MessageTypes.TEXT.toString();
    data['timeStamp'] = DateTime.now().millisecondsSinceEpoch;
    data['text'] = _postController.text;
    data['userId'] = _currentUser.uid;
    data['username'] = Preferences.communityName;
    data['ProfilePicture'] = Preferences.profilePicture;

    _firestore.collection("Community").add(data).then((value) {
      _removeDialog();
      Navigator.pop(context);
    });
  }

  Future _sendImageOnly() async {
    StorageReference ref = _firebaseStorage.ref().child("Images/Community").child(
        "${Preferences.communityName}${DateTime.now().millisecondsSinceEpoch}");

    StorageUploadTask uploadTask = ref.putFile(image);
    var snapshot = await uploadTask.onComplete;
    snapshot.ref.getDownloadURL().then((imageUrl) {
      Map<String, dynamic> data = new Map();
      data['type'] = MessageTypes.IMAGE.toString();
      data['timeStamp'] = DateTime.now().millisecondsSinceEpoch;
      data['userId'] = _currentUser.uid;
      data['username'] = Preferences.communityName;
      data['ProfilePicture'] = Preferences.profilePicture;
      data['imageUrl'] = imageUrl;

      _firestore.collection("Community").add(data).then((data) {
        _removeDialog();
        Navigator.pop(context);
      });
    });
  }

  void _sendAudioOnly() {}

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

  Future _recordAudio() async {
    try {
      String path = await flutterSound.startPlayer(null);
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt(),
              isUtc: true);
          String txt = DateFormat('mm:ss:SS', 'en_US').format(date);
          this.setState(() {
            this._isPlaying = true;
            this._playerTxt = txt.substring(0, 8);
          });
        }
      });

      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {
        print("got update -> $value");
        setState(() {
          this._dbLevel = value;
        });
      });

      this.setState(() {
        this._isRecording = true;
      });
    } catch (err) {}
  }

  void _handleAudio() {
    setState(() {
      _canPickImage = false;
    });
  }
}
