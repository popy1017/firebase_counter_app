import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_button/sign_button.dart';
import 'package:special_counter_app/helpers/firestore_helper.dart';

class AuthModel extends ChangeNotifier {
  User _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthModel() {
    final User _currentUser = _auth.currentUser;

    if (_currentUser != null) {
      _user = _currentUser;
      notifyListeners();
    }
  }

  User get user => _user;
  bool get loggedIn => _user != null;

  Future<bool> login(ButtonType type) async {
    FirebaseCrashlytics.instance.log("Login: ${type.toString()}");

    if (type != ButtonType.google) {
      throw UnimplementedError(
        'Unimplemented login button was tapped.: ${type.toString()}',
      );
    }

    try {
      UserCredential _userCredential = await _signInWithGoogle();
      await FirestoreHelper.instance.createCounter(_userCredential.user.uid);
      _user = _userCredential.user;
      notifyListeners();
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  Future<void> logout() async {
    FirebaseCrashlytics.instance.log("Logout");
    _user = null;
    await _auth.signOut();
    await _signOutWithGoogle();
    notifyListeners();
  }

  Future<UserCredential> _signInWithGoogle() async {
    FirebaseCrashlytics.instance.log("Login with google");

    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> _signOutWithGoogle() async {
    FirebaseCrashlytics.instance.log("Logout with google");
    await GoogleSignIn().signOut();
  }
}
