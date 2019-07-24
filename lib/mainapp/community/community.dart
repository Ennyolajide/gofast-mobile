import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/mainapp/community/addpost.dart';
import 'package:gofast/mainapp/community/viewfullimage.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/messagetype.dart';
import 'package:gofast/utils/utils.dart';

class CommunityPage extends StatefulWidget {
  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Firestore _firestore = Firestore.instance;
  FirebaseUser _currentUser;
  FirebaseAuth _auth = FirebaseAuth.instance;

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
        key: _scaffoldKey,
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          leading: BackButton(color: Colors.white),
          backgroundColor: AppColors.buttonColor,
          elevation: 2,
          title: Text('Community',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
        ),
        body: StreamBuilder(
            stream: _firestore.collection("Community").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.buttonColor)));
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'An error occurred retrieving accounts',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textColor, fontSize: 16),
                  ),
                );
              }
              if (snapshot.hasData) {
                if (snapshot.data.documents.length > 0) {
                  return ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        return _buildPost(snapshot.data.documents[
                            snapshot.data.documents.length - 1 - index]);
                      });
                } else {
                  return Center(
                    child: Container(
                      child: Text(
                        'No posts available yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: false).push(
              CupertinoPageRoute<bool>(
                builder: (BuildContext context) => AddPost(),
              ),
            );
          },
          backgroundColor: AppColors.buttonColor,
          tooltip: "Add post",
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPost(DocumentSnapshot snapshot) {
    if (snapshot['type'] == MessageTypes.TEXT.toString()) {
      return _buildTextPost(snapshot);
    } else if (snapshot['type'] == MessageTypes.IMAGE.toString()) {
      return _buildImagePost(snapshot);
    } else if (snapshot['type'] == MessageTypes.IMAGETEXT.toString()) {
      return _buildImageAndTextSection(snapshot);
    } else if (snapshot['type'] == MessageTypes.AUDIO.toString()) {
    } else if (snapshot['type'] == MessageTypes.AUDIOTEXT.toString()) {}
  }

  Widget _buildImageAndTextSection(DocumentSnapshot snapshot) {
    return Card(
      margin: EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.white,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 35,
                    height: 35,
                    margin: EdgeInsets.all(4),
                    child: (snapshot['ProfilePicture'] != "")
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: snapshot['ProfilePicture'] ?? '',
                              placeholder: (context, data) {
                                return Center(
                                    child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.buttonColor,
                                          width: 1)),
                                  child: Center(
                                      child: Image.asset(
                                    'assets/account.png',
                                    width: 35,
                                    height: 35,
                                  )),
                                ));
                              },
                              fit: BoxFit.cover,
                              errorWidget: (context, data, obj) {
                                return Center(
                                    child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.buttonColor,
                                          width: 1)),
                                  child: Center(
                                      child: Image.asset(
                                    'assets/account.png',
                                    width: 35,
                                    height: 35,
                                  )),
                                ));
                              },
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.buttonColor, width: 1)),
                            child: Center(
                                child: Image.asset(
                              'assets/account.png',
                              width: 35,
                              height: 35,
                            )),
                          ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    snapshot['username'],
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onboardingPlaceholderText,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  TimeAgo(timestamp: snapshot.data['timeStamp']),
                  (Preferences.communityName == snapshot['username'])
                      ? InkWell(
                          onTap: () {
                            _showDeleteDialog(snapshot.documentID);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 3),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : SizedBox()
                ],
              )
            ],
          ),
          Divider(height: 0),
          Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context, rootNavigator: false)
                        .push(CupertinoPageRoute<bool>(
                      builder: (BuildContext context) =>
                          ViewFullImage(imgUrl: snapshot.data['imageUrl']),
                    ));
                  },
                  child: SizedBox(
                    height: 200,
                    child: CachedNetworkImage(
                      imageUrl: snapshot.data['imageUrl'],
                      fit: BoxFit.cover,
                      errorWidget: (context, data, obj) {
                        return Center(
                            child: Text('Error Loading Image',
                                style: TextStyle(fontSize: 16)));
                      },
                      placeholder: (context, data) {
                        return Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.buttonColor)));
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 0),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(snapshot.data['text'],
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.onboardingPlaceholderText,
                    fontWeight: FontWeight.normal)),
          )
        ],
      ),
    );
  }

  Widget _buildImagePost(DocumentSnapshot snapshot) {
    return Card(
      margin: EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.white,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 35,
                    height: 35,
                    margin: EdgeInsets.all(4),
                    child: (snapshot['ProfilePicture'] != "")
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: snapshot['ProfilePicture'] ?? '',
                              placeholder: (context, data) {
                                return Center(
                                    child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.buttonColor,
                                          width: 1)),
                                  child: Center(
                                      child: Image.asset(
                                    'assets/account.png',
                                    width: 35,
                                    height: 35,
                                  )),
                                ));
                              },
                              fit: BoxFit.cover,
                              errorWidget: (context, data, obj) {
                                return Center(
                                    child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.buttonColor,
                                          width: 1)),
                                  child: Center(
                                      child: Image.asset(
                                    'assets/account.png',
                                    width: 35,
                                    height: 35,
                                  )),
                                ));
                              },
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.buttonColor, width: 1)),
                            child: Center(
                                child: Image.asset(
                              'assets/account.png',
                              width: 35,
                              height: 35,
                            )),
                          ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    snapshot['username'],
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onboardingPlaceholderText,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  TimeAgo(timestamp: snapshot.data['timeStamp']),
                  (Preferences.communityName == snapshot['username'])
                      ? InkWell(
                          onTap: () {
                            _showDeleteDialog(snapshot.documentID);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 3),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : SizedBox()
                ],
              )
            ],
          ),
          Divider(height: 0),
          Row(
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context, rootNavigator: false)
                        .push(CupertinoPageRoute<bool>(
                      builder: (BuildContext context) => ViewFullImage(
                            imgUrl: snapshot.data['imageUrl'],
                          ),
                    ));
                  },
                  child: SizedBox(
                    height: 200,
                    child: CachedNetworkImage(
                      imageUrl: snapshot.data['imageUrl'],
                      fit: BoxFit.cover,
                      errorWidget: (context, data, obj) {
                        return Center(
                            child: Text('Error Loading Image',
                                style: TextStyle(fontSize: 16)));
                      },
                      placeholder: (context, data) {
                        return Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.buttonColor)));
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextPost(DocumentSnapshot snapshot) {
    return Card(
      margin: EdgeInsets.only(left: 12, right: 12, top: 5, bottom: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.white,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 35,
                    height: 35,
                    margin: EdgeInsets.all(4),
                    child: (snapshot['ProfilePicture'] != "")
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: snapshot['ProfilePicture'] ?? '',
                              placeholder: (context, data) {
                                return Center(
                                    child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.buttonColor,
                                          width: 1)),
                                  child: Center(
                                      child: Image.asset(
                                    'assets/account.png',
                                    width: 35,
                                    height: 35,
                                  )),
                                ));
                              },
                              fit: BoxFit.cover,
                              errorWidget: (context, data, obj) {
                                return Center(
                                    child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.buttonColor,
                                          width: 1)),
                                  child: Center(
                                      child: Image.asset(
                                    'assets/account.png',
                                    width: 35,
                                    height: 35,
                                  )),
                                ));
                              },
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.buttonColor, width: 1)),
                            child: Center(
                                child: Image.asset(
                              'assets/account.png',
                              width: 35,
                              height: 35,
                            )),
                          ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    snapshot['username'],
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColors.onboardingPlaceholderText,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  TimeAgo(timestamp: snapshot.data['timeStamp']),
                  (Preferences.communityName == snapshot['username'])
                      ? InkWell(
                          onTap: () {
                            _showDeleteDialog(snapshot.documentID);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 3),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : SizedBox()
                ],
              )
            ],
          ),
          Divider(height: 0),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(snapshot.data['text'],
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.onboardingPlaceholderText,
                    fontWeight: FontWeight.normal)),
          )
        ],
      ),
    );
  }

  void _showDeleteDialog(String docId) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 50,
            color: Colors.white,
            child: InkWell(
              onTap: () {
                _firestore
                    .collection("Community")
                    .document(docId)
                    .delete()
                    .then((data) {
                  Navigator.pop(context);
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 15),
                  Text('Delete',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 22,
                          fontWeight: FontWeight.bold))
                ],
              ),
            ),
          );
        });
  }
}

class TimeAgo extends StatefulWidget {
  int _timestamp;
  TimeAgo({int timestamp}) {
    _timestamp = timestamp;
  }
  @override
  State<StatefulWidget> createState() => TimeAgoState();
}

class TimeAgoState extends State<TimeAgo> {
  Timer _refreshTimer;
  String _timeago = "";

  _feedItemUpdate() {
    _timeago = Utils.getTimeAgo(widget._timestamp);
  }

  @override
  initState() {
    _feedItemUpdate();
    _refreshTimer = Timer.periodic(Duration(seconds: 60), (t) {
      try {
        setState(() {
          _feedItemUpdate();
        });
      } catch (e) {
        _refreshTimer.cancel();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(_timeago,
          style: TextStyle(
            color: AppColors.onboardingPlaceholderText,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          )),
    );
  }
}
