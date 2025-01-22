import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/startup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management',
      home: StartupScreen(),
    );
  }
}
