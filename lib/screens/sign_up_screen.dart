import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_application_1/auth/auth_service.dart';
import 'package:flutter_application_1/screens/homepage.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/JsonModels/users.dart';
import 'package:flutter_application_1/screens/wrapper.dart';
// import 'package:flutter_application_1/SQLite/sqlite.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(children: [
          // Top Bar
          TopBarWidget(),
          // Email Field
          Flexible(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                children: [
                  Container(
                    height: 520,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        child: Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            children: [
                              SizedBox(height: 25),
                              // Sign up Field
                              SignUpField(),
                              SizedBox(height: 20),
                              // Go Login
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Already have an Account? "),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Color(0xff4D7881),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(190, -150),
                    child: Image.asset(
                      'assets/images/ez-removebg.png',
                      width: 180,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class TopBarWidget extends StatefulWidget {
  const TopBarWidget({super.key});

  @override
  TopBarWidgetState createState() => TopBarWidgetState();
}

class TopBarWidgetState extends State<TopBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: Offset(-40, -10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 2,
                )
              ],
            ),
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Transform.rotate(
          angle: 0.2,
          child: Transform.translate(
            offset: Offset(-20, -40),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(80),
              ),
              child: Container(
                height: 160,
                width: 370,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(80),
                  color: Color(0xff1f5f5b),
                ),
              ),
            ),
          ),
        ),
        Transform.rotate(
          angle: 0.2,
          child: Transform.translate(
            offset: Offset(35, -40),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(80),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 2,
                  )
                ],
              ),
              child: Container(
                height: 160,
                width: 370,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(80),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              'Sign up',
              style: TextStyle(
                fontSize: 33,
                fontFamily: 'InriaSans',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SignUpField extends StatefulWidget {
  const SignUpField({super.key});

  @override
  SignUpFieldState createState() => SignUpFieldState();
}

class SignUpFieldState extends State<SignUpField> {
  final formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final confirmPassword = TextEditingController();
  String? emailError;

  bool _isPasswordState = false;

  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  void _togglePasswordField() {
    setState(() {
      _isPasswordState = !_isPasswordState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Email
          Column(
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
          SizedBox(height: 10),

          // Password
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                obscureText: !_isPasswordState,
                controller: _password,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 5),
                      Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: Color.fromARGB(255, 124, 124, 124),
                      ),
                      SizedBox(width: 6),
                      Container(
                        width: 1.5,
                        height: 20,
                        color: Color.fromARGB(255, 124, 124, 124),
                      ),
                    ],
                  ),
                  suffixIcon: IconButton(
                    onPressed: _togglePasswordField,
                    icon: Icon(
                      _isPasswordState
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  hintText: '********',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 124, 124, 124),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          // Confirm Password
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextFormField(
                obscureText: !_isPasswordState,
                controller: confirmPassword,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password is required';
                  } else if (_password.text != confirmPassword.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 5),
                      Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: Color.fromARGB(255, 124, 124, 124),
                      ),
                      SizedBox(width: 6),
                      Container(
                        width: 1.5,
                        height: 20,
                        color: Color.fromARGB(255, 124, 124, 124),
                      ),
                    ],
                  ),
                  suffixIcon: IconButton(
                    onPressed: _togglePasswordField,
                    icon: Icon(
                      _isPasswordState
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  hintText: '********',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 124, 124, 124),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Create Account Button
          ElevatedButton(
            onPressed: _signup,
            // onPressed: () async {
            //   if (formKey.currentState!.validate()) {
            //     final db = DatabaseHelper();
            //     bool emailExists = await db.checkEmailExists(email.text);
            //     if (emailExists) {
            //       setState(() {
            //         emailError = 'Email is already in use';
            //       });
            //     } else {
            //       await db.signup(_email.text, _password.text);
            //       Navigator.pushReplacement(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => Homepage(
            //                 user: Users(
            //                     usrEmail: email.text,
            //                     usrPassword: password.text))),
            //       );
            //     }
            //   }
            // },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff1f5f5b),
              fixedSize: Size(350, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Create an Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ),
          if (emailError != null)
            Text(
              emailError!,
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  _signup() async {
    final user =
        await _auth.createUserWithEmailAndPassword(_email.text, _password.text);
    if (user != null) {
      log('User Created Successfully');
      Navigator.push(
          context,
          MaterialPageRoute(
              // builder: (context) => Homepage(
              //     user: Users(
              //         usrEmail: _email.text, usrPassword: _password.text))));
              builder: (context) => Wrapper()));
    }
  }
}
