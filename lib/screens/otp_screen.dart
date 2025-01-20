import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('data'),
            Center(
              child: Text('OTP Verification'),
            ),
          ],
        ),
      ),
    );
  }
}
