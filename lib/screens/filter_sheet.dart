import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
User? _user;

class FilterSheet extends StatefulWidget {
  final double? initialCalories;
  final Function(Map<String, dynamic>) onFiltersApplied;

  const FilterSheet({this.initialCalories, required this.onFiltersApplied});

  @override
  _FilterSheetState createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  double _selectedCalories = 100;
  Set<String> selectedFoodAllergy = {};
  Set<String> selectedFoodCategory = {};
  Set<String> selectedFoodIngredient = {};

  final List<String> foodCategories = [
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

  List<String> foodAllergy = [
    'Nuts',
    'Dairy',
    'Shellfish',
    'Gluten',
    'Wheat',
    'Sulfites',
    'Eggs',
    'Peanuts',
    'Tree-Nuts',
    'FODMAP'
  ];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _loadFilters();
    }
  }

  Future<void> _loadFilters() async {
    if (_user == null) return;

    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(_user!.uid).get();
    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      setState(() {
        _selectedCalories = (data?['calories'] ?? 100).toDouble();
        selectedFoodAllergy = Set<String>.from(data?['foodAllergy'] ?? []);
        selectedFoodCategory = Set<String>.from(data?['foodCategory'] ?? []);
        selectedFoodIngredient =
            Set<String>.from(data?['foodIngredient'] ?? []);
      });
    }
  }

  Future<void> _saveFilters() async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.uid).set({
      'calories': _selectedCalories,
      'foodAllergy': selectedFoodAllergy.toList(),
      'foodCategory': selectedFoodCategory.toList(),
      'foodIngredient': selectedFoodIngredient.toList(),
    }, SetOptions(merge: true));
  }

  void _resetFilters() {
    setState(() {
      _selectedCalories = 100;
      selectedFoodAllergy.clear();
      selectedFoodCategory.clear();
      selectedFoodIngredient.clear();
    });
    _saveFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Filter',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            Text("Calories",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Calories: ${_selectedCalories.toStringAsFixed(0)} Kcal',
                  style: TextStyle(fontSize: 14)),
            ),
            Slider(
              value: _selectedCalories,
              activeColor: Color(0xFF1f5f5b),
              thumbColor: Color(0xFF1f5f5b),
              min: 0,
              max: 1000,
              divisions: 100,
              label: _selectedCalories.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  _selectedCalories = value;
                });
              },
            ),
            SizedBox(height: 10),

            // Category Selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Food Categories",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: foodCategories.map((option) {
                    bool isSelected = selectedFoodCategory.contains(option);
                    return ChoiceChip(
                      label: Text(option,
                          style: TextStyle(
                              color: isSelected
                                  ? Color(0xFF39C184)
                                  : Colors.black54)),
                      selected: isSelected,
                      onSelected: (bool selectedValue) {
                        setState(() {
                          if (selectedValue) {
                            selectedFoodCategory.add(option);
                          } else {
                            selectedFoodCategory.remove(option);
                          }
                        });
                      },
                      selectedColor: Color(0xFF39C184).withOpacity(0.3),
                      side: BorderSide(
                          color: isSelected ? Color(0xFF39C184) : Colors.grey,
                          width: 1.4),
                      labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
              ],
            ),

            // Ingredient Filter
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Food Ingredients",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: foodIngredient.map((option) {
                    bool isSelected = selectedFoodIngredient.contains(option);
                    return ChoiceChip(
                      label: Text(option,
                          style: TextStyle(
                              color: isSelected
                                  ? Color(0xFF39C184)
                                  : Colors.black54)),
                      selected: isSelected,
                      onSelected: (bool selectedValue) {
                        setState(() {
                          if (selectedValue) {
                            selectedFoodIngredient.add(option);
                          } else {
                            selectedFoodIngredient.remove(option);
                          }
                        });
                      },
                      selectedColor: Color(0xFF39C184).withOpacity(0.3),
                      side: BorderSide(
                          color: isSelected ? Color(0xFF39C184) : Colors.grey,
                          width: 1.4),
                      labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
              ],
            ),

            // Allergy Filter
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Food Allergies",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8.0,
                  children: foodAllergy.map((option) {
                    bool isSelected = selectedFoodAllergy.contains(option);
                    return ChoiceChip(
                      label: Text(option,
                          style: TextStyle(
                              color: isSelected
                                  ? Color(0xFF39C184)
                                  : Colors.black54)),
                      selected: isSelected,
                      onSelected: (bool selectedValue) {
                        setState(() {
                          if (selectedValue) {
                            selectedFoodAllergy.add(option);
                          } else {
                            selectedFoodAllergy.remove(option);
                          }
                        });
                      },
                      selectedColor: Color(0xFF39C184).withOpacity(0.3),
                      side: BorderSide(
                          color: isSelected ? Color(0xFF39C184) : Colors.grey,
                          width: 1.4),
                      labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
              ],
            ),

            SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _resetFilters,
                  child: Text('Reset',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    minimumSize: Size(120, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _saveFilters();
                    Navigator.pop(context, {
                      'calories': _selectedCalories,
                      'foodAllergy': selectedFoodAllergy.toList(),
                      'foodCategory': selectedFoodCategory.toList(),
                      'foodIngredient': selectedFoodIngredient.toList(),
                    });
                  },
                  child: Text('Apply',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF39C184),
                    minimumSize: Size(120, 40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// Calorie
class CalorieFilterSheet extends StatefulWidget {
  final double initialCalories;
  final Function(double) onCaloriesChanged;

  CalorieFilterSheet({
    required this.initialCalories,
    required this.onCaloriesChanged,
  });

  @override
  _CalorieFilterSheetState createState() => _CalorieFilterSheetState();
}

class _CalorieFilterSheetState extends State<CalorieFilterSheet> {
  late double _selectedCalories = 100;

  Future<void> _loadFilters() async {
    if (_user == null) return;

    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(_user!.uid).get();
    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      setState(() {
        _selectedCalories = (data?['calories'] ?? 100).toDouble();
      });
    }
  }

  Future<void> _saveFilters() async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.uid).set({
      'calories': _selectedCalories,
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _loadFilters();
    }
    _selectedCalories = widget.initialCalories;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
                'Calories: ${_selectedCalories.toStringAsFixed(0)} Kcal',
                style: TextStyle(fontSize: 14)),
          ),
          Slider(
            value: _selectedCalories,
            activeColor: Color(0xFF1f5f5b),
            thumbColor: Color(0xFF1f5f5b),
            min: 0,
            max: 1000,
            divisions: 100,
            label: _selectedCalories.toStringAsFixed(0),
            onChanged: (value) {
              setState(() {
                _selectedCalories = value;
              });
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedCalories = 100;
                  });
                  _saveFilters();
                },
                child: Text('Reset',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  minimumSize: Size(120, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onCaloriesChanged(_selectedCalories);
                  _saveFilters();
                },
                child: Text('Apply', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF39C184),
                  minimumSize: Size(120, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Category
class CategoryFilter extends StatefulWidget {
  final Set<String> selectedCategories;
  final Function(Set<String>) onSelectionChanged;

  CategoryFilter({
    required this.selectedCategories,
    required this.onSelectionChanged,
  });

  @override
  _CategoryFilterState createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  final List<String> foodCategories = [
    'American',
    'Italian',
    'Japanese',
    'Chinese',
    'Thai',
    'South East Asia',
    'Mexican',
    'British',
    'Central Europe',
    'Asian'
  ];

  late Set<String> selectedCategories;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    selectedCategories = Set.from(widget.selectedCategories);
    if (_user != null) {
      _loadFilters();
    }
  }

  // Load filters from Firebase when the widget is initialized
  Future<void> _loadFilters() async {
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(_user!.uid).get();
    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      setState(() {
        selectedCategories = Set<String>.from(data?['foodCategory'] ?? []);
      });
    }
  }

  // Save the selected categories to Firebase
  Future<void> _saveFilters() async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.uid).set({
      'foodCategory': selectedCategories.toList(),
    }, SetOptions(merge: true));
    widget.onSelectionChanged(selectedCategories);
  }

  // Reset filters to the original categories from Firebase
  void _resetFilters() {
    setState(() {
      selectedCategories = Set.from(widget.selectedCategories);
    });
    _saveFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Food Categories",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: foodCategories.map((option) {
            bool isSelected = selectedCategories.contains(option);
            return ChoiceChip(
              label: Text(option,
                  style: TextStyle(
                      color: isSelected ? Color(0xFF39C184) : Colors.black54)),
              selected: isSelected,
              onSelected: (bool selectedValue) {
                setState(() {
                  if (selectedValue) {
                    selectedCategories.add(option);
                  } else {
                    selectedCategories.remove(option);
                  }
                });
              },
              selectedColor: Color(0xFF39C184).withOpacity(0.3),
              side: BorderSide(
                  color: isSelected ? Color(0xFF39C184) : Colors.grey,
                  width: 1.4),
              labelStyle:
                  TextStyle(color: isSelected ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _resetFilters, // Reset the categories when clicked
              child: Text('Reset',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                minimumSize: Size(120, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
              ),
            ),
            ElevatedButton(
              onPressed: _saveFilters, // Save the selected categories
              child: Text('Apply',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF39C184),
                minimumSize: Size(120, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class IngredientFilter extends StatefulWidget {
  final Set<String> selectedIngredients;
  final Function(Set<String>) onSelectionChanged;

  IngredientFilter({
    required this.selectedIngredients,
    required this.onSelectionChanged,
  });

  @override
  _IngredientFilterState createState() => _IngredientFilterState();
}

class _IngredientFilterState extends State<IngredientFilter> {
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
    'Coconut',
    'Potato',
    'Mushroom',
    'Broccoli',
    'Spinach',
    'Peanut',
    'Soy Sauce',
    'Olive Oil'
  ];

  late Set<String> selectedIngredients;

  @override
  void initState() {
    super.initState();
    selectedIngredients = Set.from(widget.selectedIngredients);
  }

  // Reset filters to the original selected ingredients
  void _resetFilters() {
    setState(() {
      selectedIngredients.clear(); // Clear all selected ingredients
    });
    widget.onSelectionChanged(
        selectedIngredients); // Notify parent with empty set
  }

  // Save the selected filters to Firebase (or any other storage)
  Future<void> _saveFilters() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'foodIngredient': selectedIngredients.toList(),
    }, SetOptions(merge: true));
  }

  // Apply filters and save the selected ingredients (without popping the dialog)
  void _applyFilters() {
    widget.onSelectionChanged(
        selectedIngredients); // Notify parent with selected ingredients
    _saveFilters(); // Save the selected ingredients to Firebase
    // Navigator.pop(context); // Close the modal
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFilterChips(foodIngredient, selectedIngredients, "Ingredients"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _resetFilters,
                child: Text('Reset',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  minimumSize: Size(120, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyFilters();
                  _saveFilters();
                },
                child: Text('Apply',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF39C184),
                  minimumSize: Size(120, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
      List<String> options, Set<String> selectedOptions, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            bool isSelected = selectedOptions.contains(option);
            return ChoiceChip(
              label: Text(option,
                  style: TextStyle(
                      color: isSelected ? Color(0xFF39C184) : Colors.black54)),
              selected: isSelected,
              onSelected: (bool selectedValue) {
                setState(() {
                  if (selectedValue) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
                  }
                });
              },
              selectedColor: Color(0xFF39C184).withOpacity(0.3),
              side: BorderSide(
                  color: isSelected ? Color(0xFF39C184) : Colors.grey,
                  width: 1.4),
              labelStyle:
                  TextStyle(color: isSelected ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

// Allergy
class AllergyFilter extends StatefulWidget {
  final Set<String> selectedAllergies;
  final Function(Set<String>) onSelectionChanged;

  AllergyFilter({
    required this.selectedAllergies,
    required this.onSelectionChanged,
  });

  @override
  _AllergyFilterState createState() => _AllergyFilterState();
}

class _AllergyFilterState extends State<AllergyFilter> {
  List<String> foodAllergy = [
    'Nuts',
    'Dairy',
    'Shellfish',
    'Gluten',
    'Wheat',
    'Sulfites',
    'Eggs',
    'Peanuts',
    'Tree-Nuts',
    'FODMAP'
  ];

  late Set<String> selectedAllergies;

  @override
  void initState() {
    super.initState();
    selectedAllergies = Set.from(widget.selectedAllergies);
  }

  // Save selected allergies to Firebase
  Future<void> _saveAllergies() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'foodAllergy': selectedAllergies.toList(),
    }, SetOptions(merge: true));
  }

  // Reset the selected allergies
  void _resetFilters() {
    setState(() {
      selectedAllergies.clear(); // Clears all selected allergies
    });
    widget.onSelectionChanged(
        Set.from(selectedAllergies)); // Notify parent with empty set
  }

  // Apply filters and save to Firebase
  void _applyFilters() {
    widget.onSelectionChanged(
        selectedAllergies); // Notify parent with selected allergies
    _saveAllergies(); // Save selected allergies to Firebase
    Navigator.pop(context, selectedAllergies);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFilterChips(foodAllergy, selectedAllergies, "Allergies"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _resetFilters,
                child: Text('Reset',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  minimumSize: Size(120, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _applyFilters();
                  _saveAllergies();
                },
                child: Text('Apply',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF39C184),
                  minimumSize: Size(120, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
      List<String> options, Set<String> selectedOptions, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            bool isSelected = selectedOptions.contains(option);
            return ChoiceChip(
              label: Text(option,
                  style: TextStyle(
                      color: isSelected ? Color(0xFF39C184) : Colors.black54)),
              selected: isSelected,
              onSelected: (bool selectedValue) {
                setState(() {
                  if (selectedValue) {
                    selectedOptions.add(option);
                  } else {
                    selectedOptions.remove(option);
                  }
                });
              },
              selectedColor: Color(0xFF39C184).withOpacity(0.3),
              side: BorderSide(
                  color: isSelected ? Color(0xFF39C184) : Colors.grey,
                  width: 1.4),
              labelStyle:
                  TextStyle(color: isSelected ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
