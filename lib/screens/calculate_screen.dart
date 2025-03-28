import 'package:flutter/material.dart';
import 'package:flutter_application_1/SQLite/sqlite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'homepage.dart';
import 'menu_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';

class CalculateScreen extends StatefulWidget {
  @override
  _CalculateScreenState createState() => _CalculateScreenState();
}

class _CalculateScreenState extends State<CalculateScreen> {
  final int _currentIndex = 3;

  String? _selectedGender;
  String? _selectedActivityLevel;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> activityLevels = [
    "Sedentary (little to no exercise)",
    "Lightly active (1-3 days/week)",
    "Moderately active (3-5 days/week)",
    "Very active (6-7 days/week)",
    "Super active (very hard exercise, physical job)"
  ];

  double? _bmi, _bmr, _tdee;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Activity level multipliers
  final Map<String, double> _activityMultipliers = {
    'Sedentary (little to no exercise)': 1.2,
    'Lightly active (1-3 days/week)': 1.375,
    'Moderately active (3-5 days/week)': 1.55,
    'Very active (6-7 days/week)': 1.725,
    'Super active (very hard exercise, physical job)': 1.9,
  };

  String _selectedCalculation = 'BMI'; // Default calculation type

  void _calculateAndStore() async {
    final gender = _selectedGender;
    final age = int.tryParse(_ageController.text);
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final activityLevel = _selectedActivityLevel;

    if (gender == null ||
        (height == null || weight == null) ||
        (_selectedCalculation == 'BMR' && age == null) ||
        (_selectedCalculation == 'TDEE' && activityLevel == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill out all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      // based on International System of Units (SI) formula
      // Calculate BMI
      if (_selectedCalculation == 'BMI') {
        _bmi = weight / ((height / 100) * (height / 100));
      }

      // based on the Mifflin-St Jeor Formula
      // Calculate BMR
      if (_selectedCalculation == 'BMR') {
        if (gender == 'Male') {
          // _bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age!);
          _bmr = (9.99 * weight) + (6.25 * height) - (4.92 * age!) + 5;
        } else {
          // _bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age!);
          _bmr = (9.99 * weight) + (6.25 * height) - (4.92 * age!) - 161;
        }
      }

      // based on the Mifflin-St Jeor Formula
      // Calculate TDEE
      if (_selectedCalculation == 'TDEE') {
        if (gender == 'Male') {
          _bmr = (9.99 * weight) + (6.25 * height) - (4.92 * age!) + 5;
        } else {
          _bmr = (9.99 * weight) + (6.25 * height) - (4.92 * age!) - 161;
        }
        _tdee = _bmr! * _activityMultipliers[activityLevel]!;
      }

      print("BMI: $_bmi");
      print("BMR: $_bmr");
      print("TDEE: $_tdee");
    });

    // Save to SQLite
    await _dbHelper.insertCalculation({
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'bmi': _bmi,
      'bmr': _bmr,
      'tdee': _tdee,
      'activityLevel': activityLevel,
    });
  }

  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  Future<void> _loadUserData() async {
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;

          String dobString = userData?["dob"] ?? '';
          // _genderController.text = userData?["gender"] ?? '';
          _weightController.text = userData?["weight"].toString() ?? '';
          _heightController.text = userData?["height"].toString() ?? '';

          // #1
          // _selectedGender =
          //     (userData != null && genders.contains(userData!["gender"]))
          //         ? userData!["gender"]
          //         : null;

          _selectedGender = userData?["gender"]?.toLowerCase() == "male"
              ? "Male"
              : userData?["gender"]?.toLowerCase() == "female"
                  ? "Female"
                  : "Other"; // Default case

          _selectedActivityLevel = userData?["activityLevel"] != null &&
                  activityLevels.contains(userData?["activityLevel"])
              ? userData!["activityLevel"]
              : activityLevels.first; // Default to the first item

          // #2
          // _selectedActivityLevel = (userData != null &&
          //         activityLevels.contains(userData!["activityLevel"]))
          //     ? userData!["activityLevel"]
          //     : null;

          // #2
          // _selectedGender = userData?["gender"]?.toLowerCase() == "male"
          //     ? "Male"
          //     : userData?["gender"]?.toLowerCase() == "female"
          //         ? "Female"
          //         : "Other"; // Default case

          // #1
          // _selectedActivityLevel = userData?["activityLevel"] ?? '';
          //       _selectedActivityLevel = activityLevels.contains(userData?["activityLevel"])
          // ? userData?["activityLevel"]
          // : null;

          if (dobString.isNotEmpty) {
            DateTime dob =
                DateTime.parse(dobString); // Convert string to DateTime
            int age = _calculateAge(dob); // Calculate age
            _ageController.text = age.toString(); // Set age in the text field
          } else {
            _ageController.text = ''; // Default if dob is empty
          }
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  double? _calculatedBMI() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      return weight / ((height / 100) * (height / 100)); // BMI formula
    }
    return null; // Return null if the input values are invalid
  }

// Function to calculate age
  int _calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--; // Reduce age if the birthday hasn't occurred yet this year
    }
    return age;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String formatNumber(int number) {
    return NumberFormat("#,###").format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Text(
                  'Body Metrics Calculation',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    letterSpacing: 1,
                  ),
                ),
              ),

              SizedBox(height: 20),

              Text(
                'To calculate the appropriate calories for you',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 20),

              // Container for BMI, BMR, and TDEE
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // BMI Button
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCalculation = 'BMI';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedCalculation == 'BMI'
                                ? Color(0xFF1F5F5B)
                                : Colors.grey[350],
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'BMI',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _selectedCalculation == 'BMI'
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // BMR Button
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCalculation = 'BMR';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedCalculation == 'BMR'
                                ? Color(0xFF1F5F5B)
                                : Colors.grey[350],
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'BMR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _selectedCalculation == 'BMR'
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // TDEE Button
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCalculation = 'TDEE';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedCalculation == 'TDEE'
                                ? Color(0xFF1F5F5B)
                                : Colors.grey[350],
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'TDEE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _selectedCalculation == 'TDEE'
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // _buildDropdownRow(
              //     label: 'Gender',
              //     value: _selectedGender,
              //     // controller: _genderController,
              //     items: ['Male', 'Female', 'Other'],
              //     // onChanged: (value) => setState(() => _selectedGender = value),
              //     onChanged: (newValue) {
              //       setState(() {
              //         _selectedGender = newValue;
              //       });
              //     }),
              Row(
                children: [
                  Expanded(flex: 2, child: Text('Gender')),
                  Expanded(
                    flex: 6,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedGender, // Ensure this is in the list
                      items: genders.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(
                            gender,
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w400),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue!;
                        });
                      },
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  if (_selectedCalculation == 'BMR' ||
                      _selectedCalculation == 'TDEE')
                    _buildInputRow(
                      label: 'Age',
                      unit: 'years',
                      controller: _ageController,
                    ),
                  _buildInputRow(
                    label: 'Height',
                    unit: 'cm',
                    controller: _heightController,
                  ),
                  _buildInputRow(
                    label: 'Weight',
                    unit: 'kg',
                    controller: _weightController,
                  ),
                ],
              ),

              if (_selectedCalculation == 'TDEE')
                // _buildDropdownRow(
                //     label: 'Activity Level',
                //     value: _selectedActivityLevel,
                //     // controller: _activityLevelController,
                //     // items: _activityMultipliers.keys.toList(),
                //     items: [
                //       'Sedentary',
                //       'Lightly Active',
                //       'Moderately Active',
                //       'Very Active'
                //     ],
                //     // onChanged: () =>
                //     //     setState(() => _selectedActivityLevel = value),
                //     onChanged: (newValue) {
                //       setState(() {
                //         _selectedActivityLevel = newValue;
                //       });
                //     }),
                Row(
                  children: [
                    Expanded(flex: 2, child: Text('Activity Level')),
                    Expanded(
                      flex: 6,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedActivityLevel,
                        items: activityLevels.map((String level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(
                              level,
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w400),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedActivityLevel = newValue!;
                          });
                        },
                      ),
                    )
                  ],
                ),

              SizedBox(height: 20),

              // Save Button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _calculateAndStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1F5F5B),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    child: Text(
                      'Calculate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              //
              if (_bmi != null || _bmr != null || _tdee != null) ...[
                SizedBox(height: 20),
                if (_selectedCalculation == 'BMI' && _bmi != null)
                  Material(
                    borderRadius: BorderRadius.circular(10),
                    elevation: 4,
                    shadowColor: Colors.black,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          // Text('BMI: ${_bmi!.toStringAsFixed(2)}'),
                          SizedBox(
                            width: 200, // Set a smaller width
                            height: 200, // Set a smaller height
                            child: SfRadialGauge(
                              axes: <RadialAxis>[
                                RadialAxis(
                                  radiusFactor:
                                      1, // Reduce the gauge size inside its container
                                  minimum: 10,
                                  maximum: 40,
                                  ranges: <GaugeRange>[
                                    GaugeRange(
                                      startValue: 10,
                                      endValue: 18.5,
                                      color: Colors.blue,
                                      label: 'Underweight',
                                    ),
                                    GaugeRange(
                                      startValue: 18.5,
                                      endValue: 24.9,
                                      color: Colors.green,
                                      label: 'Normal',
                                    ),
                                    GaugeRange(
                                      startValue: 25,
                                      endValue: 29.9,
                                      color: Colors.orange,
                                      label: 'Overweight',
                                    ),
                                    GaugeRange(
                                      startValue: 30,
                                      endValue: 40,
                                      color: Colors.red,
                                      label: 'Obesity',
                                    ),
                                  ],
                                  pointers: <GaugePointer>[
                                    NeedlePointer(
                                      value: _calculatedBMI() ??
                                          0, // Dynamically pass BMI value
                                    ),
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                      widget: Text(
                                        "BMI: ${(_calculatedBMI() ?? 0).toStringAsFixed(1)}", // Show updated BMI
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      angle: 90,
                                      positionFactor:
                                          0.8, // Adjust annotation position
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Text(
                            "A Body Mass Index (BMI) of 25 or higher is classified as overweight, but it's essential to remember that BMI is just one of many indicators of health. The journey to achieving a healthy weight is not just about numbers; it's about making sustainable lifestyle changes that enhance your overall well-being.",
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_selectedCalculation == 'BMR' && _bmr != null)
                  Material(
                    borderRadius: BorderRadius.circular(10),
                    elevation: 4,
                    shadowColor: Colors.black,
                    child: Container(
                      height: 180,
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'The recommended daily calorie intake based on BMR is',
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${formatNumber(_bmr!.toInt())} ',
                                style: TextStyle(
                                  color: Color(0xFF1F5F5B),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'kcal',
                                style: TextStyle(
                                  color: Color(0xFF1F5F5B).withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "This is the number of calories your body needs to maintain basic functions like breathing and digestion while at rest.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_selectedCalculation == 'TDEE' && _tdee != null)
                  Material(
                    borderRadius: BorderRadius.circular(10),
                    elevation: 4,
                    shadowColor: Colors.black,
                    child: Container(
                      height: 180,
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'The recommended daily calorie intake based on TDEE is',
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${_tdee!.toStringAsFixed(2)} ',
                                style: TextStyle(
                                  color: Color(0xFF1F5F5B),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'kcal',
                                style: TextStyle(
                                  color: Color(0xFF1F5F5B).withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "This is the number of calories your body burns in a day, including all activities like exercise, work, and daily tasks.",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF1F5F5B),
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(color: Color(0xFF1F5F5B)),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Homepage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MenuScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FavoriteScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CalculateScreen()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.food_bank_outlined,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border_outlined,
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calculate_outlined,
            ),
            label: 'Calculate',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(label)),
        Expanded(
          flex: 6,
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow({
    required String label,
    required String unit,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        Expanded(flex: 4, child: Text(label)),
        Expanded(
          flex: 10,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter $label'),
          ),
        ),
        Expanded(flex: 2, child: Text(unit)),
      ],
    );
  }
}
