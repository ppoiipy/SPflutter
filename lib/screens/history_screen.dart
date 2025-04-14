// 5
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'food_detail_screen.dart';
import 'filter_sheet.dart';
import 'homepage.dart';
import 'favorite_screen.dart';
import 'calculate_screen.dart';
import 'profile_screen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentIndex = 1;

  DateTime selectedDate = DateTime.now();

  List<Map<String, dynamic>> _loggedMeals = [];

  @override
  void initState() {
    super.initState();
    _loadFoodLog();
  }

  Future<void> _loadFoodLog() async {
    var user = _auth.currentUser;
    if (user == null) return;

    // Format the date range based on the selected date (start of day to end of day)
    DateTime startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    DateTime endOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day + 1);

    // Convert to Firestore-compatible DateTime objects
    var startTimestamp = Timestamp.fromDate(startOfDay);
    var endTimestamp = Timestamp.fromDate(endOfDay);

    var snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('food_log')
        .where('date', isGreaterThanOrEqualTo: startTimestamp)
        .where('date', isLessThan: endTimestamp)
        .get();

    setState(() {
      _loggedMeals = snapshot.docs.map((doc) => doc.data()).toList();
      print("Loaded meals: $_loggedMeals");
    });
  }

  Future<void> _pickDate() async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (newSelectedDate != null && newSelectedDate != selectedDate) {
      setState(() {
        selectedDate = newSelectedDate;
      });
      _loadFoodLog();
    }
  }

  void _changeDate(int dayOffset) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: dayOffset));
    });
    _loadFoodLog();
  }

  Future<void> logRecipeClick(String recipeLabel, String recipeShareAs) async {
    try {
      // Get the current user's ID (from FirebaseAuth)
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get reference to the user's 'clicks' subcollection
        CollectionReference clicks = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('clicks');

        // Reference to the recipe document using the recipeLabel as document ID
        DocumentReference recipeRef = clicks.doc(recipeLabel);

        // Get the document to check if it exists
        DocumentSnapshot snapshot = await recipeRef.get();

        // If the document exists, increment the click count
        if (snapshot.exists) {
          // Update the existing click count
          await recipeRef.update({
            'clickCount': FieldValue.increment(1),
          });
        } else {
          // If the document doesn't exist, create a new one with clickCount = 1
          await recipeRef.set({
            'clickCount': 1,
            'shareAs': recipeShareAs,
          });
        }

        print('Click logged successfully for $recipeLabel!');
      } else {
        print('User is not logged in.');
      }
    } catch (e) {
      print('Error logging click: $e');
    }
  }

  String formatNumber(int number) {
    return NumberFormat("#,###").format(number);
  }

  Future<void> _removeMeal(Map<String, dynamic> meal) async {
    var user = _auth.currentUser;
    if (user == null) return;

    var query = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('food_log')
        .where('recipe.label', isEqualTo: meal['recipe']['label'])
        .where('mealType', isEqualTo: meal['mealType'])
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }

    _loadFoodLog();
  }

  Widget _buildMealCategory(String category) {
    // Filter meals by selected date and category
    List<Map<String, dynamic>> meals =
        _loggedMeals.where((meal) => meal['mealType'] == category).toList();

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          meals.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("No meals logged"),
                )
              : Column(
                  children: meals.map((meal) {
                    var recipe = meal['recipe'];
                    return ListTile(
                      leading: Image.asset(
                        'assets/fetchMenu/' +
                            recipe['label']
                                ?.toLowerCase()
                                .replaceAll(' ', '_') +
                            '.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/default.png', // Fallback image
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      title: Text(recipe['label'] ?? 'Unknown Recipe'),
                      subtitle: Text(
                          "${formatNumber(recipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt())} kcal"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeMeal(meal),
                      ),
                      onTap: () {
                        logRecipeClick(recipe['label'], recipe['shareAs']);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetailScreen(
                              recipe: recipe,
                              selectedDate:
                                  selectedDate, // Pass selected date here
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildMealPlans() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildMealCategory('Breakfast'),
            _buildMealCategory('Lunch'),
            _buildMealCategory('Dinner'),
            _buildMealCategory('Snack'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'History Meal Record',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, size: 32),
                    onPressed: () => _changeDate(-1),
                  ),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Text(
                      DateFormat('dd MMM yyyy').format(selectedDate),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, size: 32),
                    onPressed: () => _changeDate(1),
                  ),
                ],
              ),
              Positioned(
                right: 30,
                child: Icon(Icons.calendar_month),
              ),
            ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     IconButton(
          //       icon: Icon(Icons.arrow_left, color: Colors.black, size: 32),
          //       onPressed: () => _changeDate(-1),
          //     ),
          //     GestureDetector(
          //       onTap: _pickDate,
          //       child: Text(
          //         DateFormat('dd MMM yyyy').format(selectedDate),
          //         style: TextStyle(
          //             fontSize: 18,
          //             fontWeight: FontWeight.w600,
          //             color: Colors.black),
          //       ),
          //     ),
          //     IconButton(
          //       icon: Icon(
          //         Icons.arrow_right,
          //         color: Colors.black,
          //         size: 32,
          //       ),
          //       onPressed: () => _changeDate(1),
          //     ),
          //   ],
          // ),
          _buildMealPlans(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF1F5F5B),
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(color: Color(0xFF1F5F5B)),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Homepage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HistoryScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FavoriteScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CalculateScreen()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border_outlined,
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calculate_outlined,
            ),
            label: 'Calculate',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
// class MenuScreen extends StatefulWidget {
//   @override
//   _MenuScreenState createState() => _MenuScreenState();
// }

// class _MenuScreenState extends State<MenuScreen> {
//   final int _currentIndex = 1;

//   Map<String, dynamic>? selectedFilters;
//   double? _selectedCalories;
//   Set<String> selectedCategories = {};
//   Set<String> selectedIngredients = {};
//   Set<String> selectedAllergies = {};

//   List<dynamic> recipes = [];
//   List<dynamic> filteredRecipes = [];
//   TextEditingController searchController = TextEditingController();
//   String selectedCuisineType = "All";

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Map<String, bool> favoriteRecipes = {};

//   List<Map<String, dynamic>> allRecipes = [];

//   @override
//   void initState() {
//     super.initState();
//     loadJsonData();
//     _loadUserFilters(); // Load filters from Firebase when screen starts
//   }

//   String formatNumber(int number) {
//     return NumberFormat("#,###").format(number);
//   }

//   // Load user-selected filters from Firebase
//   Future<void> _loadUserFilters() async {
//     var user = _auth.currentUser;
//     if (user == null) return;

//     var userDoc = await _firestore.collection('users').doc(user.uid).get();

//     if (userDoc.exists) {
//       var data = userDoc.data();
//       setState(() {
//         selectedCategories = (data?['foodCategory'] as List<dynamic>?)
//                 ?.map((e) => e.toString())
//                 .toSet() ??
//             {};
//       });
//     }
//   }

//   // Load data from JSON file in assets/fetchMenu
//   void loadJsonData() async {
//     String jsonData =
//         await rootBundle.loadString('assets/fetchMenu/recipe_output.json');
//     Map<String, dynamic> jsonMap = json.decode(jsonData);
//     recipes = jsonMap['hits'].map((hit) => hit['recipe']).toList();

//     await _loadFavorites();

//     setState(() {
//       filteredRecipes = List.from(recipes);
//       allRecipes = List.from(recipes);
//     });
//   }

//   Future<void> _loadFavorites() async {
//     var user = _auth.currentUser;
//     if (user == null) return;

//     var favoritesSnapshot = await _firestore
//         .collection('users')
//         .doc(user.uid)
//         .collection('favorites')
//         .get();

//     var favoriteSet = favoritesSnapshot.docs.map((doc) => doc.id).toSet();

//     setState(() {
//       favoriteRecipes = {
//         for (var recipe in recipes)
//           recipe['label']: favoriteSet.contains(recipe['label'])
//       };
//     });
//   }

//   // Filter recipes based on search query and cuisineType
//   void filterRecipes(String query, String cuisineType) {
//     setState(() {
//       filteredRecipes = recipes
//           .where((recipe) =>
//               recipe['label'].toLowerCase().contains(query.toLowerCase()) &&
//               (cuisineType == "All" ||
//                   recipe['cuisineType']
//                       .toString()
//                       .toLowerCase()
//                       .contains(cuisineType.toLowerCase()) ||
//                   recipe['label']
//                       .toString()
//                       .toLowerCase()
//                       .contains(cuisineType.toLowerCase())) &&
//               (selectedCategories.isEmpty ||
//                   selectedCategories.contains(recipe['cuisineType'])))
//           .toList();
//     });
//   }

//   // Filter recipes based on _selectedCalories
//   void _filterRecipesByCalories() {
//     setState(() {
//       filteredRecipes = allRecipes.where((recipe) {
//         if (_selectedCalories == null) return true; // No calorie filter applied

//         double calories = recipe['calories'] ?? 0.0;
//         return calories <= _selectedCalories!;
//       }).toList();
//     });

//     print(
//         "Filtered Recipes by Calories: ${filteredRecipes.map((r) => r['label']).toList()}");
//   }

//   // Call Filter Sheet Function
//   void openFilterSheet() async {
//     final filters = await showFilterSheet(context);
//     if (filters != null) {
//       setState(() {
//         selectedFilters = filters;
//         _selectedCalories = filters['calories']; // Get calories filter
//         _filterRecipesByCalories(); // Apply filter
//         _filterRecipesByIngredients();
//       });
//       print("Selected Filters: $selectedFilters");
//     }
//   }

//   Future<Map<String, dynamic>?> showFilterSheet(BuildContext context) {
//     return showModalBottomSheet<Map<String, dynamic>>(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       isScrollControlled: true,
//       builder: (context) {
//         return FilterSheet(
//           initialCalories: _selectedCalories, // Pass the current value
//           onFiltersApplied: (filters) {
//             Navigator.pop(context, filters);
//           },
//         );
//       },
//     );
//   }

//   // Open Calorie Filter
//   Future<double?> showCalorieFilterSheet(
//       BuildContext context, double initialCalories) {
//     return showModalBottomSheet<double>(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return CalorieFilterSheet(
//           initialCalories: initialCalories,
//           onCaloriesChanged: (calories) {
//             Navigator.pop(context, calories);
//           },
//         );
//       },
//     );
//   }

//   // Open Category Filter
//   Future<Set<String>?> showCategoryFilterSheet(
//       BuildContext context, Set<String> selectedCategories) async {
//     var user = _auth.currentUser;
//     if (user == null) return null;

//     // Fetch categories from Firebase
//     var userDoc = await _firestore.collection('users').doc(user.uid).get();
//     var data = userDoc.data();

//     Set<String> loadedCategories = {};
//     if (data != null && data['foodCategory'] != null) {
//       loadedCategories = Set<String>.from(data['foodCategory']);
//     }

//     return showModalBottomSheet<Set<String>>(
//       context: context,
//       isScrollControlled: false, // Prevents full-screen height
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height * 0.5,
//           padding: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: CategoryFilter(
//             selectedCategories: loadedCategories,
//             onSelectionChanged: (updatedCategories) {
//               Navigator.pop(context, updatedCategories);
//             },
//           ),
//         );
//       },
//     );
//   }

//   void _filterRecipesByCategories({bool startFromAllRecipes = false}) {
//     setState(() {
//       print("All cuisine types:");
//       for (var recipe in allRecipes) {
//         print(recipe['cuisineType']);
//       }

//       filteredRecipes =
//           (startFromAllRecipes ? allRecipes : filteredRecipes).where((recipe) {
//         if (selectedCategories.isEmpty)
//           return true; // No category filter applied

//         // Check if recipe's cuisineType matches any selected category
//         bool containsSelectedCategories = selectedCategories.any((category) {
//           var cuisineType = recipe['cuisineType'];

//           // Ensure cuisineType is a list and check if any element matches
//           if (cuisineType is List) {
//             return cuisineType.any((cuisine) {
//               if (cuisine is String) {
//                 return cuisine.toLowerCase().contains(category.toLowerCase());
//               }
//               return false;
//             });
//           } else if (cuisineType is String) {
//             return cuisineType.toLowerCase().contains(category.toLowerCase());
//           }

//           return false;
//         });

//         return containsSelectedCategories; // Include recipes that match any of the selected categories
//       }).toList();
//     });

//     print(
//         "Filtered Recipes by Categories: ${filteredRecipes.map((r) => r['label']).toList()}");
//   }

//   Future<Set<String>?> showIngredientFilterSheet(
//       BuildContext context, Set<String> selectedIngredients) async {
//     var user = _auth.currentUser;
//     if (user == null) return null;

//     var userDoc = await _firestore.collection('users').doc(user.uid).get();
//     var data = userDoc.data();

//     Set<String> loadedIngredients = {};
//     if (data != null && data['foodIngredient'] != null) {
//       loadedIngredients = Set<String>.from(data['foodIngredient']);
//     }

//     return await showModalBottomSheet<Set<String>>(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return IngredientFilter(
//           selectedIngredients: loadedIngredients,
//           onSelectionChanged: (selected) {
//             print("Ingredient Selection Updated: $selected"); // Debugging
//             Navigator.pop(context, selected);
//           },
//         );
//       },
//     );
//   }

//   void _filterRecipesByIngredients({bool startFromAllRecipes = false}) {
//     setState(() {
//       filteredRecipes =
//           (startFromAllRecipes ? allRecipes : filteredRecipes).where((recipe) {
//         if (selectedIngredients.isEmpty)
//           return true; // No ingredient filter applied

//         // Check if recipe contains any selected ingredients
//         bool containsSelectedIngredients =
//             recipe['ingredients'].any((ingredient) {
//           String food = ingredient['food'].toLowerCase();
//           return selectedIngredients
//               .any((selected) => food.contains(selected.toLowerCase()));
//         });

//         return containsSelectedIngredients; // Include recipes that contain at least one of the selected ingredients
//       }).toList();
//     });

//     print(
//         "Filtered Recipes by Ingredients: ${filteredRecipes.map((r) => r['label']).toList()}");
//   }

//   Future<Set<String>?> showAllergyFilterSheet(
//       BuildContext context, Set<String> selectedAllergies) async {
//     var user = _auth.currentUser;
//     if (user == null) return null;

//     var userDoc = await _firestore.collection('users').doc(user.uid).get();
//     var data = userDoc.data();

//     Set<String> loadedAllergies = {};
//     if (data != null && data['foodAllergy'] != null) {
//       loadedAllergies = Set<String>.from(data['foodAllergy']);
//     }

//     return await showModalBottomSheet<Set<String>>(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return AllergyFilter(
//           selectedAllergies: loadedAllergies,
//           onSelectionChanged: (selected) {
//             // Navigator.pop(context, selected);
//           },
//         );
//       },
//     );
//   }

//   void _filterRecipesByAllergies({bool startFromAllRecipes = false}) {
//     setState(() {
//       print("All Cautions in Recipes:");
//       for (var recipe in allRecipes) {
//         print("${recipe['label']}: ${recipe['cautions']}");
//       }

//       print("All cuisine types:");
//       for (var recipe in allRecipes) {
//         print(recipe['cuisineType']);
//       }

//       print(
//           "Allergy Filtering Started. Selected Allergies: $selectedAllergies");

//       filteredRecipes =
//           (startFromAllRecipes ? allRecipes : filteredRecipes).where((recipe) {
//         if (selectedAllergies.isEmpty) return true; // No allergy filter applied

//         var cautions = recipe['cautions'];

//         // Ensure cautions is a list before processing
//         if (cautions is List) {
//           bool containsAllergy = selectedAllergies.any((allergy) {
//             return cautions.any((caution) {
//               if (caution is String) {
//                 return caution.toLowerCase().contains(allergy.toLowerCase());
//               }
//               return false;
//             });
//           });

//           return !containsAllergy; // Exclude recipes that match any selected allergy
//         }

//         return true; // If no cautions, include the recipe
//       }).toList();
//     });

//     print(
//         "Filtered Recipes by Allergies: ${filteredRecipes.map((r) => r['label']).toList()}");
//   }

//   Future<void> logRecipeClick(String recipeLabel, String recipeShareAs) async {
//     try {
//       // Get the current user's ID (from FirebaseAuth)
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         // Get reference to the user's 'clicks' subcollection
//         CollectionReference clicks = FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('clicks');

//         // Reference to the recipe document using the recipeLabel as document ID
//         DocumentReference recipeRef = clicks.doc(recipeLabel);

//         // Get the document to check if it exists
//         DocumentSnapshot snapshot = await recipeRef.get();

//         // If the document exists, increment the click count
//         if (snapshot.exists) {
//           // Update the existing click count
//           await recipeRef.update({
//             'clickCount': FieldValue.increment(1),
//           });
//         } else {
//           // If the document doesn't exist, create a new one with clickCount = 1
//           await recipeRef.set({
//             'clickCount': 1,
//             'shareAs': recipeShareAs,
//           });
//         }

//         print('Click logged successfully for $recipeLabel!');
//       } else {
//         print('User is not logged in.');
//       }
//     } catch (e) {
//       print('Error logging click: $e');
//     }
//   }

//   Future<void> _toggleFavorite(
//       String recipeLabel, Map<String, dynamic> recipe) async {
//     var user = _auth.currentUser;
//     if (user == null) return;

//     var favoriteRef = _firestore
//         .collection('users')
//         .doc(user.uid)
//         .collection('favorites')
//         .doc(recipeLabel);

//     if (favoriteRecipes[recipeLabel] == true) {
//       // Remove from favorites
//       await favoriteRef.delete();
//     } else {
//       // Add to favorites
//       await favoriteRef.set(recipe);
//     }

//     setState(() {
//       favoriteRecipes[recipeLabel] = !favoriteRecipes[recipeLabel]!;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         title: Text(
//           'Recipe Search',
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontFamily: 'Inter',
//             letterSpacing: 1,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Search Field
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 20, bottom: 5),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     'Search',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//                 child: Material(
//                   borderRadius: BorderRadius.circular(15),
//                   elevation: 3,
//                   shadowColor: Colors.black26,
//                   child: TextFormField(
//                     controller: searchController,
//                     decoration: InputDecoration(
//                       contentPadding: EdgeInsets.symmetric(vertical: 12),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide: BorderSide(color: Colors.transparent),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide:
//                             BorderSide(color: Color(0xFF1F5F5B), width: 1.5),
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       prefixIcon: IconButton(
//                         icon: Icon(Icons.search, color: Colors.grey[700]),
//                         splashRadius: 22, // Better touch feedback
//                         onPressed: () {
//                           filterRecipes(
//                               searchController.text, selectedCuisineType);
//                         },
//                       ),
//                       suffixIcon: IconButton(
//                         icon: Icon(Icons.tune, color: Color(0xFF1F5F5B)),
//                         splashRadius: 22,
//                         onPressed: () {
//                           openFilterSheet();
//                         },
//                       ),
//                       hintText: 'Search food...',
//                       hintStyle: TextStyle(color: Colors.grey[600]),
//                     ),
//                     onFieldSubmitted: (query) {
//                       filterRecipes(query, selectedCuisineType);
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           // Scroll List
//           Padding(
//             padding: const EdgeInsets.only(top: 15),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   // Icons.tune,
//                   Icons.fastfood,
//                   Icons.category,
//                   Icons.kitchen,
//                   Icons.warning,
//                 ].map((icon) {
//                   return GestureDetector(
//                     onTap: () async {
//                       if (icon == Icons.tune) {
//                         // Open filter modal
//                         Map<String, dynamic>? result =
//                             await showFilterSheet(context);
//                         if (result != null) {
//                           setState(() {
//                             _selectedCalories = result['calories'];
//                             _filterRecipesByCalories();
//                             _filterRecipesByIngredients();
//                             _filterRecipesByCategories();
//                             _filterRecipesByAllergies();
//                           });
//                           print("Updated Calories: $_selectedCalories");
//                         }
//                       } else if (icon == Icons.fastfood) {
//                         double? result = await showCalorieFilterSheet(
//                             context, _selectedCalories ?? 100);
//                         if (result != null) {
//                           print("Updated Calories: $result");
//                           setState(() {
//                             _selectedCalories = result;
//                             _filterRecipesByCalories();
//                           });
//                         }
//                       } else if (icon == Icons.category) {
//                         Set<String>? result = await showCategoryFilterSheet(
//                             context, selectedCategories);
//                         if (result != null) {
//                           setState(() {
//                             selectedCategories = result;
//                             _filterRecipesByCategories(
//                                 startFromAllRecipes: true);
//                           });
//                           print("Selected Categories: $selectedCategories");
//                         }
//                       } else if (icon == Icons.kitchen) {
//                         Set<String>? result = await showIngredientFilterSheet(
//                             context, selectedIngredients);
//                         if (result != null) {
//                           setState(() {
//                             selectedIngredients = result;
//                             _filterRecipesByIngredients(
//                                 startFromAllRecipes: true);
//                           });
//                           print("Selected Ingredients: $selectedIngredients");
//                         }
//                       } else if (icon == Icons.warning) {
//                         Set<String>? result = await showAllergyFilterSheet(
//                             context, selectedAllergies);
//                         if (result != null) {
//                           setState(() {
//                             selectedAllergies = result;
//                             _filterRecipesByAllergies(
//                                 startFromAllRecipes: true);
//                           });
//                           print("Selected Allergies: $selectedAllergies");
//                         }
//                       }
//                     },
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 7),
//                       child: Column(
//                         children: [
//                           Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(15),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.2),
//                                   spreadRadius: 2,
//                                   blurRadius: 5,
//                                   offset: Offset(0, 3),
//                                 ),
//                               ],
//                             ),
//                             child: Center(
//                               child: Icon(
//                                 icon,
//                                 size: 30,
//                                 color: Color(0xFF1F5F5B),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 5),
//                           Text(
//                             // icon == Icons.tune
//                             //     ? 'Edit'
//                             // : icon == Icons.category
//                             icon == Icons.category
//                                 ? 'Category'
//                                 : icon == Icons.kitchen
//                                     ? 'Ingredients'
//                                     : icon == Icons.warning
//                                         ? 'Allergy'
//                                         : 'Calories',
//                             style: TextStyle(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w500,
//                               color: Color(0xFF1F5F5B),
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),

//           SizedBox(height: 10),

//           // Recipe List
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredRecipes.length,
//               itemBuilder: (context, index) {
//                 var recipe = filteredRecipes[index];
//                 String imagePath = 'assets/fetchMenu/' +
//                     recipe['label'].replaceAll(' ', '_') +
//                     '.jpg';

//                 return Stack(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(right: 20),
//                       child: ListTile(
//                         leading: Image.asset(
//                           imagePath,
//                           width: 50,
//                           height: 50,
//                           fit: BoxFit.cover,
//                           errorBuilder: (BuildContext context, Object error,
//                               StackTrace? stackTrace) {
//                             return Image.asset(
//                               'assets/images/default.png',
//                               width: 50,
//                               height: 50,
//                               fit: BoxFit.cover,
//                             );
//                           },
//                         ),
//                         title: Text(recipe['label']),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.local_fire_department_outlined,
//                                   color: Colors.red,
//                                 ),
//                                 Text(
//                                   "${formatNumber(recipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt())} ${recipe['totalNutrients']['ENERC_KCAL']['unit']}",
//                                 ),
//                               ],
//                             ),
//                             Text(recipe['source']),
//                           ],
//                         ),
//                         onTap: () {
//                           logRecipeClick(recipe['label'], recipe['shareAs']);

//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   FoodDetailScreen(recipe: recipe),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     // Favorite Icon on Top-Right
//                     Positioned(
//                       top: 5, // Adjust top position
//                       right: 5, // Adjust right position
//                       child: IconButton(
//                         icon: Icon(
//                           favoriteRecipes[recipe['label']] == true
//                               ? Icons.star
//                               : Icons.star_border,
//                           size: 30,
//                           color: favoriteRecipes[recipe['label']] == true
//                               ? Color.fromARGB(255, 255, 191, 0)
//                               : Colors.grey,
//                         ),
//                         onPressed: () {
//                           _toggleFavorite(recipe['label'], recipe);
//                         },
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Color(0xFF1F5F5B),
//         unselectedItemColor: Colors.black,
//         selectedLabelStyle: TextStyle(color: Color(0xFF1F5F5B)),
//         unselectedLabelStyle: TextStyle(color: Colors.black),
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           if (index == 0) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => Homepage()),
//             );
//           } else if (index == 1) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => MenuScreen()),
//             );
//           } else if (index == 2) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => FavoriteScreen()),
//             );
//           } else if (index == 3) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => CalculateScreen()),
//             );
//           } else if (index == 4) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => ProfileScreen()),
//             );
//           }
//         },
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.home_outlined,
//             ),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.food_bank_outlined,
//             ),
//             label: 'Search',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.favorite_border_outlined,
//             ),
//             label: 'Favorites',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.calculate_outlined,
//             ),
//             label: 'Calculate',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               Icons.person_outline,
//             ),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }
