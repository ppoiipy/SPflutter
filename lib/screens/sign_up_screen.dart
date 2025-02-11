import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_application_1/auth/auth_service.dart';
import 'package:flutter_application_1/screens/homepage.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/JsonModels/users.dart';
import 'package:flutter_application_1/screens/wrapper.dart';
import 'package:flutter_application_1/screens/add_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _weightGoalController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _preferredFlavorsController = TextEditingController();
  final _activityLevelController = TextEditingController();

  // final FirestoreService firestoreService = FirestoreService();

  List<String> allergies = [
    'Nuts',
    'Dairy',
    'Shellfish',
    'Gluten',
    'Eggs',
    'Peanuts',
  ];

  List<String> flavors = [
    'Sweet',
    'Salty',
    'Spicy',
    'Sour',
    'Bitter',
  ];

  String? selectedGender;
  String? _selectedActivityLevel;
  String? _activityDescription;

  List<String> selectedAllergies = [];
  List<String> selectedFlavors = [];

  List<String> genderOptions = ['Male', 'Female', 'Other'];
  Map<String, String> activityLevels = {
    "Sedentary": "Little or no exercise, desk job.",
    "Lightly Active": "Light exercise or sports 1-3 days per week.",
    "Moderately Active": "Moderate exercise or sports 3-5 days per week.",
    "Very Active": "Hard exercise or sports 6-7 days per week.",
    "Super Active": "Very hard exercise or physical job, training twice a day.",
  };

  String? emailError;
  bool _isPasswordState = false;

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
    // _preferredFlavorsController.dispose();
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
          .doc(userCredential.user!.uid) // Using the UID as document ID
          .set({
        'email': userCredential.user!.email,
        'weight': weight, // Store as number
        'height': height, // Store as number
        'dob': _dobController.text,
        'gender': selectedGender,
        'weightGoal': weightGoal, // Store as number
        // 'allergies': _allergiesController.text,
        'allergies': selectedAllergies,
        'preferredFlavors': selectedFlavors,
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                hintText: 'Enter your weight',
              ),
            ),
            SizedBox(height: 10),

            // Weight Goal
            TextFormField(
              controller: _weightGoalController,
              decoration: InputDecoration(
                labelText: 'Weight Goal (kg)',
                hintText: 'Enter your weight goal',
              ),
            ),
            SizedBox(height: 10),

            // Height
            TextFormField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                hintText: 'Enter your height',
              ),
            ),
            SizedBox(height: 10),

            // Date of Birth
            TextFormField(
              controller: _dobController,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                hintText: 'Select your date of birth',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                FocusScope.of(context)
                    .requestFocus(FocusNode()); // to hide keyboard
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
              readOnly: true, // Disable keyboard input to prevent manual typing
            ),
            SizedBox(height: 10),

            // Gender
            // TextFormField(
            //   controller: _genderController,
            //   decoration: InputDecoration(
            //     labelText: 'Gender',
            //     hintText: 'Enter your gender',
            //   ),
            // ),

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
                    if (value == null) {
                      return 'Please select a gender';
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
                    prefixIcon: Icon(Icons.person, size: 20),
                    hintText: 'Select gender',
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Allergies
            TextFormField(
              controller:
                  TextEditingController(text: selectedAllergies.join(', ')),
              readOnly: true, // Prevent manual input
              decoration: InputDecoration(
                labelText: 'Allergies',
                hintText: 'Select your allergies',
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              onTap: _showAllergySheet, // Opens the bottom sheet on tap
            ),
            SizedBox(height: 10),

            // Preferred Flavors
            TextFormField(
              controller:
                  TextEditingController(text: selectedFlavors.join(', ')),
              readOnly: true, // Prevent manual input
              decoration: InputDecoration(
                labelText: 'Flavors',
                hintText: 'Select your flavors',
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              onTap: _showFlavorSheet, // Opens the bottom sheet on tap
            ),
            SizedBox(height: 10),

            // Activity Level
            // TextFormField(
            //   controller: _activityLevelController,
            //   decoration: InputDecoration(
            //     labelText: 'Activity Level',
            //     hintText: 'Enter your activity level',
            //   ),
            // ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 10.0), // Prevent overflow
                  child: DropdownButtonFormField<String>(
                    value: _selectedActivityLevel,
                    items: activityLevels.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedActivityLevel = value;
                        _activityDescription = activityLevels[value];
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Select your activity level',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 10.0), // Increase vertical padding
                    ),
                    isDense:
                        false, // Ensure there is more space in the dropdown
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an activity level';
                      }
                      return null;
                    },
                  ),
                ),

                // Show selected description
                // if (_selectedActivityLevel != null)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 10.0),
                //     child: Text(
                //       'Description: $_activityDescription',
                //       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                //     ),
                //   ),
              ],
            ),

            SizedBox(height: 20),

            // Create Account Button
            ElevatedButton(
              onPressed: _signUp,
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
                        children: allergies.map((allergy) {
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
                    child: Text('Done'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFlavorSheet() {
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
                    'Select Preferred Flavors',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: flavors.map((flavor) {
                          return CheckboxListTile(
                            title: Text(flavor),
                            value: selectedFlavors.contains(flavor),
                            onChanged: (bool? value) {
                              setSheetState(() {
                                if (value == true) {
                                  selectedFlavors.add(flavor);
                                } else {
                                  selectedFlavors.remove(flavor);
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
                    child: Text('Done'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
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

// class SignUpFieldState extends State<SignUpField> {
//   final formKey = GlobalKey<FormState>();
//   final _auth = AuthService();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _weightController = TextEditingController();
//   final _heightController = TextEditingController();
//   final _dobController = TextEditingController();
//   final _genderController = TextEditingController();
//   final _weightGoalController = TextEditingController();
//   final _allergiesController = TextEditingController();
//   final _preferredFlavorsController = TextEditingController();
//   final _activityLevelController = TextEditingController();
//   String? emailError;

//   bool _isPasswordState = false;

//   void dispose() {
//     super.dispose();
//     _email.dispose();
//     _password.dispose();
//   }

//   void _togglePasswordField() {
//     setState(() {
//       _isPasswordState = !_isPasswordState;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: formKey,
//       child: Column(
//         children: [
//           // Email
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Email',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               TextFormField(
//                 controller: _email,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Email is required';
//                   }
//                   return null;
//                 },
//                 decoration: InputDecoration(
//                   prefixIcon: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(width: 5),
//                       Icon(
//                         Icons.email_outlined,
//                         size: 20,
//                         color: Color.fromARGB(255, 124, 124, 124),
//                       ),
//                       SizedBox(width: 6),
//                       Container(
//                         width: 1.5,
//                         height: 20,
//                         color: Color.fromARGB(255, 124, 124, 124),
//                       )
//                     ],
//                   ),
//                   hintText: 'abc@email.com',
//                   hintStyle: TextStyle(
//                     color: Color.fromARGB(255, 124, 124, 124),
//                   ),
//                   contentPadding: EdgeInsets.symmetric(vertical: 10),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),

//           // Password
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Password',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               TextFormField(
//                 obscureText: !_isPasswordState,
//                 controller: _password,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Password is required';
//                   }
//                   return null;
//                 },
//                 decoration: InputDecoration(
//                   prefixIcon: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(width: 5),
//                       Icon(
//                         Icons.lock_outline,
//                         size: 20,
//                         color: Color.fromARGB(255, 124, 124, 124),
//                       ),
//                       SizedBox(width: 6),
//                       Container(
//                         width: 1.5,
//                         height: 20,
//                         color: Color.fromARGB(255, 124, 124, 124),
//                       ),
//                     ],
//                   ),
//                   suffixIcon: IconButton(
//                     onPressed: _togglePasswordField,
//                     icon: Icon(
//                       _isPasswordState
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                     ),
//                   ),
//                   hintText: '********',
//                   hintStyle: TextStyle(
//                     color: Color.fromARGB(255, 124, 124, 124),
//                   ),
//                   contentPadding: EdgeInsets.symmetric(vertical: 12),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),

//           // Confirm Password
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Confirm Password',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               TextFormField(
//                 obscureText: !_isPasswordState,
//                 controller: confirmPassword,
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Password is required';
//                   } else if (_password.text != confirmPassword.text) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//                 decoration: InputDecoration(
//                   prefixIcon: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(width: 5),
//                       Icon(
//                         Icons.lock_outline,
//                         size: 20,
//                         color: Color.fromARGB(255, 124, 124, 124),
//                       ),
//                       SizedBox(width: 6),
//                       Container(
//                         width: 1.5,
//                         height: 20,
//                         color: Color.fromARGB(255, 124, 124, 124),
//                       ),
//                     ],
//                   ),
//                   suffixIcon: IconButton(
//                     onPressed: _togglePasswordField,
//                     icon: Icon(
//                       _isPasswordState
//                           ? Icons.visibility
//                           : Icons.visibility_off,
//                     ),
//                   ),
//                   hintText: '********',
//                   hintStyle: TextStyle(
//                     color: Color.fromARGB(255, 124, 124, 124),
//                   ),
//                   contentPadding: EdgeInsets.symmetric(vertical: 12),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),

//           // Create Account Button
//           ElevatedButton(
//             onPressed: _signup,
//             // onPressed: () async {
//             //   if (formKey.currentState!.validate()) {
//             //     final db = DatabaseHelper();
//             //     bool emailExists = await db.checkEmailExists(email.text);
//             //     if (emailExists) {
//             //       setState(() {
//             //         emailError = 'Email is already in use';
//             //       });
//             //     } else {
//             //       await db.signup(_email.text, _password.text);
//             //       Navigator.pushReplacement(
//             //         context,
//             //         MaterialPageRoute(
//             //             builder: (context) => Homepage(
//             //                 user: Users(
//             //                     usrEmail: email.text,
//             //                     usrPassword: password.text))),
//             //       );
//             //     }
//             //   }
//             // },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Color(0xff1f5f5b),
//               fixedSize: Size(350, 50),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: Text(
//               'Create an Account',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 17,
//               ),
//             ),
//           ),
//           if (emailError != null)
//             Text(
//               emailError!,
//               style: TextStyle(color: Colors.red),
//             ),
//         ],
//       ),
//     );
//   }

//   Future<void> _signUp() async {
//     try {
//       // Sign up the user
//       UserCredential userCredential =
//           await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text,
//         password: _passwordController.text,
//       );

//       // Get the user from the userCredential
//       User? user = userCredential.user;
//       if (user != null) {
//         log('User Created Successfully');

//         // Saving the additional user details to Firestore
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'email': user.email,
//           'weight': _weightController.text,
//           'height': _heightController.text,
//           'dob': _dobController.text,
//           'gender': _genderController.text,
//           'weightGoal': _weightGoalController.text,
//           'allergies': _allergiesController.text,
//           'preferredFlavors': _preferredFlavorsController.text,
//           'activityLevel': _activityLevelController.text,
//         });

//         // Navigate to the next screen
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => UserDetailScreen(user: user),
//           ),
//         );
//       }
//     } catch (e) {
//       log('Error: $e');
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_application_1/screens/homepage.dart';

// class SignUpScreen extends StatefulWidget {
//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _weightController = TextEditingController();
//   final _heightController = TextEditingController();
//   final _dobController = TextEditingController();
//   final _genderController = TextEditingController();
//   final _weightGoalController = TextEditingController();
//   final _allergiesController = TextEditingController();
//   final _preferredFlavorsController = TextEditingController();
//   final _activityLevelController = TextEditingController();

//   final SignUpService _signUpService = SignUpService();
//   String? errorMessage;

//   void _signUp() async {
//     String? result = await _signUpService.signUp(
//       email: _emailController.text,
//       password: _passwordController.text,
//       confirmPassword: _confirmPasswordController.text,
//       weight: _weightController.text,
//       height: _heightController.text,
//       dob: _dobController.text,
//       gender: _genderController.text,
//       weightGoal: _weightGoalController.text,
//       allergies: _allergiesController.text,
//       preferredFlavors: _preferredFlavorsController.text,
//       activityLevel: _activityLevelController.text,
//     );

//     if (result != null) {
//       setState(() {
//         errorMessage = result;
//       });
//     } else {
//       // Handle successful sign up (navigate to the next screen or show success message)
//       Navigator.push(
//           context, MaterialPageRoute(builder: (context) => Homepage()));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Sign Up")),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                   controller: _emailController,
//                   decoration: InputDecoration(labelText: "Email")),
//               TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: InputDecoration(labelText: "Password")),
//               TextField(
//                   controller: _confirmPasswordController,
//                   obscureText: true,
//                   decoration: InputDecoration(labelText: "Confirm Password")),
//               TextField(
//                   controller: _weightController,
//                   decoration: InputDecoration(labelText: "Weight")),
//               TextField(
//                   controller: _heightController,
//                   decoration: InputDecoration(labelText: "Height")),
//               TextField(
//                   controller: _dobController,
//                   decoration: InputDecoration(labelText: "Date of Birth")),
//               TextField(
//                   controller: _genderController,
//                   decoration: InputDecoration(labelText: "Gender")),
//               TextField(
//                   controller: _weightGoalController,
//                   decoration: InputDecoration(labelText: "Weight Goal")),
//               TextField(
//                   controller: _allergiesController,
//                   decoration: InputDecoration(labelText: "Allergies")),
//               TextField(
//                   controller: _preferredFlavorsController,
//                   decoration: InputDecoration(labelText: "Preferred Flavors")),
//               TextField(
//                   controller: _activityLevelController,
//                   decoration: InputDecoration(labelText: "Activity Level")),
//               SizedBox(height: 20),
//               ElevatedButton(onPressed: _signUp, child: Text("Sign Up")),
//               if (errorMessage != null) ...[
//                 SizedBox(height: 10),
//                 Text(errorMessage!, style: TextStyle(color: Colors.red)),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SignUpService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Function to sign up and store user data
//   Future<String?> signUp({
//     required String email,
//     required String password,
//     required String confirmPassword,
//     required String weight,
//     required String height,
//     required String dob,
//     required String gender,
//     required String weightGoal,
//     required String allergies,
//     required String preferredFlavors,
//     required String activityLevel,
//   }) async {
//     if (password != confirmPassword) {
//       return 'Passwords do not match';
//     }

//     try {
//       User? user = _auth.currentUser;

//       // Create user if not authenticated
//       if (user == null) {
//         UserCredential userCredential =
//             await _auth.createUserWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//         user = userCredential.user;
//       }

//       // Store user data in Firestore
//       await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
//         'email': user.email,
//         'weight': weight,
//         'height': height,
//         'dob': dob,
//         'gender': gender,
//         'weightGoal': weightGoal,
//         'allergies': allergies,
//         'preferredFlavors': preferredFlavors,
//         'activityLevel': activityLevel,
//       });

//       return null;
//     } catch (e) {
//       print('Error: $e'); // Print detailed error
//       return 'Error: ${e.toString()}';
//     }
//   }
// }
