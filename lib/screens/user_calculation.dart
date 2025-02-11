import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserCalculation extends StatefulWidget {
  @override
  _UserCalculationState createState() => _UserCalculationState();
}

class _UserCalculationState extends State<UserCalculation> {
  double? _bmi;
  double? _bmr;
  double? _tdee;

  String? _gender;
  int? _age;
  double? _height;
  double? _weight;
  String? _activityLevel;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          setState(() {
            _gender = snapshot['gender'];
            _age = snapshot['age'];
            _height = double.tryParse(snapshot['height']);
            _weight = double.tryParse(snapshot['weight']);
            _activityLevel = snapshot['activityLevel'];
          });

          // Check if data is fetched correctly
          print(
              'Fetched user data: gender=$_gender, age=$_age, height=$_height, weight=$_weight, activityLevel=$_activityLevel');

          // Calculate values once data is fetched
          _calculateBmi();
          _calculateBmr();
          _calculateTdee();
        } else {
          print('No user data found');
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    } else {
      print('No user is logged in');
    }
  }

  // Calculate BMI
  void _calculateBmi() {
    if (_height != null && _weight != null) {
      setState(() {
        _bmi = _weight! /
            ((_height! / 100) * (_height! / 100)); // Height in cm to meters
      });
    }
  }

  // Calculate BMR (using Mifflin-St Jeor Equation)
  void _calculateBmr() {
    if (_age != null && _weight != null && _height != null && _gender != null) {
      setState(() {
        if (_gender == 'male') {
          _bmr = 10 * _weight! + 6.25 * _height! - 5 * _age! + 5;
        } else if (_gender == 'female') {
          _bmr = 10 * _weight! + 6.25 * _height! - 5 * _age! - 161;
        }
      });
    }
  }

  // Calculate TDEE
  void _calculateTdee() {
    if (_bmr != null && _activityLevel != null) {
      setState(() {
        switch (_activityLevel) {
          case 'Sedentary':
            _tdee = _bmr! * 1.2;
            break;
          case 'Lightly Active':
            _tdee = _bmr! * 1.375;
            break;
          case 'Moderately Active':
            _tdee = _bmr! * 1.55;
            break;
          case 'Very Active':
            _tdee = _bmr! * 1.725;
            break;
          case 'Super Active':
            _tdee = _bmr! * 1.9;
            break;
          default:
            _tdee = _bmr!;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Calculation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_bmi != null)
              Text('BMI: ${_bmi?.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20)),
            if (_bmr != null)
              Text('BMR: ${_bmr?.toStringAsFixed(2)} kcal/day',
                  style: TextStyle(fontSize: 20)),
            if (_tdee != null)
              Text('TDEE: ${_tdee?.toStringAsFixed(2)} kcal/day',
                  style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            if (_gender == null ||
                _age == null ||
                _height == null ||
                _weight == null ||
                _activityLevel == null)
              CircularProgressIndicator(), // Loading indicator
            if (_gender != null &&
                _age != null &&
                _height != null &&
                _weight != null &&
                _activityLevel != null)
              Text('User Data Loaded Successfully!',
                  style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
