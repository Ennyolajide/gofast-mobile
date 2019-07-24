import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gofast/config/CONFIG.dart';
import 'package:gofast/mainapp/accountspage.dart';
import 'package:gofast/mainapp/beneficiaries/view_beneficiaries.dart';
import 'package:gofast/mainapp/changeprofileimage.dart';
import 'package:gofast/mainapp/community/community.dart';
import 'package:gofast/mainapp/community/services.dart';
import 'package:gofast/mainapp/milestones.dart';
import 'package:gofast/mainapp/moneytransfer/receipient_details.dart';
import 'package:gofast/mainapp/moneytransfer/transfertobeneficiary.dart';
import 'package:gofast/mainapp/settings.dart';
import 'package:gofast/mainapp/updateProfile.dart';
import 'package:gofast/mainapp/view_transfers.dart';
import 'package:gofast/onboarding/bankAccountSetup/addbank.dart';
import 'package:gofast/onboarding/login.dart';
import 'package:gofast/persistence/preferences.dart';
import 'package:gofast/utils/colors.dart';
import 'package:gofast/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class MainDashboard extends StatefulWidget {
  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _accountTabController;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _firebaseUser;
  Firestore _firestore = Firestore.instance;
  bool _uidLoaded = false;
  bool _loadTransfer = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _initPreferences();
  }

  void _getCurrentUser() {
    _auth.currentUser().then((user) {
      if (user != null) {
        setState(() {
          _firebaseUser = user;
          _uidLoaded = true;
        });
      }
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
        backgroundColor: Color(0xFFFFFAFA),
        drawer: _buildDrawer(),
        body: ListView(
          children: <Widget>[
            _buildHeader(),
            _buildQuickServices(),
            _buildHistoryContainer(),
            _buildHistoryItems()
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.buttonColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => ChangeImage()));
                    },
                    child: ClipOval(
                      child: Container(
                        width: 64,
                        height: 64,
                        color: Colors.white,
                        child: (Preferences.profilePicture != "")
                            ? CachedNetworkImage(
                                imageUrl: Preferences.profilePicture ?? '',
                                placeholder: (context, data) {
                                  return Center(
                                      child: Image.asset(
                                    'assets/account.png',
                                    width: 60,
                                    height: 60,
                                  ));
                                },
                                fit: BoxFit.cover,
                                errorWidget: (context, data, obj) {
                                  return Center(
                                      child: Image.asset(
                                    'assets/account.png',
                                    width: 60,
                                    height: 60,
                                  ));
                                },
                              )
                            : Center(
                                child: Image.asset(
                                'assets/account.png',
                                width: 60,
                                height: 60,
                              )),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Hi, ${Preferences.firstname ?? ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontFamily: 'MontserratSemiBold',
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${Preferences.email ?? ""}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'MontserratSemiBold',
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => UpdateProfile()));
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 7),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )),
          _buildListTile('assets/user.png', "My Account",
              launchPage: MyAccount()),
          _buildTransferListTile('assets/transfer_funds.png', "Transfer Funds"),
          _buildListTile('assets/transfer.png', "My Transfers",
              launchPage: ViewTransfers()),
          _buildListTile('assets/beneficiaries.png', "Beneficiaries List",
              launchPage: Beneficiaries()),
          _buildListTile('assets/service_profile.png', "Service Profile",
              launchPage: Preferences.signedUpForCommunity
                  ? CommunityPage()
                  : Services()),
          _buildListTile('assets/milestones.png', "Milestone",
              launchPage: Milestones()),
          _buildListTile('assets/settings_work_tool.png', "About",
              launchPage: Settings()),
          _buildContactUsTile('assets/phone_contact.png', "Contact Us"),
          _buildLogoutTile('assets/logout.png', "Log out")
        ],
      ),
    );
  }

  Widget _buildContactUsTile(String image, String title) {
    return ListTile(
      onTap: () {
        String email = CONFIG.SUPPORT_EMAIL;
        canLaunch("mailto:${email}").then(
          (canlaunch) {
            if (canlaunch) {
              launch('mailto:${email}');
            }
          },
        );
      },
      leading: Image.asset('assets/phone_contact.png', width: 20, height: 20),
      title: Text(
        "Contact Us",
        style: TextStyle(
            color: AppColors.onboardingPlaceholderText,
            fontSize: 17,
            letterSpacing: 0.33,
            fontFamily: 'MontserratSemiBold',
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTransferListTile(String image, String title) {
    return ListTile(
      onTap: () {
        _showComingSoonDialog();
      },
      leading: Image.asset(image, width: 20, height: 20),
      title: Text(
        title,
        style: TextStyle(
            color: AppColors.onboardingPlaceholderText,
            fontSize: 17,
            letterSpacing: 0.33,
            fontFamily: 'MontserratSemiBold',
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildLogoutTile(String image, String title) {
    return ListTile(
      onTap: () {
        showDialog<dynamic>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            if (Platform.isAndroid) {
              return new AlertDialog(
                title: new Text(
                  title ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      new Text('Are you sure you want to log out?',
                          style: TextStyle(
                              fontSize: 15, fontFamily: 'Montserrat')),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: new Text(
                      'Yes',
                      style: TextStyle(
                          color: AppColors.buttonColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _handleLogOut();
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: new Text(
                      'No',
                      style: TextStyle(
                          color: AppColors.buttonColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            } else {
              return new CupertinoAlertDialog(
                title: Text(
                  title ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      new Text('Are you sure you want to log out?',
                          style:
                              TextStyle(fontSize: 15, fontFamily: 'Montserrat'))
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: new Text(
                      'Yes',
                      style: TextStyle(
                          color: AppColors.buttonColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _handleLogOut();
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: new Text(
                      'No',
                      style: TextStyle(
                          color: AppColors.buttonColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
          },
        );
      },
      leading: Image.asset(image, width: 20, height: 20),
      title: Text(
        title,
        style: TextStyle(
            color: AppColors.onboardingPlaceholderText,
            fontSize: 17,
            letterSpacing: 0.33,
            fontFamily: 'MontserratSemiBold',
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildListTile(String image, String title, {Widget launchPage}) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        if (launchPage != null) {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => launchPage));
        }
      },
      leading: Image.asset(image, width: 20, height: 20),
      title: Text(
        title,
        style: TextStyle(
            color: AppColors.onboardingPlaceholderText,
            fontSize: 17,
            letterSpacing: 0.33,
            fontFamily: 'MontserratSemiBold',
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/dashboard_header_bg.png'))),
          height: screenAwareSize(230, context),
        ),
        Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: screenAwareSize(18, context),
                    bottom: screenAwareSize(23, context)),
                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        _scaffoldKey.currentState.openDrawer();
                      },
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    Expanded(
                        child: Image.asset('assets/gofast.png',
                            width: 100, height: 20)),
                    InkWell(
                      onTap: () {
                        Navigator.of(context, rootNavigator: false).push(
                          CupertinoPageRoute<bool>(
                            builder: (BuildContext context) =>
                                Preferences.signedUpForCommunity
                                    ? CommunityPage()
                                    : Services(),
                          ),
                        );
                      },
                      child: Container(
                        width: 36,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        height: screenAwareSize(36, context),
                        child: (Preferences.profilePicture != "")
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: Preferences.profilePicture ?? '',
                                  placeholder: (context, data) {
                                    return Center(
                                        child: Image.asset(
                                      'assets/account.png',
                                      width: 33,
                                      height: 33,
                                    ));
                                  },
                                  fit: BoxFit.cover,
                                  errorWidget: (context, data, obj) {
                                    return Center(
                                        child: Image.asset(
                                      'assets/account.png',
                                      width: 33,
                                      height: 33,
                                    ));
                                  },
                                ),
                              )
                            : Center(
                                child: Image.asset(
                                'assets/account.png',
                                width: 36,
                                height: 36,
                              )),
                      ),
                    )
                  ],
                ),
              ),
              _buildAccountSlides()
            ],
          ),
        )
      ],
    );
  }

  Widget _buildAccountSlides() {
    return (_uidLoaded)
        ? StreamBuilder(
            stream: _firestore
                .collection("Users")
                .document(_firebaseUser.uid)
                .collection("Accounts")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                    child: Container(
                  margin: EdgeInsets.only(top: 15),
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                ));
              }
              if (snapshot.hasError) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 19),
                  height: 110,
                  child: Center(
                    child: Text(
                      'An error occurred retrieving accounts',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: AppColors.textColor, fontSize: 16),
                    ),
                  ),
                );
              }
              if (snapshot.hasData) {
                if (snapshot.data.documents.length > 0) {
                  return _buildAccountContent(snapshot);
                } else {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 19),
                    height: 110,
                    child: Card(
                      elevation: 8,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'You have no account, tap to add.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                Navigator.of(context, rootNavigator: false)
                                    .push(new CupertinoPageRoute<bool>(
                                        builder: (context) {
                                  return AddAccount(fromOnboarding: false);
                                }));
                              },
                              child: ClipOval(
                                child: Container(
                                  color: AppColors.floatingBtnColor,
                                  height: 36,
                                  width: 36,
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }
            },
          )
        : SizedBox();
  }

  Widget _buildAccountContent(AsyncSnapshot snapshot) {
    _accountTabController =
        TabController(length: snapshot.data.documents.length, vsync: this);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 19),
          height: 120,
          child: TabBarView(
              controller: _accountTabController,
              children: List.from(snapshot.data.documents).map((item) {
                return Card(
                  elevation: 8,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: screenAwareSize(14, context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Icon(
                              Icons.account_balance,
                              color: AppColors.buttonColor,
                            ),
                            Material(
                              elevation: 6,
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context, rootNavigator: false)
                                      .push(new CupertinoPageRoute<bool>(
                                          builder: (context) {
                                    return AddAccount(fromOnboarding: false);
                                  }));
                                },
                                child: ClipOval(
                                  child: Container(
                                    color: AppColors.floatingBtnColor,
                                    height: 26,
                                    width: 26,
                                    child: Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'ACCOUNT NAME',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.transferHistoryItemTextColor,
                                  fontSize: 9),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Text(
                                'ACCOUNT NUMBER',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        AppColors.transferHistoryItemTextColor,
                                    fontSize: 9),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(item['AccountName'],
                                      style: TextStyle(
                                        color: AppColors.textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'MontserratSemiBold',
                                      ))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(item['AccountNumber'],
                                      style: TextStyle(
                                        color: AppColors.textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'MontserratSemiBold',
                                      ))
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }).toList()),
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: 10),
          child: TabPageSelector(
            indicatorSize: 7,
            color: AppColors.buttonColor,
            selectedColor: AppColors.goldColor,
            controller: _accountTabController,
          ),
        )
      ],
    );
  }

  Widget _buildQuickServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 20, top: 30, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Quick Services',
                style: TextStyle(
                    color: AppColors.goldBgColor,
                    fontSize: 14,
                    fontFamily: 'MontserratSemiBold'),
              ),
              SizedBox(width: 10),
              Flexible(
                  child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: AppColors.onboardingTextFieldBorder))),
              ))
            ],
          ),
        ),

        InkWell(
          child: _buildTransferItem(),
          onTap: () {
            _showComingSoonDialog();
          },
        ),
        SizedBox(height: 10),
        InkWell(
          child: _buildViewTransfer(),
          onTap: () {
            Navigator.of(context, rootNavigator: false).push(
              CupertinoPageRoute<bool>(
                builder: (BuildContext context) => ViewTransfers(),
              ),
            );
          },
        ),
        SizedBox(height: 10),
        InkWell(
            child: _buildBeneficiaryItem(),
            onTap: () {
              Navigator.of(context, rootNavigator: false).push(
                CupertinoPageRoute<bool>(
                  builder: (BuildContext context) => Beneficiaries(),
                ),
              );
            }),
        SizedBox(height: 10),
        InkWell(
            child: _buildServicesItem(),
            onTap: () {
              Navigator.of(context, rootNavigator: false).push(
                CupertinoPageRoute<bool>(
                  builder: (BuildContext context) =>
                      Preferences.signedUpForCommunity
                          ? CommunityPage()
                          : Services(),
                ),
              );
            })

//        Container(
//          height: 80,
//          child: Center(
//            child: ListView(
//              shrinkWrap: true,
//              scrollDirection: Axis.horizontal,
//              children: <Widget>[
//                InkWell(
//                  onTap: () {
////                  _showSelectionDialog();
//                    _showComingSoonDialog();
//                  },
//                  child: Container(
////                  width: 80,
//                    padding:
//                        EdgeInsets.only(top: 17, bottom: 9, left: 9, right: 9),
//                    decoration: BoxDecoration(
//                        border: Border.all(
//                            color: AppColors.onboardingTextFieldBorder),
//                        borderRadius: BorderRadius.circular(15)),
//                    child: Column(
//                      children: <Widget>[
//                        Image.asset(
//                          'assets/bank.png',
//                          width: 30,
//                          height: 30,
//                        ),
//                        SizedBox(height: 8),
//                        Text('Transfer funds',
//                            style: TextStyle(
//                                color: AppColors.goldBgColor,
//                                fontSize: 9,
//                                fontFamily: 'MontserratSemiBold'))
//                      ],
//                    ),
//                  ),
//                ),
//                SizedBox(width: 10),
//                InkWell(
//                  onTap: () {
//                    Navigator.of(context, rootNavigator: false).push(
//                      CupertinoPageRoute<bool>(
//                        builder: (BuildContext context) => ViewTransfers(),
//                      ),
//                    );
//                  },
//                  child: Container(
////                  width: 80,
//                    padding:
//                        EdgeInsets.only(top: 17, bottom: 9, left: 9, right: 9),
//                    decoration: BoxDecoration(
//                        border: Border.all(
//                            color: AppColors.onboardingTextFieldBorder),
//                        borderRadius: BorderRadius.circular(15)),
//                    child: Column(
//                      children: <Widget>[
//                        Image.asset(
//                          'assets/money_transfer.png',
//                          width: 30,
//                          height: 30,
//                        ),
//                        SizedBox(height: 8),
//                        Text('View transfers',
//                            style: TextStyle(
//                                color: AppColors.goldBgColor,
//                                fontSize: 9,
//                                fontFamily: 'MontserratSemiBold'))
//                      ],
//                    ),
//                  ),
//                ),
//                SizedBox(width: 10),
//                InkWell(
//                  onTap: () {
//                    Navigator.of(context, rootNavigator: false).push(
//                      CupertinoPageRoute<bool>(
//                        builder: (BuildContext context) => Beneficiaries(),
//                      ),
//                    );
//                  },
//                  child: Container(
////                  width: 80,
//                    padding: EdgeInsets.only(
//                        top: 17, bottom: 9, left: 10, right: 10),
//                    decoration: BoxDecoration(
//                        border: Border.all(
//                            color: AppColors.onboardingTextFieldBorder),
//                        borderRadius: BorderRadius.circular(15)),
//                    child: Column(
//                      children: <Widget>[
//                        Image.asset(
//                          'assets/quick_transfer.png',
//                          width: 30,
//                          height: 30,
//                        ),
//                        SizedBox(height: 8),
//                        Text('Beneficiaries',
//                            style: TextStyle(
//                                color: AppColors.goldBgColor,
//                                fontSize: 9,
//                                fontFamily: 'MontserratSemiBold'))
//                      ],
//                    ),
//                  ),
//                ),
//                SizedBox(width: 10),
//                InkWell(
//                  onTap: () {
//                    Navigator.of(context, rootNavigator: false).push(
//                      CupertinoPageRoute<bool>(
//                        builder: (BuildContext context) =>
//                            Preferences.signedUpForCommunity
//                                ? CommunityPage()
//                                : Services(),
//                      ),
//                    );
//                  },
//                  child: Container(
////                  width: 80,
//                    padding: EdgeInsets.only(
//                        top: 17, bottom: 9, left: 20, right: 20),
//                    decoration: BoxDecoration(
//                        border: Border.all(
//                            color: AppColors.onboardingTextFieldBorder),
//                        borderRadius: BorderRadius.circular(15)),
//                    child: Column(
//                      children: <Widget>[
//                        Image.asset(
//                          'assets/quick_services.png',
//                          width: 30,
//                          height: 30,
//                        ),
//                        SizedBox(height: 8),
//                        Text('Services',
//                            style: TextStyle(
//                                color: AppColors.goldBgColor,
//                                fontSize: 9,
//                                fontFamily: 'MontserratSemiBold'))
//                      ],
//                    ),
//                  ),
//                ),
////                SizedBox(width: 10),
//              ],
//            ),
//          ),
//        )
      ],
    );
  }

  Widget _buildTransferItem() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Image.asset(
                'assets/bank.png',
                width: 40,
                height: 40,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Transfer funds',
              style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(height: 10),
            Text('Transfer money from account to account.',
                style: TextStyle(
                    color: AppColors.onboardingPlaceholderText, fontSize: 14)),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTransfer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Image.asset(
                'assets/money_transfer.png',
                width: 40,
                height: 40,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'View transfers',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(height: 10),
            Text('View all transfers that have been made.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.onboardingPlaceholderText, fontSize: 14)),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficiaryItem() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Image.asset(
                'assets/quick_transfer.png',
                width: 40,
                height: 40,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'View beneficiaries',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(height: 10),
            Text('View people that have been saved as beneficiaries.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.onboardingPlaceholderText, fontSize: 14)),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesItem() {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Image.asset(
                'assets/quick_services.png',
                width: 40,
                height: 40,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Services',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(height: 10),
            Text('Connect with other people using gofast.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.onboardingPlaceholderText, fontSize: 14)),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            left: 20,
            top: 30,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Transfer history',
                style: TextStyle(
                    color: AppColors.goldBgColor,
                    fontSize: 14,
                    fontFamily: 'MontserratSemiBold'),
              ),
              SizedBox(width: 10),
              Flexible(
                  child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: AppColors.onboardingTextFieldBorder))),
              ))
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHistoryItems() {
    return (_uidLoaded)
        ? StreamBuilder(
            stream: _firestore
                .collection("Users")
                .document(_firebaseUser.uid)
                .collection("Transfers")
                .limit(4)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.buttonColor))),
                );
              }
              if (snapshot.hasError) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 19),
                  height: 110,
                  child: Center(
                    child: Text(
                      'An error occurred retrieving recent transfers.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: AppColors.textColor, fontSize: 14),
                    ),
                  ),
                );
              }
              if (snapshot.hasData) {
                if (snapshot.data.documents.length > 0) {
                  List<Widget> widgetList = new List<Widget>();
                  widgetList.add(SizedBox());
                  snapshot.data.documents.forEach((key) {
                    widgetList.add(Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Transfer to ${key['accountName']}',
                                    style: TextStyle(
                                        color: AppColors
                                            .transferHistoryItemTextColor,
                                        fontSize: 14)),
                                Text(
                                  'N ${key['amount']}',
                                  style: TextStyle(
                                      color:
                                          AppColors.onboardingPlaceholderText,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: AppColors
                                            .onboardingTextFieldBorder))),
                          )
                        ],
                      ),
                    ));
                  });

                  widgetList.add(InkWell(
                    onTap: () {
                      Navigator.of(context, rootNavigator: false).push(
                        CupertinoPageRoute<bool>(
                          builder: (BuildContext context) => ViewTransfers(),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.only(right: 20, top: 10, bottom: 10),
                      child: Text('View more',
                          style: TextStyle(
                              color: AppColors.buttonColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ),
                  ));
                  return Column(children: widgetList);
                } else {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        'You have no recent transfers.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
              }
            },
          )
        : SizedBox();
  }

  void _handleLogOut() {
    _auth.signOut().then((data) {
      Preferences.dispose().then((data) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false);
      });
    });
  }

  void _showComingSoonDialog() {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          return new AlertDialog(
              content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                ListTile(
                  title: Text(
                    'Coming soon',
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ));
        } else {
          return new CupertinoAlertDialog(
              content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                ListTile(
                  title: Text(
                    'Coming soon',
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ));
        }
      },
    );
  }

  void _showSelectionDialog() {
    showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        if (Platform.isAndroid) {
          return new AlertDialog(
            title: new Text(
              'Select option',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      'Single transfer',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: false).push(
                        CupertinoPageRoute<bool>(
                          builder: (BuildContext context) => TransferMoney(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Transfer to beneficiary',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: false).push(
                        CupertinoPageRoute<bool>(
                          builder: (BuildContext context) =>
                              TransferToBeneficiary(),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          );
        } else {
          return new CupertinoAlertDialog(
              title: Text(
                'Select option',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        'Single transfer',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context, rootNavigator: false).push(
                          CupertinoPageRoute<bool>(
                            builder: (BuildContext context) => TransferMoney(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: Text(
                        'Transfer to beneficiary',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context, rootNavigator: false).push(
                          CupertinoPageRoute<bool>(
                            builder: (BuildContext context) =>
                                TransferToBeneficiary(),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ));
        }
      },
    );
  }
}
