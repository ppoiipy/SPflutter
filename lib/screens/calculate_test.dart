import 'package:flutter/material.dart';
import 'package:flutter_application_1/SQLite/sqlite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:syncfusion_flutter_gauges/gauges.dart';

class CalculateTest extends StatefulWidget {
  @override
  _CalculateTestState createState() => _CalculateTestState();
}

class _CalculateTestState extends State<CalculateTest> {
  String? _selectedGender;
  String? _selectedActivityLevel;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> activityLevels = [
    "Sedentary (little to no exercise)",
    "Lightly active active (1-3 days/week)",
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
    final height = double.tryParse(_heightController.text); // double for height
    final weight = double.tryParse(_weightController.text); // double for weight
    final activityLevel = _selectedActivityLevel;

    // Check if all required fields are filled
    if (gender == null ||
        height == null ||
        weight == null ||
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

    // Perform calculations
    setState(() {
      // Calculate BMI
      if (_selectedCalculation == 'BMI') {
        _bmi = weight / ((height / 100) * (height / 100));
      }
    });

    print("BMI: $_bmi");

    // Now, update Firestore with the calculated data
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid) // Make sure 'user' is the current authenticated user
          .update({
        'gender': gender,
        'age': age,
        'height': height.toString(), // Convert to String for Firestore
        'weight': weight.toString(), // Convert to String for Firestore
        'bmi': _bmi?.toString(), // Convert to String for Firestore
        'activityLevel': activityLevel,
      });

      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle any errors
      print("Error updating user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating data'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          _weightController.text = userData?["weight"] ?? '';
          _heightController.text = userData?["height"] ?? '';

          _selectedGender = userData?["gender"]?.toLowerCase() == "male"
              ? "Male"
              : userData?["gender"]?.toLowerCase() == "female"
                  ? "Female"
                  : "Other"; // Default case

          _selectedActivityLevel = userData?["activityLevel"] != null &&
                  activityLevels.contains(userData?["activityLevel"])
              ? userData!["activityLevel"]
              : activityLevels.first;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              AppBar(
                centerTitle: true,
                title: Text(
                  'Calories Calculation',
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
                  ],
                ),
              ),
              SizedBox(height: 20),
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
                                        label: 'Underweight'),
                                    GaugeRange(
                                        startValue: 18.5,
                                        endValue: 24.9,
                                        color: Colors.green,
                                        label: 'Normal'),
                                    GaugeRange(
                                        startValue: 25,
                                        endValue: 29.9,
                                        color: Colors.orange,
                                        label: 'Overweight'),
                                    GaugeRange(
                                        startValue: 30,
                                        endValue: 40,
                                        color: Colors.red,
                                        label: 'Obese'),
                                  ],
                                  pointers: <GaugePointer>[
                                    NeedlePointer(
                                      value: double.parse(
                                              userData?['weight'] ?? '0') /
                                          ((double.parse(userData?['height'] ??
                                                      '1') /
                                                  100) *
                                              (double.parse(
                                                      userData?['height'] ??
                                                          '1') /
                                                  100)),
                                    ),
                                  ],
                                  annotations: <GaugeAnnotation>[
                                    GaugeAnnotation(
                                      widget: Text(
                                        "BMI: ${(double.parse(userData?['weight'] ?? '0') / ((double.parse(userData?['height'] ?? '1') / 100) * (double.parse(userData?['height'] ?? '1') / 100))).toStringAsFixed(1)}",
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
              ],
            ],
          ),
        ),
      ),
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
