import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
User? _user;

Future<Map<String, dynamic>?> showFilterSheet(BuildContext context) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return FilterSheet();
    },
  );
}

class FilterSheet extends StatefulWidget {
  @override
  _FilterSheetState createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  double _selectedCalories = 100;
  Set<String> selectedFoodCookingTechnique = {};
  Set<String> selectedFoodAllergy = {};
  Set<String> selectedFoodCategory = {};
  Set<String> selectedFoodFlavor = {};

  final List<String> foodCookingTechnique = [
    'Boiling',
    'Frying',
    'Baking',
    'Grilling',
    'Steaming'
  ];
  final List<String> foodAllergy = ['Egg', 'Milk', 'Fish', 'Nuts', 'Soybeans'];
  final List<String> foodCategory = ['Italian', 'Japanese', 'Chinese', 'Thai'];
  final List<String> foodFlavor = ['Sweet', 'Salty', 'Spicy', 'Sour', 'Bitter'];

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
        selectedFoodCookingTechnique =
            Set<String>.from(data?['foodCookingTechnique'] ?? []);
        selectedFoodAllergy = Set<String>.from(data?['foodAllergy'] ?? []);
        selectedFoodCategory = Set<String>.from(data?['foodCategory'] ?? []);
        selectedFoodFlavor = Set<String>.from(data?['foodFlavor'] ?? []);
      });
    }
  }

  Future<void> _saveFilters() async {
    if (_user == null) return;

    await _firestore.collection('users').doc(_user!.uid).set({
      'calories': _selectedCalories,
      'foodCookingTechnique': selectedFoodCookingTechnique.toList(),
      'foodAllergy': selectedFoodAllergy.toList(),
      'foodCategory': selectedFoodCategory.toList(),
      'foodFlavor': selectedFoodFlavor.toList(),
    }, SetOptions(merge: true));
  }

  Widget _buildFilterChips(
      List<String> options, Set<String> selected, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            bool isSelected = selected.contains(option);
            return ChoiceChip(
              label: Text(option,
                  style: TextStyle(
                      color: isSelected ? Color(0xFF39C184) : Colors.black54)),
              selected: isSelected,
              onSelected: (bool selectedValue) {
                setState(() {
                  if (selectedValue) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Filter',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
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
            CategoryFilter(
              selectedCategories: selectedFoodCategory,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedFoodCategory = selected;
                });
              },
            ),
            TechniqueFilter(
              selectedTechniques: selectedFoodCookingTechnique,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedFoodCookingTechnique = selected;
                });
              },
            ),
            IngredientFilter(
              selectedIngredients:
                  selectedFoodCategory, // Example: using categories here, change as needed
              onSelectionChanged: (selected) {
                setState(() {
                  selectedFoodCategory = selected;
                });
              },
            ),
            AllergyFilter(
              selectedAllergies: selectedFoodAllergy,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedFoodAllergy = selected;
                });
              },
            ),
            // _buildFilterChips(foodCookingTechnique,
            //     selectedFoodCookingTechnique, "Cooking Techniques"),
            // _buildFilterChips(
            //     foodAllergy, selectedFoodAllergy, "Food Allergies"),
            // _buildFilterChips(
            //     foodCategory, selectedFoodCategory, "Food Categories"),
            // _buildFilterChips(foodFlavor, selectedFoodFlavor, "Food Flavors"),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCalories = 100;
                      selectedFoodCookingTechnique.clear();
                      selectedFoodAllergy.clear();
                      selectedFoodCategory.clear();
                      selectedFoodFlavor.clear();
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
                    _saveFilters();
                    Navigator.pop(context, {
                      'calories': _selectedCalories,
                      'foodCookingTechnique':
                          selectedFoodCookingTechnique.toList(),
                      'foodAllergy': selectedFoodAllergy.toList(),
                      'foodCategory': selectedFoodCategory.toList(),
                      'foodFlavor': selectedFoodFlavor.toList(),
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

  final List<String> foodCookingTechnique = [
    'Boiling',
    'Frying',
    'Baking',
    'Grilling',
    'Steaming'
  ];
  final List<String> foodAllergy = ['Egg', 'Milk', 'Fish', 'Nuts', 'Soybeans'];
  final List<String> foodCategory = ['Italian', 'Japanese', 'Chinese', 'Thai'];
  final List<String> foodFlavor = ['Sweet', 'Salty', 'Spicy', 'Sour', 'Bitter'];

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
    'Italian',
    'Japanese',
    'Chinese',
    'Thai',
  ];

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            children: [
              Text(
                "Food Categories",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(
                _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 20,
                color: Color(0xFF39C184),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft, // Align content at the bottom
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isExpanded ? 150 : 0, // Adjust height when expanded
            curve: Curves.easeInOut,
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8.0,
                children: foodCategories.map((option) {
                  bool isSelected = widget.selectedCategories.contains(option);
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
                          widget.selectedCategories.add(option);
                        } else {
                          widget.selectedCategories.remove(option);
                        }
                        widget.onSelectionChanged(widget.selectedCategories);
                      });
                    },
                    selectedColor: Color(0xFF39C184).withOpacity(0.3),
                    side: BorderSide(
                        color: isSelected ? Color(0xFF39C184) : Colors.grey,
                        width: 1.4),
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

// Technique
class TechniqueFilter extends StatefulWidget {
  final Set<String> selectedTechniques;
  final Function(Set<String>) onSelectionChanged;

  TechniqueFilter({
    required this.selectedTechniques,
    required this.onSelectionChanged,
  });

  @override
  _TechniqueFilterState createState() => _TechniqueFilterState();
}

class _TechniqueFilterState extends State<TechniqueFilter> {
  final List<String> foodTechniques = [
    'Boiling',
    'Frying',
    'Baking',
    'Grilling',
    'Steaming'
  ];

  @override
  Widget build(BuildContext context) {
    return _buildFilterChips(
        foodTechniques, widget.selectedTechniques, "Cooking Techniques");
  }

  Widget _buildFilterChips(
      List<String> options, Set<String> selected, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            bool isSelected = selected.contains(option);
            return ChoiceChip(
              label: Text(option,
                  style: TextStyle(
                      color: isSelected ? Color(0xFF39C184) : Colors.black54)),
              selected: isSelected,
              onSelected: (bool selectedValue) {
                setState(() {
                  if (selectedValue) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
                  }
                  widget.onSelectionChanged(selected);
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

// Ingredient
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
  final List<String> ingredients = [
    'Tomato',
    'Onion',
    'Garlic',
    'Cheese',
    'Chicken'
  ];

  @override
  Widget build(BuildContext context) {
    return _buildFilterChips(
        ingredients, widget.selectedIngredients, "Ingredients");
  }

  Widget _buildFilterChips(
      List<String> options, Set<String> selected, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            bool isSelected = selected.contains(option);
            return ChoiceChip(
              label: Text(option,
                  style: TextStyle(
                      color: isSelected ? Color(0xFF39C184) : Colors.black54)),
              selected: isSelected,
              onSelected: (bool selectedValue) {
                setState(() {
                  if (selectedValue) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
                  }
                  widget.onSelectionChanged(selected);
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
  final List<String> allergies = ['Egg', 'Milk', 'Fish', 'Nuts', 'Soybeans'];

  @override
  Widget build(BuildContext context) {
    return _buildFilterChips(
        allergies, widget.selectedAllergies, "Food Allergies");
  }

  Widget _buildFilterChips(
      List<String> options, Set<String> selected, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            bool isSelected = selected.contains(option);
            return ChoiceChip(
              label: Text(option,
                  style: TextStyle(
                      color: isSelected ? Color(0xFF39C184) : Colors.black54)),
              selected: isSelected,
              onSelected: (bool selectedValue) {
                setState(() {
                  if (selectedValue) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
                  }
                  widget.onSelectionChanged(selected);
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
