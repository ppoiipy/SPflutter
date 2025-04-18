import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ginraidee/auth/auth_service.dart';
import 'package:ginraidee/screens/homepage.dart';
import 'package:ginraidee/screens/wrapper.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'Unknown User';

  final _auth = AuthService();
  late Timer timer;

  @override
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
          body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Verify your email address',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              Text(
                'Click the link in the email we just sent to your email ',
                textAlign: TextAlign.center,
              ),
              Text(
                userEmail,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xff1f5f5b)),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  _auth.sendVerificationEmail();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff1f5f5b)),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Text(
                    'Resend Verification Email',
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ));
}
