import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      // Create user using Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential; // Return the UserCredential, which contains the User
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!cred.user!.emailVerified) {
        log("Email not verified. Sending verification email.");
        await cred.user!.sendEmailVerification();
        throw FirebaseAuthException(
          code: "email-not-verified",
          message: "Please verify your email before logging in.",
        );
      }

      return cred.user;
    } catch (e) {
      log("Error during login: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      log("Something went wrong: $e");
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = _auth.currentUser!;
      await user.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }

  Future sendPasswordResetLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
    }
  }
}
