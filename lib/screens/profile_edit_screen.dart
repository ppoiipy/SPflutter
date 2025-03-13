import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_application_1/SQLite/sqlite.dart';
import 'package:flutter_application_1/screens/food_search_screen.dart';
import 'package:flutter_application_1/screens/homepage.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/profile_edit_screen.dart';
import 'package:flutter_application_1/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/widgets/chart_widget.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightGoalController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _preferredFlavorsController =
      TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _cuisineTypesController = TextEditingController();
  final TextEditingController _ingredientsActivityLevel =
      TextEditingController();
  final TextEditingController _selectedActivityLevel = TextEditingController();

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

  List<String> activityLevels = [
    "Sedentary (little to no exercise)",
    "Lightly active (1-3 days/week)",
    "Moderately active (3-5 days/week)",
    "Very active (6-7 days/week)",
    "Super active (Very hard exercise)"
    // "Sedentary",
    // "Lightly active",
    // "Moderately active",
    // "Very active",
    // "Super active"
  ];

  List<String> cuisineTypes = [
    'American',
    'Asian',
    'British',
    'Caribbean',
    'Central Europe',
    'Chinese',
    'Eastern Europe',
    'French',
    'Greek',
    'Indian',
    'Italian',
    'Japanese',
    'Korean',
    'Kosher',
    'Mediterranean',
    'Mexican',
    'Middle Eastern',
    'Nordic',
    'South American',
    'South East Asian',
    'World',
  ];

  List<String> ingredients = [
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

  List<String> selectedIngredients = [];

  List<String> selectedAllergies = [];
  List<String> selectedFlavors = [];
  List<String> selectedCuisineTypes = [];

  // Ver 2
  Set<String> selectedFoodCookingTechnique = {};
  Set<String> selectedFoodAllergy = {};
  Set<String> selectedFoodCategory = {};
  Set<String> selectedFoodFlavor = {};
  List<String> foodCookingTechnique = [
    'Boiling',
    'Frying',
    'Baking',
    'Grilling',
    'Steaming'
  ];
  List<String> foodAllergy = ['Egg', 'Milk', 'Fish', 'Nuts', 'Soybeans'];
  List<String> foodCategory = ['Italian', 'Japanese', 'Chinese', 'Thai'];
  List<String> foodFlavor = ['Sweet', 'Salty', 'Spicy', 'Sour', 'Bitter'];

  List<String> genderOptions = ['Male', 'Female', 'Other'];
  String? selectedGender;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    selectedGender = '';
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

          // _genderController.text = userData?["gender"] ?? '';
          selectedGender = userData?["gender"] ?? 'Male';
          _weightController.text = (userData?["weight"] ?? '').toString();
          _heightController.text = (userData?["height"] ?? '').toString();
          _weightGoalController.text =
              (userData?["weightGoal"] ?? '').toString();
          _birthController.text = userData?["dob"] ?? '';
          selectedFlavors =
              List<String>.from(userData?["preferredFlavors"] ?? []);
          selectedAllergies = List<String>.from(userData?["allergies"] ?? []);
          selectedCuisineTypes =
              List<String>.from(userData?["cuisineTypes"] ?? []);
          selectedIngredients =
              List<String>.from(userData?["ingredients"] ?? []);
          _selectedActivityLevel.text = userData?["activityLevel"] ?? '';

          selectedFoodCookingTechnique =
              Set<String>.from(userData?['foodCookingTechnique'] ?? []);
          selectedFoodAllergy =
              Set<String>.from(userData?['foodAllergy'] ?? []);
          selectedFoodCategory =
              Set<String>.from(userData?['foodCategory'] ?? []);
          selectedFoodFlavor = Set<String>.from(userData?['foodFlavor'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              // _buildInputRow(label: 'Gender', controller: _genderController),
              _buildGenderDropdown(),
              _buildInputRow(
                label: 'Weight',
                controller: _weightController,
                inputType: TextInputType.number,
                unit: 'kg',
              ),
              _buildInputRow(
                label: 'Height',
                controller: _heightController,
                inputType: TextInputType.number,
                unit: 'cm',
              ),
              _buildInputRow(
                label: 'Weight Goals',
                controller: _weightGoalController,
                unit: 'kg',
              ),
              _buildDateInputRow(
                  label: 'Birth date', controller: _birthController),
              // _buildFlavorDropdown(),
              // _buildAllergyDropdown(),
              // _buildCuisineTypesDropdown(),
              // _buildIngredientsDropdown(),

              // Ver 2
              _buildDropdown(foodCookingTechnique, selectedFoodCookingTechnique,
                  "Cooking Techniques"),
              _buildDropdown(
                  foodAllergy, selectedFoodAllergy, "Food Allergies"),
              _buildDropdown(
                  foodCategory, selectedFoodCategory, "Food Categories"),
              _buildDropdown(foodFlavor, selectedFoodFlavor, "Food Flavors"),

              _buildActivityLevelDropdown(),

              SizedBox(height: 30),
              _buildSubmitButton(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F5F5B), Color(0xFF40C5BD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        centerTitle: true,
        title: Text('Profile Settings', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildInputRow({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    required String unit,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: Color(0xFF1F5F5B),
                fontWeight: FontWeight.w500,
                fontSize: 14),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: inputType,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    hintText: 'Enter $label',
                    isDense: true,
                    border: UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    } else if (inputType == TextInputType.number &&
                        double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^[0-9]*\.?[0-9]*$')),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  ' ${unit}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: TextStyle(
                color: Color(0xFF1F5F5B),
                fontWeight: FontWeight.w500,
                fontSize: 14),
          ),
          DropdownButtonFormField<String>(
            value: selectedGender!.isEmpty ? 'Male' : selectedGender,
            onChanged: (newValue) {
              setState(() {
                selectedGender = newValue!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
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
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
              prefixIcon: Icon(Icons.person, size: 20),
              hintText: 'Select gender',
              isDense: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDropdown(
      List<String> options, Set<String> selected, String title) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF1F5F5B),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          MultiSelectDialogField(
            items: options
                .map((option) => MultiSelectItem<String>(option, option))
                .toList(),
            initialValue: selected.toList(),
            title: Text(
              title,
              style: TextStyle(color: Color(0xFF1F5F5B)),
            ),
            onConfirm: (selectedValues) {
              setState(() {
                selected.clear();
                selected.addAll(selectedValues.cast<String>());
              });
            },
            chipDisplay: MultiSelectChipDisplay(
              chipColor: Color(0xFF2E968F),
              textStyle: TextStyle(color: Colors.white),
              onTap: (item) {
                setState(() {
                  selected.remove(item);
                });
              },
            ),
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(12),
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
            ),
            selectedColor: Color(0xFF2E968F),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  // Widget _buildFlavorDropdown() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Flavors',
  //           style: TextStyle(
  //             color: Color(0xFF1F5F5B),
  //             fontWeight: FontWeight.w500,
  //             fontSize: 14,
  //           ),
  //         ),
  //         MultiSelectDialogField(
  //           items: flavors
  //               .map((flavor) => MultiSelectItem<String>(flavor, flavor))
  //               .toList(),
  //           initialValue: selectedFlavors,
  //           title: Text(
  //             "Preferred Flavors",
  //             style: TextStyle(color: Color(0xFF1F5F5B)),
  //           ),
  //           onConfirm: (selectedValues) {
  //             setState(() {
  //               selectedFlavors = selectedValues.cast<String>();
  //             });
  //           },
  //           chipDisplay: MultiSelectChipDisplay(
  //             chipColor: Color.fromARGB(255, 46, 150, 143),
  //             textStyle: TextStyle(color: Colors.white),
  //             onTap: (item) {
  //               setState(() {
  //                 selectedFlavors.remove(item);
  //               });
  //             },
  //           ),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           selectedColor: Color.fromARGB(255, 46, 150, 143),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildAllergyDropdown() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Allergy',
  //           style: TextStyle(
  //             color: Color(0xFF1F5F5B),
  //             fontWeight: FontWeight.w500,
  //             fontSize: 14,
  //           ),
  //         ),
  //         MultiSelectDialogField(
  //           items: allergies
  //               .map((allergy) => MultiSelectItem<String>(allergy, allergy))
  //               .toList(),
  //           initialValue: selectedAllergies,
  //           title: Text(
  //             "Allergies",
  //             style: TextStyle(color: Color(0xFF1F5F5B)),
  //           ),
  //           onConfirm: (selectedValues) {
  //             setState(() {
  //               selectedAllergies = selectedValues.cast<String>();
  //             });
  //           },
  //           chipDisplay: MultiSelectChipDisplay(
  //             chipColor: Color.fromARGB(255, 46, 150, 143),
  //             textStyle: TextStyle(color: Colors.white),
  //             onTap: (item) {
  //               setState(() {
  //                 selectedAllergies.remove(item);
  //               });
  //             },
  //           ),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           selectedColor: Color.fromARGB(255, 46, 150, 143),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCuisineTypesDropdown() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Cuisine',
  //           style: TextStyle(
  //             color: Color(0xFF1F5F5B),
  //             fontWeight: FontWeight.w500,
  //             fontSize: 14,
  //           ),
  //         ),
  //         MultiSelectDialogField(
  //           items: cuisineTypes
  //               .map((cuisineType) =>
  //                   MultiSelectItem<String>(cuisineType, cuisineType))
  //               .toList(),
  //           initialValue: selectedCuisineTypes,
  //           title: Text(
  //             "Cuisine Type",
  //             style: TextStyle(color: Color(0xFF1F5F5B)),
  //           ),
  //           onConfirm: (selectedValues) {
  //             setState(() {
  //               selectedCuisineTypes = selectedValues.cast<String>();
  //             });
  //           },
  //           chipDisplay: MultiSelectChipDisplay(
  //             chipColor: Color.fromARGB(255, 46, 150, 143),
  //             textStyle: TextStyle(color: Colors.white),
  //             onTap: (item) {
  //               setState(() {
  //                 selectedCuisineTypes.remove(item);
  //               });
  //             },
  //           ),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           selectedColor: Color.fromARGB(255, 46, 150, 143),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildIngredientsDropdown() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Ingredients',
  //           style: TextStyle(
  //             color: Color(0xFF1F5F5B),
  //             fontWeight: FontWeight.w500,
  //             fontSize: 14,
  //           ),
  //         ),
  //         MultiSelectDialogField(
  //           items: ingredients
  //               .map((ingredient) =>
  //                   MultiSelectItem<String>(ingredient, ingredient))
  //               .toList(),
  //           initialValue: selectedIngredients,
  //           title: Text(
  //             "Ingredients",
  //             style: TextStyle(color: Color(0xFF1F5F5B)),
  //           ),
  //           onConfirm: (selectedValues) {
  //             setState(() {
  //               selectedIngredients = selectedValues.cast<String>();
  //             });
  //           },
  //           chipDisplay: MultiSelectChipDisplay(
  //             chipColor: Color.fromARGB(255, 46, 150, 143),
  //             textStyle: TextStyle(color: Colors.white),
  //             onTap: (item) {
  //               setState(() {
  //                 selectedIngredients.remove(item);
  //               });
  //             },
  //           ),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           selectedColor: Color.fromARGB(255, 46, 150, 143),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildActivityLevelDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Level',
            style: TextStyle(
              color: Color(0xFF1F5F5B),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          DropdownButtonFormField<String>(
            value: _selectedActivityLevel.text.isEmpty
                ? null
                : _selectedActivityLevel.text,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              hintText: 'Select activity level',
              isDense: true,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedActivityLevel.text = newValue ?? '';
              });
            },
            items: activityLevels.map((String level) {
              return DropdownMenuItem<String>(
                value: level,
                child: Text(level, style: TextStyle(fontSize: 14)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInputRow(
      {required String label, required TextEditingController controller}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: Color(0xFF1F5F5B),
                fontWeight: FontWeight.w500,
                fontSize: 14),
          ),
          TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                hintText: 'Select $label',
                isDense: true),
            onTap: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (selectedDate != null) {
                setState(() {
                  controller.text =
                      DateFormat('yyyy-MM-dd').format(selectedDate);
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1F5F5B),
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width * 0.3,
            vertical: MediaQuery.sizeOf(context).width * 0.03,
          ),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            try {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .update({
                'gender': selectedGender,
                'weight': _weightController.text,
                'height': _heightController.text,
                'weightGoal': _weightGoalController.text,
                'dob': _birthController.text,
                'preferredFlavors': selectedFlavors,
                'allergies': selectedAllergies,
                'cuisineTypes': selectedCuisineTypes,
                'ingredients': selectedIngredients,
                'activityLevel': _selectedActivityLevel.text,
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Profile updated successfully!')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating profile')),
              );
            }
          }
        },
        child: Text(
          'Apply',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
