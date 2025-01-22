import 'package:flutter/material.dart';
import 'package:flutter_application_1/SQLite/sqlite.dart';

class CalculateScreen extends StatefulWidget {
  @override
  _CalculateScreenState createState() => _CalculateScreenState();
}

class _CalculateScreenState extends State<CalculateScreen> {
  String? _selectedGender;
  String? _selectedActivityLevel;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
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

  void _calculateAndStore() async {
    final gender = _selectedGender;
    final age = int.tryParse(_ageController.text);
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final activityLevel = _selectedActivityLevel;

    if (gender == null ||
        activityLevel == null ||
        age == null ||
        height == null ||
        weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill out all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      // Calculate BMI
      _bmi = weight / ((height / 100) * (height / 100));

      // Calculate BMR
      if (gender == 'Male') {
        _bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
      } else {
        _bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
      }

      // Calculate TDEE based on selected activity level
      _tdee = _bmr! * _activityMultipliers[activityLevel]!;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Calories Calculation',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
            letterSpacing: 1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text('To calculate the appropriate calories for you',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            _buildDropdownRow(
              label: 'Gender',
              value: _selectedGender,
              items: ['Male', 'Female'],
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
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
            _buildDropdownRow(
              label: 'Activity Level',
              value: _selectedActivityLevel,
              items: _activityMultipliers.keys.toList(),
              onChanged: (value) =>
                  setState(() => _selectedActivityLevel = value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateAndStore,
              child: Text('Calculate and Save'),
            ),
            if (_bmi != null && _bmr != null && _tdee != null) ...[
              SizedBox(height: 20),
              Text('BMI: ${_bmi!.toStringAsFixed(2)}'),
              Text('BMR: ${_bmr!.toStringAsFixed(2)}'),
              Text('TDEE: ${_tdee!.toStringAsFixed(2)}'),
            ],
          ],
        ),
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
          flex: 3,
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
