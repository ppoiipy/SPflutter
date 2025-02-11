import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/homepage.dart';

class AddDetailsScreen extends StatefulWidget {
  final String userId; // Pass userId from previous screen (e.g., after sign-up)

  AddDetailsScreen({required this.userId});

  @override
  _AddDetailsScreenState createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _weightGoalController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _preferredFlavorsController = TextEditingController();
  final _activityLevelController = TextEditingController();

  Future<void> _saveDetails() async {
    try {
      // Save the additional user details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .set({
        'weight': _weightController.text,
        'height': _heightController.text,
        'dob': _dobController.text,
        'gender': _genderController.text,
        'weightGoal': _weightGoalController.text,
        'allergies': _allergiesController.text,
        'preferredFlavors': _preferredFlavorsController.text,
        'activityLevel': _activityLevelController.text,
      });

      // Navigate to the Home screen or Dashboard after saving details
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form fields for the user details (weight, height, etc.)
            TextField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight')),
            TextField(
                controller: _heightController,
                decoration: InputDecoration(labelText: 'Height')),
            TextField(
                controller: _dobController,
                decoration: InputDecoration(labelText: 'Date of Birth')),
            TextField(
                controller: _genderController,
                decoration: InputDecoration(labelText: 'Gender')),
            TextField(
                controller: _weightGoalController,
                decoration: InputDecoration(labelText: 'Weight Goal')),
            TextField(
                controller: _allergiesController,
                decoration: InputDecoration(labelText: 'Allergies')),
            TextField(
                controller: _preferredFlavorsController,
                decoration: InputDecoration(labelText: 'Preferred Flavors')),
            TextField(
                controller: _activityLevelController,
                decoration: InputDecoration(labelText: 'Activity Level')),

            // Save Button
            ElevatedButton(
              onPressed: _saveDetails,
              child: Text('Save Details'),
            ),
          ],
        ),
      ),
    );
  }
}
