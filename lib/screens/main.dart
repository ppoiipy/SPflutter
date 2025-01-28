import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/startup_screen.dart';
import 'package:flutter_application_1/screens/homepage.dart';
import 'package:flutter_application_1/screens/sign_up_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/screens/verify_email_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: StreamBuilder<User?>(
    //     stream: FirebaseAuth.instance.authStateChanges(),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         return VerifyEmailScreen();
    //       } else {
    //         return SignUpScreen();
    //       }
    //     },
    //   ),
    // );
    return MaterialApp(
      title: 'User Management',
      home: StartupScreen(),
    );
  }
}
