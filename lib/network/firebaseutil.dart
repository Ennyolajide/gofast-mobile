import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseService {
  Future<FirebaseUser> signIn(String email, String password);
  Future<FirebaseUser> signUp(String email, String password);
  Future<String> getCurrentUser();
  Future<void> signOut();
}

class FirebaseService implements BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<String> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user.uid;
  }

  @override
  Future<FirebaseUser> signIn(String email, String password) async {
    FirebaseUser user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    return user;
  }

  @override
  Future<FirebaseUser> signUp(String email, String password) async {
    FirebaseUser user;
    try {
      FirebaseUser user = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print("Error-------->: ${e.message}");
    }
    return user;
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }
}
