import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/auth_service.dart';
import 'package:flutter_application_1/screens/login_screen.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final _email = TextEditingController();
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text(
            'Forgot Password',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              letterSpacing: 1,
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 40),

            //
            Text(
              'Enter the Email',
              style: TextStyle(fontSize: 32),
            ),
            //

            SizedBox(height: 40),

            //
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextFormField(
                    controller: _email,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 5),
                          Icon(
                            Icons.email_outlined,
                            size: 20,
                            color: Color.fromARGB(255, 124, 124, 124),
                          ),
                          SizedBox(width: 6),
                          Container(
                            width: 1.5,
                            height: 20,
                            color: Color.fromARGB(255, 124, 124, 124),
                          )
                        ],
                      ),
                      hintText: 'abc@email.com',
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 124, 124, 124),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            //

            SizedBox(height: 80),

            //
            ElevatedButton(
              onPressed: () async {
                await _auth.sendPasswordResetLink(_email.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff1f5f5b),
                fixedSize: Size(350, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Send',
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
