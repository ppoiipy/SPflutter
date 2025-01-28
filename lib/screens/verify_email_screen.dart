import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/JsonModels/users.dart';
import 'package:flutter_application_1/auth/auth_service.dart';
import 'package:flutter_application_1/screens/homepage.dart';
import 'package:flutter_application_1/screens/wrapper.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;

  final _auth = AuthService();
  late Timer timer;

  void initState() {
    super.initState();

    // User needs to be created before
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      _auth.sendVerificationEmail();
    }

    timer = Timer.periodic(const Duration(seconds: 5), (time) {
      FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified == true) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Wrapper()));
      }
    });
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? Homepage()
      : Scaffold(
          body: Column(
          children: [
            Text('We have sent an email verification.'),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  _auth.sendVerificationEmail();
                },
                child: Text(
                  'Resend Verification',
                  style: const TextStyle(fontSize: 18),
                )),
          ],
        ));
}
