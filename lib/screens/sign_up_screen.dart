import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:ginraidee/auth/auth_service.dart';
import 'package:ginraidee/screens/login_screen.dart';
import 'package:ginraidee/screens/wrapper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _weightGoalController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _activityLevelController = TextEditingController();

  // final FirestoreService firestoreService = FirestoreService();

  List<String> foodIngredient = [
    'None',
    'Chicken',
    'Beef',
    'Pork',
    'Fish',
    'Tofu',
    'Rice',
    'Pasta',
    'Tomato',
    'Cheese',
    'Milk',
    'Egg',
    'Garlic',
    'Onion',
    'Carrot',
    'Potato',
    'Mushroom',
    'Broccoli',
    'Spinach',
    'Peanut',
    'Soy Sauce',
    'Olive Oil'
  ];
  List<String> foodAllergy = [
    'None',
    'Nuts',
    'Milk',
    'Celery',
    'Fish',
    'Shellfish',
    'Mustard',
    'Gluten',
    'Soy',
    'Eggs',
    'Sesame',
    'Wheat',
    'Alcohol',
  ];
  List<String> foodCategory = [
    'None',
    'American',
    'Italian',
    'Japanese',
    'Chinese',
    'Thai',
  ];

  String? selectedGender;
  String? _selectedActivityLevel;
  // String? _activityDescription;

  List<String> selectedIngredients = [];
  List<String> selectedAllergies = [];
  List<String> selectedCategories = [];

  List<String> genderOptions = ['Male', 'Female', 'Other'];
  Set<String> activityLevels = {
    "Sedentary (little to no exercise)",
    "Lightly active (1-3 days/week)",
    "Moderately active (3-5 days/week)",
    "Very active (6-7 days/week)",
    "Super active (very hard exercise, physical job)"
  };

  String? emailError;
  bool _isPasswordState = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    // _weightController.dispose();
    // _heightController.dispose();
    // _dobController.dispose();
    // _genderController.dispose();
    // _weightGoalController.dispose();
    // _allergiesController.dispose();
    // _activityLevelController.dispose();
  }

  void _togglePasswordField() {
    setState(() {
      _isPasswordState = !_isPasswordState;
    });
  }

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<void> _signUp() async {
    try {
      // Create user with email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      // Log the UID to make sure it's correct
      log('User UID: ${userCredential.user!.uid}');

      // Convert text inputs to numbers for weight, height, and weightGoal
      double weight = double.tryParse(_weightController.text) ?? 0.0;
      double height = double.tryParse(_heightController.text) ?? 0.0;
      double weightGoal = double.tryParse(_weightGoalController.text) ?? 0.0;

      // Save user details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email,
        'weight': weight,
        'height': height,
        'dob': _dobController.text,
        'gender': selectedGender,
        'weightGoal': weightGoal,
        // 'allergies': _allergiesController.text,
        'foodIngredient': selectedIngredients,
        'foodAllergy': selectedAllergies,
        'foodCategory': selectedCategories,
        'activityLevel': _selectedActivityLevel,
      }).then((_) {
        log('User details saved to Firestore');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Wrapper()), // Navigate after successful registration
        );
      }).catchError((e) {
        log('Error saving user details to Firestore: $e');
      });
    } catch (e) {
      // Catch and log the error if something goes wrong
      log('Error: $e');
      if (e is FirebaseException) {
        log('Firebase Error: ${e.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Make the entire form scrollable
      child: Form(
        key: formKey,
        child: Column(
          children: [
            // Email
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                        Icon(Icons.email_outlined,
                            size: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                        SizedBox(width: 6),
                        Container(
                            width: 1.5,
                            height: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                      ],
                    ),
                    hintText: 'abc@email.com',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 124, 124, 124)),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                        Icon(Icons.lock_outline,
                            size: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                        SizedBox(width: 6),
                        Container(
                            width: 1.5,
                            height: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                      ],
                    ),
                    suffixIcon: IconButton(
                      onPressed: _togglePasswordField,
                      icon: Icon(_isPasswordState
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    hintText: '********',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 124, 124, 124)),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                TextFormField(
                  obscureText: !_isPasswordState,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password is required';
                    } else if (_passwordController.text !=
                        _confirmPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.lock_outline,
                            size: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                        SizedBox(width: 6),
                        Container(
                            width: 1.5,
                            height: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                      ],
                    ),
                    suffixIcon: IconButton(
                      onPressed: _togglePasswordField,
                      icon: Icon(_isPasswordState
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    hintText: '********',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 124, 124, 124)),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Weight
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weight (kg)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                TextFormField(
                  controller: _weightController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Weight is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.monitor_weight_outlined,
                            size: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                        SizedBox(width: 6),
                        Container(
                            width: 1.5,
                            height: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                      ],
                    ),
                    hintText: 'Enter your weight',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 124, 124, 124)),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Weight Goal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weight Goal (kg)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                TextFormField(
                  controller: _weightGoalController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Weight Goal is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.flag_outlined,
                            size: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                        SizedBox(width: 6),
                        Container(
                            width: 1.5,
                            height: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                      ],
                    ),
                    hintText: 'Enter your weight goal',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 124, 124, 124)),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Height
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Height (cm)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                TextFormField(
                  controller: _heightController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Height is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.height_outlined,
                            size: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                        SizedBox(width: 6),
                        Container(
                            width: 1.5,
                            height: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                      ],
                    ),
                    hintText: 'Enter your height',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 124, 124, 124)),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Date of Birth
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date of Birth',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                TextFormField(
                  controller: _dobController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Birth Date is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.cake_outlined,
                            size: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                        SizedBox(width: 6),
                        Container(
                            width: 1.5,
                            height: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                      ],
                    ),
                    suffixIcon: Icon(Icons.calendar_today,
                        size: 20, color: Color.fromARGB(255, 124, 124, 124)),
                    hintText: 'Select your date of birth',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 124, 124, 124)),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      setState(() {
                        _dobController.text = formattedDate;
                      });
                    }
                  },
                  readOnly: true,
                ),
              ],
            ),
            SizedBox(height: 10),

            // Gender
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  onChanged: (newValue) {
                    setState(() {
                      selectedGender = newValue!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Gender is required';
                    }
                    return null;
                  },
                  items: genderOptions.map((gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outlined,
                        size: 20, color: Color.fromARGB(255, 124, 124, 124)),
                    hintText: 'Gender',
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Ingredients
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                TextFormField(
                  controller: TextEditingController(
                      text: selectedIngredients.join(', ')),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select ingredients';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.kitchen_outlined,
                            size: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                        SizedBox(width: 6),
                        Container(
                            width: 1.5,
                            height: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                      ],
                    ),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                    hintText: 'Select your ingredients',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 124, 124, 124)),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onTap: _showIngredientSheet,
                ),
              ],
            ),
            SizedBox(height: 10),

            // Allergies
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Allergies',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                TextFormField(
                  controller:
                      TextEditingController(text: selectedAllergies.join(', ')),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select allergies';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.warning_outlined,
                            size: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                        SizedBox(width: 6),
                        Container(
                            width: 1.5,
                            height: 20,
                            color: Color.fromARGB(255, 124, 124, 124)),
                      ],
                    ),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                    hintText: 'Select your allergies',
                    hintStyle:
                        TextStyle(color: Color.fromARGB(255, 124, 124, 124)),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onTap: _showAllergySheet,
                ),
              ],
            ),
            SizedBox(height: 10),

            // Category / Cuisine Types
            TextFormField(
              controller:
                  TextEditingController(text: selectedCategories.join(', ')),
              readOnly: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select cuisine types';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Cuisine Types',
                hintText: 'Select your cuisine types',
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 6),
                    Icon(Icons.restaurant_menu_outlined,
                        size: 20, color: Color.fromARGB(255, 124, 124, 124)),
                    SizedBox(width: 5),
                    Container(
                        width: 1.5,
                        height: 20,
                        color: Color.fromARGB(255, 124, 124, 124)),
                    SizedBox(width: 5),
                  ],
                ),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              onTap: _showCuisineSheet,
            ),
            SizedBox(height: 10),

            // Activity Level
            DropdownButtonFormField<String>(
              value: _selectedActivityLevel,
              items: activityLevels.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry,
                  child: Text(
                    entry,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedActivityLevel = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Activity Level',
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 6),
                    Icon(Icons.fitness_center_outlined,
                        size: 20, color: Color.fromARGB(255, 124, 124, 124)),
                    SizedBox(width: 5),
                    Container(
                        width: 1.5,
                        height: 20,
                        color: Color.fromARGB(255, 124, 124, 124)),
                    SizedBox(width: 5),
                  ],
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
              ),
              isDense: false,
              validator: (value) {
                if (value == null) {
                  return 'Please select an activity level';
                }
                return null;
              },
            ),

            SizedBox(height: 20),

            // Create Account Button
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _signUp();
                }
              },
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
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showIngredientSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Ingredients',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: foodIngredient.map((ingredient) {
                          return CheckboxListTile(
                            title: Text(ingredient),
                            value: selectedIngredients.contains(ingredient),
                            onChanged: (bool? value) {
                              setSheetState(() {
                                if (value == true) {
                                  selectedIngredients.add(ingredient);
                                } else {
                                  selectedIngredients.remove(ingredient);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAllergySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Allergies',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: foodAllergy.map((allergy) {
                          return CheckboxListTile(
                            title: Text(allergy),
                            value: selectedAllergies.contains(allergy),
                            onChanged: (bool? value) {
                              setSheetState(() {
                                if (value == true) {
                                  selectedAllergies.add(allergy);
                                } else {
                                  selectedAllergies.remove(allergy);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCuisineSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Cuisine Types',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: foodCategory.map((cuisine) {
                          return CheckboxListTile(
                            title: Text(cuisine),
                            value: selectedCategories.contains(cuisine),
                            onChanged: (bool? value) {
                              setSheetState(() {
                                if (value == true) {
                                  selectedCategories.add(cuisine);
                                } else {
                                  selectedCategories.remove(cuisine);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text('Done'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
