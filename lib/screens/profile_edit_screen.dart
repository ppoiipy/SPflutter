import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:ginraidee/screens/profile_screen.dart';

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
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _cuisineTypesController = TextEditingController();
  final TextEditingController _ingredientsActivityLevel =
      TextEditingController();

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

  List<String> foodCategory = [
    //   'American',
    //   'Asian',
    //   'British',
    //   'Caribbean',
    //   'Central Europe',
    //   'Chinese',
    //   'Eastern Europe',
    //   'French',
    //   'Greek',
    //   'Indian',
    //   'Italian',
    //   'Japanese',
    //   'Korean',
    //   'Kosher',
    //   'Mediterranean',
    //   'Mexican',
    //   'Middle Eastern',
    //   'Nordic',
    //   'South American',
    //   'South East Asian',
    //   'World',
    // ];
    'American',
    'Italian',
    'Japanese',
    'Chinese',
    'Thai',
    'South East Asia'
  ];

  List<String> foodIngredient = [
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
  List<String> selectedCuisineTypes = [];
  String selectedActivityLevel = '';

  // Ver 2
  Set<String> selectedFoodCookingTechnique = {};
  Set<String> selectedFoodAllergy = {};
  Set<String> selectedFoodCategory = {};
  List<String> foodCookingTechnique = [
    'Boiling',
    'Frying',
    'Baking',
    'Grilling',
    'Steaming'
  ];
  // List<String> foodAllergy = ['Egg', 'Milk', 'Fish', 'Nuts', 'Soybeans'];
  // List<String> foodCategory = ['Italian', 'Japanese', 'Chinese', 'Thai'];

  List<String> genderOptions = ['Male', 'Female', 'Other'];
  String? selectedGender;

  final ImagePicker _picker = ImagePicker();
  Future<void> _selectProfileImage() async {
    // Let the user pick an image from their gallery
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        // Set the selected image as profile picture
        _profileImageUrl = image.path;
      });
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      // Create a reference to Firebase Storage
      String fileName = 'profile_pics/${user!.uid}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      // Upload the image to Firebase Storage
      await storageRef.putFile(imageFile);

      // Get the download URL
      String downloadUrl = await storageRef.getDownloadURL();

      // Update the profile picture URL in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'profilePicture': downloadUrl,
      });
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

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

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        if (data.containsKey('profileImage') && data['profileImage'] != null) {
          setState(() {
            _selectedAssetImage = 'assets/profile/${data['profileImage']}';
          });
        }

        if (data.containsKey('profileImageUrl')) {
          setState(() {
            _profileImageUrl =
                data['profileImageUrl']; // if you're using Firebase Storage too
          });
        }
      }

      if (userDoc.exists && mounted) {
        // Ensure widget is still active
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;

          selectedGender = userData?["gender"] ?? 'Male';
          _weightController.text = (userData?["weight"] ?? '').toString();
          _heightController.text = (userData?["height"] ?? '').toString();
          _weightGoalController.text =
              (userData?["weightGoal"] ?? '').toString();
          _birthController.text = userData?["dob"] ?? '';
          selectedAllergies = List<String>.from(userData?["foodAllergy"] ?? []);
          selectedCuisineTypes =
              List<String>.from(userData?["foodCategory"] ?? []);
          selectedIngredients =
              List<String>.from(userData?["foodIngredient"] ?? []);

          // Ensure that selectedActivityLevel exists in activityLevels
          selectedActivityLevel =
              activityLevels.contains(userData?["activityLevel"])
                  ? userData!["activityLevel"]
                  : activityLevels.first;

          selectedFoodCookingTechnique =
              Set<String>.from(userData?['foodCookingTechnique'] ?? []);
          selectedFoodAllergy =
              Set<String>.from(userData?['foodAllergy'] ?? []);
          selectedFoodCategory =
              Set<String>.from(userData?['foodCategory'] ?? []);

          _profileImageUrl =
              userData?["profilePicture"] ?? 'assets/images/default.png';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // MARK: Profile Selection

  final List<String> _profileImages = [
    'assets/profile/avatar1.png',
    'assets/profile/avatar2.png',
    'assets/profile/avatar3.png',
    'assets/profile/avatar4.png',
    'assets/profile/avatar5.png',
    'assets/profile/avatar6.png',
    'assets/profile/avatar7.png',
  ];

  File? _image;
  String? _profileImageUrl;

  String? _selectedAssetImage;

  void _pickImage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _profileImages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _profileImageUrl = null; // Clear Firebase URL if needed
                    _selectedAssetImage = _profileImages[index];
                  });
                  Navigator.pop(context); // Close bottom sheet
                },
                child: CircleAvatar(
                  backgroundImage: AssetImage(_profileImages[index]),
                  radius: 40,
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : _selectedAssetImage != null
                              ? AssetImage(_selectedAssetImage!)
                              : const AssetImage('assets/images/default.png')
                                  as ImageProvider,
                    ),
                    Positioned(
                      right: 4,
                      bottom: 0,
                      child: Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Color(0xFF1F5F5B),
                        // backgroundColor: Colors.black.withOpacity(0.5),
                        // padding: EdgeInsets.all(6),
                        // shape: CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
              //   child: TextFormField(
              //     controller: _weightController,
              //     decoration: InputDecoration(
              //       labelText: 'Weight',
              //       labelStyle: TextStyle(
              //           color: Color(0xFF1F5F5B),
              //           fontWeight: FontWeight.w500,
              //           fontSize: 18),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
              //   child: TextFormField(
              //     controller: _heightController,
              //     decoration: InputDecoration(
              //       labelText: 'Height',
              //       labelStyle: TextStyle(
              //           color: Color(0xFF1F5F5B),
              //           fontWeight: FontWeight.w500,
              //           fontSize: 18),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
              //   child: TextFormField(
              //     controller: _weightGoalController,
              //     decoration: InputDecoration(
              //       labelText: 'Weight Goal',
              //       labelStyle: TextStyle(
              //           color: Color(0xFF1F5F5B),
              //           fontWeight: FontWeight.w500,
              //           fontSize: 18),
              //     ),
              //   ),
              // ),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
              //   child: TextFormField(
              //     controller: _birthController,
              //     decoration: InputDecoration(
              //       labelText: 'Date of Birth',
              //       labelStyle: TextStyle(
              //           color: Color(0xFF1F5F5B),
              //           fontWeight: FontWeight.w500,
              //           fontSize: 18),
              //     ),
              //   ),
              // ),

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
              _buildAllergyDropdown(),
              _buildCuisineTypesDropdown(),
              _buildIngredientsDropdown(),

              // Ver 2
              // _buildMultiSelectDropdown(
              //     foodCookingTechnique,
              //     selectedFoodCookingTechnique,
              //     "Cooking Techniques", (newValues) {
              //   setState(() {
              //     selectedFoodCookingTechnique = newValues;
              //   });
              // }),

              // _buildMultiSelectDropdown(
              //     foodAllergy, selectedFoodAllergy, "Food Allergies",
              //     (newValues) {
              //   setState(() {
              //     selectedFoodAllergy = newValues;
              //   });
              // }),

              // _buildMultiSelectDropdown(
              //     foodCategory, selectedFoodCategory, "Food Categories",
              //     (newValues) {
              //   setState(() {
              //     selectedFoodCategory = newValues;
              //   });
              // }),

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
                  ' $unit',
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

  Widget _buildMultiSelectDropdown(
      List<String> options,
      Set<String> selectedValues,
      String label,
      Function(Set<String>) onChanged) {
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
              fontSize: 14,
            ),
          ),
          MultiSelectDialogField(
            items: options.map((e) => MultiSelectItem<String>(e, e)).toList(),
            title: Text("Select $label"),
            selectedColor: Color(0xFF1F5F5B),
            buttonText: Text(
              selectedValues.isNotEmpty
                  ? selectedValues.join(', ') // Show selected values
                  : "Select $label",
              style: TextStyle(fontSize: 14),
            ),
            initialValue:
                selectedValues.toList(), // Ensure selected values appear
            onConfirm: (values) {
              setState(() {
                onChanged(values.toSet());
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Allergy',
            style: TextStyle(
              color: Color(0xFF1F5F5B),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          MultiSelectDialogField(
            items: foodAllergy
                .map((allergy) => MultiSelectItem<String>(allergy, allergy))
                .toList(),
            initialValue: selectedAllergies,
            title: Text(
              "Allergies",
              style: TextStyle(color: Color(0xFF1F5F5B)),
            ),
            onConfirm: (selectedValues) {
              setState(() {
                selectedAllergies = selectedValues.cast<String>();
              });
            },
            chipDisplay: MultiSelectChipDisplay(
              chipColor: Color.fromARGB(255, 46, 150, 143),
              textStyle: TextStyle(color: Colors.white),
              onTap: (item) {
                setState(() {
                  selectedAllergies.remove(item);
                });
              },
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            selectedColor: Color.fromARGB(255, 46, 150, 143),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisineTypesDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cuisine',
            style: TextStyle(
              color: Color(0xFF1F5F5B),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          MultiSelectDialogField(
            items: foodCategory
                .map((foodCategory) =>
                    MultiSelectItem<String>(foodCategory, foodCategory))
                .toList(),
            initialValue: selectedCuisineTypes,
            title: Text(
              "Cuisine Type",
              style: TextStyle(color: Color(0xFF1F5F5B)),
            ),
            onConfirm: (selectedValues) {
              setState(() {
                selectedCuisineTypes = selectedValues.cast<String>();
              });
            },
            chipDisplay: MultiSelectChipDisplay(
              chipColor: Color.fromARGB(255, 46, 150, 143),
              textStyle: TextStyle(color: Colors.white),
              onTap: (item) {
                setState(() {
                  selectedCuisineTypes.remove(item);
                });
              },
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            selectedColor: Color.fromARGB(255, 46, 150, 143),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients',
            style: TextStyle(
              color: Color(0xFF1F5F5B),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          MultiSelectDialogField(
            items: foodIngredient
                .map((ingredient) =>
                    MultiSelectItem<String>(ingredient, ingredient))
                .toList(),
            initialValue: selectedIngredients,
            title: Text(
              "Ingredients",
              style: TextStyle(color: Color(0xFF1F5F5B)),
            ),
            onConfirm: (selectedValues) {
              setState(() {
                selectedIngredients = selectedValues.cast<String>();
              });
            },
            chipDisplay: MultiSelectChipDisplay(
              chipColor: Color.fromARGB(255, 46, 150, 143),
              textStyle: TextStyle(color: Colors.white),
              onTap: (item) {
                setState(() {
                  selectedIngredients.remove(item);
                });
              },
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            selectedColor: Color.fromARGB(255, 46, 150, 143),
          ),
        ],
      ),
    );
  }

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
            value: selectedActivityLevel.isNotEmpty &&
                    activityLevels.contains(selectedActivityLevel)
                ? selectedActivityLevel
                : activityLevels
                    .first, // Default to the first activity level if none selected
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              hintText: 'Select activity level',
              isDense: true,
            ),
            onChanged: (String? newValue) {
              setState(() {
                selectedActivityLevel = newValue ??
                    activityLevels.first; // Update selected activity level
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
              final String? profileImageName = _selectedAssetImage != null
                  ? _selectedAssetImage!.split('/').last
                  : null;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .update({
                'gender': selectedGender,
                'weight': _weightController.text,
                'height': _heightController.text,
                'weightGoal': _weightGoalController.text,
                'dob': _birthController.text,
                'foodAllergy': selectedAllergies,
                'foodCategory': selectedCuisineTypes,
                'foodIngredient': selectedIngredients,
                'activityLevel': selectedActivityLevel,
                if (profileImageName != null) 'profileImage': profileImageName,
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
          } else {
            print("Form is not valid.");
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
