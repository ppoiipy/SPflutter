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
      // Calculate BMI
      if (_selectedCalculation == 'BMI') {
        _bmi = weight / ((height / 100) * (height / 100));
      }

      // Calculate BMR
      if (_selectedCalculation == 'BMR') {
        if (gender == 'Male') {
          _bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age!);
        } else {
          _bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age!);
        }
      }

      // Calculate TDEE
      if (_selectedCalculation == 'TDEE') {
        if (gender == 'Male') {
          _bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age!);
        } else {
          _bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'To calculate the appropriate calories for you',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // Buttons for BMI, BMR, TDEE selection in a single container with background color for each
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // BMI Button with background color
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: _selectedCalculation == 'BMI'
                              ? const Color.fromARGB(255, 33, 243, 128)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCalculation = 'BMI';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .transparent, // Make button background transparent
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
                    // BMR Button with background color
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: _selectedCalculation == 'BMR'
                              ? const Color.fromARGB(255, 33, 243, 128)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCalculation = 'BMR';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .transparent, // Make button background transparent
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
                    // TDEE Button with background color
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: _selectedCalculation == 'TDEE'
                              ? const Color.fromARGB(255, 33, 243, 128)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCalculation = 'TDEE';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .transparent, // Make button background transparent
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
              _buildDropdownRow(
                label: 'Gender',
                value: _selectedGender,
                items: ['Male', 'Female'],
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
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
              if (_selectedCalculation == 'TDEE')
                _buildDropdownRow(
                  label: 'Activity Level',
                  value: _selectedActivityLevel,
                  items: _activityMultipliers.keys.toList(),
                  onChanged: (value) =>
                      setState(() => _selectedActivityLevel = value),
                ),
              SizedBox(height: 20),

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
                      'Calculate and Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
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
                          Text('BMI: ${_bmi!.toStringAsFixed(2)}'),
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
                                '${_bmr!.toStringAsFixed(2)} ',
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
