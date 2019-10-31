import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences prefs;

//isAccountVerified



  static set phoneNumber(String phonenumber) =>
      prefs.setString("phonenumber", phonenumber);
  static get phoneNumber => prefs.getString("phonenumber") ?? '';

  static set email(String email) => prefs.setString("email", email);
  static get email => prefs.getString("email") ?? '';

  static set passWord(String passWord) => prefs.setString("passWord", passWord);
  static get passWord => prefs.getString("passWord") ?? '';

  static set username(String username) => prefs.setString("username", username);
  static get username => prefs.getString("username") ?? '';

  static set dob(String dob) => prefs.setString("dob", dob);
  static get dob => prefs.getString("dob") ?? '';

  static set firstname(String firstname) =>
      prefs.setString("firstname", firstname);
  static get firstname => prefs.getString("firstname") ?? '';

  static set lastname(String lastname) => prefs.setString("lastname", lastname);
  static get lastname => prefs.getString("lastname") ?? '';

//TODO remove the preference below
/*   static set isAccountVerified(String isAccountVerified) =>
      prefs.setString("isAccountVerified", isAccountVerified);
  static get isAccountVerified => prefs.getString("isAccountVerified") ?? ''; */

  static set profilePicture(String profilePicture) =>
      prefs.setString("profilePicture", profilePicture);
  static get profilePicture => prefs.getString("profilePicture") ?? '';

  static set fcmToken(String token) => prefs.setString("fcmToken", token);
  static get fcmToken => prefs.getString("fcmToken") ?? '';

  static set signedUpForCommunity(bool signedUpForCommunity) =>
      prefs.setBool("signedUpForCommunity", signedUpForCommunity);
  static get signedUpForCommunity =>
      prefs.getBool("signedUpForCommunity") ?? false;

  static set communityName(String communityName) =>
      prefs.setString("communityName", communityName);
  static get communityName => prefs.getString("communityName") ?? '';

  static set communityDesc(String communityDesc) =>
      prefs.setString("communityDesc", communityDesc);
  static get communityDesc => prefs.getString("communityDesc") ?? '';

  static set authId(String authId) => prefs.setString("authId", authId);
  static get authId => prefs.getString("authId") ?? '';

  static bool get isfirstTime => prefs.getBool("IsFirstTime") ?? true;

  static set isfirstTime(bool firstTimer) =>
      prefs.setBool("IsFirstTime", firstTimer);

  static set isLoggedIn(bool loggedIn) => prefs.setBool("IsLoggedIn", loggedIn);
  static bool get isLoggedIn => prefs.getBool("IsLoggedIn") ?? false;

  static set deviceId(String deviceId) => prefs.setString("deviceId", deviceId);
  static String get deviceId => prefs.getString("deviceId") ?? false;

  static set isPhysicalDevice(bool isPhysicalDevice) =>
      prefs.setBool("isPhysicalDevice", isPhysicalDevice);
  static bool get isPhysicalDevice =>
      prefs.getBool("isPhysicalDevice") ?? false;

  static set notificationAfterEachTransaction(bool value) =>
      prefs.setBool("notificationAfterTransaction", value);
  static bool get notificationAfterEachTransaction =>
      prefs.getBool("notificationAfterTransaction") ?? false;

  static set notificationAfterTransactionSuccess(bool value) =>
      prefs.setBool("notificationAfterTransactionSuccess", value);
  static bool get notificationAfterTransactionSuccess =>
      prefs.getBool("notificationAfterTransactionSuccess") ?? false;

  static set kycMessage(String kycMessage) => prefs.setString("kycMessage", kycMessage);
  static get kycMessage => prefs.getString("kycMessage") ?? '';

  static set iskycCompleted(bool iskycCompleted) =>
      prefs.setBool("iskycCompleted", iskycCompleted);
  static get iskycCompleted => prefs.getBool("iskycCompleted") ?? false;

  static set uploadedKycIdCard(String uploadedKycIdCard) =>
      prefs.setString("uploadedKycIdCard", uploadedKycIdCard);
  static get uploadedKycIdCard => prefs.getString("uploadedKycIdCard") ?? '';

  static Future<Null> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<Null> dispose() async {
    prefs.clear().then((data) {
      print("data cleared");
    });
  }
}
