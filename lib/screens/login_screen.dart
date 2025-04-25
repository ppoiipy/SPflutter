import 'package:flutter/material.dart';

import 'dart:developer';

// import 'package:flutter_application_1/SQLite/sqlite.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ginraidee/screens/wrapper.dart';
import 'package:ginraidee/screens/forget_pass_screen.dart';
import 'package:ginraidee/screens/sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(children: [
          TopBarWidget(),
          Flexible(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                children: [
                  Container(
                    height: 370,
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
                              SizedBox(height: 30),
                              LoginField(),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Don't have an Account? "),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignUpScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Sign up',
                                      style: TextStyle(
                                        color: Color(0xff4D7881),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(150, -160),
                    child: Image.asset(
                      'assets/images/Jake-removebg-preview.png',
                      width: 210,
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
          offset: Offset(MediaQuery.of(context).size.width * -0.1, -10),
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

        // Green Rounded Rectangle (Middle)
        Transform.rotate(
          angle: 0.2,
          child: Transform.translate(
            offset: Offset(MediaQuery.of(context).size.width * -0.05, -40),
            child: Container(
              height: 160,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(80),
                color: Color(0xff1f5f5b),
              ),
            ),
          ),
        ),

        // White Rounded Rectangle (Right)
        Transform.rotate(
          angle: 0.2,
          child: Transform.translate(
            offset: Offset(MediaQuery.of(context).size.width * 0.1, -40),
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
                width: MediaQuery.of(context).size.width * 0.9,
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
              'Login',
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

class LoginField extends StatefulWidget {
  const LoginField({super.key});

  @override
  LoginFieldState createState() => LoginFieldState();
}

class LoginFieldState extends State<LoginField> {
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoginTrue = false;

  bool _isPasswordState = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Email Field
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
                controller: _emailController,
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

          // Password Field
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
                controller: _passwordController,
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

          // Forget Password
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgetPassScreen()));
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                    color: Color(0xFF4D7881), fontWeight: FontWeight.w600),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Login Button
          ElevatedButton(
            onPressed: _login,
            // onPressed: () async {
            //   if (formKey.currentState!.validate()) {
            //     final db = DatabaseHelper();
            //     bool success = await db.login(email.text, password.text);
            //     if (success) {
            //       Navigator.pushReplacement(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => Homepage(
            //                 user: Users(
            //                     usrEmail: email.text,
            //                     usrPassword: password.text))),
            //       );
            //     } else {
            //       setState(() {
            //         isLoginTrue = true;
            //       });
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
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ),
          isLoginTrue
              ? Text(
                  "Email or password is incorrect",
                  style: TextStyle(color: Colors.red),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Check if the email is verified
      if (userCredential.user != null && userCredential.user!.emailVerified) {
        log('User logged in successfully');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Wrapper()));
      } else {
        log('Email is not verified');
        await userCredential.user!.sendEmailVerification();
        log('Verification email sent again');

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Email not verified'),
            content:
                Text('Please verify your email address before logging in.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      log('Error during login: $e');
    }
  }
}
