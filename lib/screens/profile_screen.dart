import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // final _formKey = GlobalKey<FormState>();

  // DateTime? _selectedDate;
  // String _gender = '';
  // double? _height;
  // double? _weight;
  // double? _goalWeight;
  // int? _activityLevel;

  // @override
  // void initState() {
  //   super.initState();
  //   _loadUserProfile();
  // }

  // Future<void> _loadUserProfile() async {
  //   final userProfile = await _dbHelper.getUserProfile();
  //   if (userProfile != null) {
  //     setState(() {
  //       _gender = userProfile['gender'] ?? '';
  //       _height = userProfile['height'];
  //       _weight = userProfile['weight'];
  //       _goalWeight = userProfile['goalWeight'];
  //       _activityLevel = userProfile['activityLevel'];
  //       _selectedDate = userProfile['dateOfBirth'] != null
  //           ? DateTime.parse(userProfile['dateOfBirth'])
  //           : null;
  //     });
  //   }
  // }

  // Future<void> _saveUserProfile() async {
  //   if (_formKey.currentState!.validate()) {
  //     final profile = {
  //       'gender': _gender,
  //       'height': _height,
  //       'weight': _weight,
  //       'goalWeight': _goalWeight,
  //       'activityLevel': _activityLevel,
  //       'dateOfBirth': _selectedDate?.toIso8601String(),
  //     };
  //     await _dbHelper.saveUserProfile(profile);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Profile saved successfully!')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Form(
        // key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: const AssetImage('assets/profile.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () {
                            // Handle profile picture selection
                          },
                          icon: const Icon(Icons.camera_alt),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Gender
                TextFormField(
                  // initialValue: _gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter gender'
                      : null,
                  // onChanged: (value) => _gender = value,
                ),
                const SizedBox(height: 16),
                // Height
                TextFormField(
                  // initialValue: _height?.toString(),
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter height'
                      : null,
                  // onChanged: (value) => _height = double.tryParse(value),
                ),
                const SizedBox(height: 16),
                // Weight
                TextFormField(
                  // initialValue: _weight?.toString(),
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter weight'
                      : null,
                  // onChanged: (value) => _weight = double.tryParse(value),
                ),
                const SizedBox(height: 16),
                // Goal Weight
                TextFormField(
                  // initialValue: _goalWeight?.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Goal Weight (kg)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter goal weight'
                      : null,
                  // onChanged: (value) => _goalWeight = double.tryParse(value),
                ),
                const SizedBox(height: 16),
                // Activity Level
                DropdownButtonFormField<int>(
                  // value: _activityLevel,
                  decoration:
                      const InputDecoration(labelText: 'Activity Level'),
                  items: [
                    const DropdownMenuItem(value: 1, child: Text('Sedentary')),
                    const DropdownMenuItem(
                        value: 2, child: Text('Lightly active')),
                    const DropdownMenuItem(
                        value: 3, child: Text('Moderately active')),
                    const DropdownMenuItem(
                        value: 4, child: Text('Very active')),
                    const DropdownMenuItem(
                        value: 5, child: Text('Super active')),
                  ],
                  // onChanged: (value) => setState(() => _activityLevel = value),
                  onChanged: null,
                  validator: (value) =>
                      value == null ? 'Please select activity level' : null,
                ),
                const SizedBox(height: 20),
                // Date of Birth
                TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      // initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      // setState(() => _selectedDate = picked);
                    }
                  },
                  child: Text('Select Date of Birth'),
                  // child: Text(
                  //   _selectedDate == null
                  //       ? 'Select Date of Birth'
                  //       : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  // ),
                ),
                const SizedBox(height: 20),
                // Save Button
                ElevatedButton(
                  onPressed: () {},
                  // onPressed: _saveUserProfile,
                  child: const Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
