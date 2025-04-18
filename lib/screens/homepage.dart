import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import 'package:flutter/services.dart'; // For rootBundle
import 'package:intl/intl.dart';

import 'package:ginraidee/screens/filter_sheet.dart';
import 'package:ginraidee/screens/food_detail_screen.dart';
import 'package:ginraidee/screens/nutrition_tracking_screen.dart';
import 'package:ginraidee/screens/history_screen.dart';
import 'favorite_screen.dart';
import 'calculate_screen.dart';
import 'profile_screen.dart';
import 'calorie_tracking_screen.dart';
import 'meal_planning_screen.dart';

// import 'package:flutter_application_1/api/fetch_food_api.dart';
// import 'fetch_food_data.dart';

// Get DB Path

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final int _currentIndex = 0;
  final int _selectedIndex = 0;
  List foodItems = [];
  List<String> recommendedLabels = [];
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();

  Timer? _recipeStatsTimer;

  List<dynamic> recipes = [];
  List<dynamic> filteredRecipes = [];

  Map<String, dynamic>? selectedFilters;
  double? _selectedCalories;
  Set<String> selectedCategories = {};
  Set<String> selectedIngredients = {};
  Set<String> selectedAllergies = {};

  List<Map<String, dynamic>> allRecipes = [];

  String selectedCuisineType = "All";

  // MARK: initState
  @override
  void initState() {
    super.initState();
    loadJsonData();
    _loadUserFilters();
    printAllUserRecipeData();
    loadRecommendations();
    loadRecipeData();
  }

  @override
  void dispose() {
    _recipeStatsTimer?.cancel();
    super.dispose();
  }

  Future<void> loadRecommendations() async {
    User? user = _auth.currentUser; // Get current user
    if (user != null) {
      final results = await getRecommendedRecipes(user.uid); // Pass the userId
      setState(() {
        recommendedLabels = results;
        isLoading = false;
      });
    } else {
      print('User not logged in!');
    }
  }

  String formatNumber(int number) {
    return NumberFormat("#,###").format(number);
  }

  Future<void> _loadUserFilters() async {
    var user = _auth.currentUser;
    if (user == null) return;

    var userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      var data = userDoc.data();
      setState(() {
        selectedCategories = (data?['foodCategory'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toSet() ??
            {};
      });
    }
  }

  void loadJsonData() async {
    String jsonData =
        await rootBundle.loadString('assets/fetchMenu/recipe_output.json');
    // String jsonData =
    //     await rootBundle.loadString('assets/fetchMenu/thaifood_data.json');
    Map<String, dynamic> jsonMap = json.decode(jsonData);
    recipes = jsonMap['hits'].map((hit) => hit['recipe']).toList();

    await _loadFavorites();

    setState(() {
      filteredRecipes = List.from(recipes);
      allRecipes = List.from(recipes);
    });
  }

  // Call Filter Sheet Function
  void openFilterSheet() async {
    final filters = await showFilterSheet(context);
    if (filters != null) {
      setState(() {
        selectedFilters = filters;
        _selectedCalories = filters['calories']; // Get calories filter
        _filterRecipesByCalories(); // Apply filter
        _filterRecipesByIngredients();
      });
      print("Selected Filters: $selectedFilters");
    }
  }

  Future<Map<String, dynamic>?> showFilterSheet(context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return FilterSheet(
          initialCalories: _selectedCalories, // Pass the current value
          onFiltersApplied: (filters) {
            Navigator.pop(context, filters);
          },
        );
      },
    );
  }

  // MARK: Calorie
  Future<double?> showCalorieFilterSheet(
      BuildContext context, double initialCalories) {
    return showModalBottomSheet<double>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CalorieFilterSheet(
          initialCalories: initialCalories,
          onCaloriesChanged: (calories) {
            Navigator.pop(context, calories);
          },
        );
      },
    );
  }

  void _filterRecipesByCalories() {
    setState(() {
      filteredRecipes = allRecipes.where((recipe) {
        if (_selectedCalories == null) return true; // No calorie filter applied

        double calories =
            recipe['totalNutrients']['ENERC_KCAL']['quantity'] ?? 0.0;
        return calories <= _selectedCalories!;
      }).toList();
    });

    print(
        "Filtered Recipes by Calories: ${filteredRecipes.map((r) => r['label']).toList()}");
  }

  // MARK: Category
  Future<Set<String>?> showCategoryFilterSheet(
      BuildContext context, Set<String> selectedCategories) async {
    var user = _auth.currentUser;
    if (user == null) return null;

    // Fetch categories from Firebase
    var userDoc = await _firestore.collection('users').doc(user.uid).get();
    var data = userDoc.data();

    Set<String> loadedCategories = {};
    if (data != null && data['foodCategory'] != null) {
      loadedCategories = Set<String>.from(data['foodCategory']);
    }

    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: false, // Prevents full-screen height
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: CategoryFilter(
            selectedCategories: loadedCategories,
            onSelectionChanged: (updatedCategories) {
              Navigator.pop(context, updatedCategories);
            },
          ),
        );
      },
    );
  }

  void _filterRecipesByCategories({bool startFromAllRecipes = false}) {
    setState(() {
      print("All cuisine types:");
      for (var recipe in allRecipes) {
        print(recipe['cuisineType']);
      }

      filteredRecipes =
          (startFromAllRecipes ? allRecipes : filteredRecipes).where((recipe) {
        if (selectedCategories.isEmpty) {
          return true; // No category filter applied
        }

        // Check if recipe's cuisineType matches any selected category
        bool containsSelectedCategories = selectedCategories.any((category) {
          var cuisineType = recipe['cuisineType'];

          // Ensure cuisineType is a list and check if any element matches
          if (cuisineType is List) {
            return cuisineType.any((cuisine) {
              if (cuisine is String) {
                return cuisine.toLowerCase().contains(category.toLowerCase());
              }
              return false;
            });
          } else if (cuisineType is String) {
            return cuisineType.toLowerCase().contains(category.toLowerCase());
          }

          return false;
        });

        return containsSelectedCategories; // Include recipes that match any of the selected categories
      }).toList();
    });

    print(
        "Filtered Recipes by Categories: ${filteredRecipes.map((r) => r['label']).toList()}");
  }

  // MARK: Ingredient
  Future<Set<String>?> showIngredientFilterSheet(
      BuildContext context, Set<String> selectedIngredients) async {
    var user = _auth.currentUser;
    if (user == null) return null;

    var userDoc = await _firestore.collection('users').doc(user.uid).get();
    var data = userDoc.data();

    Set<String> loadedIngredients = {};
    if (data != null && data['foodIngredient'] != null) {
      loadedIngredients = Set<String>.from(data['foodIngredient']);
    }

    return await showModalBottomSheet<Set<String>>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return IngredientFilter(
          selectedIngredients: loadedIngredients,
          onSelectionChanged: (selected) {
            print("Ingredient Selection Updated: $selected"); // Debugging
            Navigator.pop(context, selected);
          },
        );
      },
    );
  }

  void _filterRecipesByIngredients({bool startFromAllRecipes = false}) {
    setState(() {
      filteredRecipes =
          (startFromAllRecipes ? allRecipes : filteredRecipes).where((recipe) {
        if (selectedIngredients.isEmpty) return true;

        // If ingredientLines is a list of strings
        bool containsSelectedIngredients =
            recipe['ingredientLines'].any((ingredient) {
          return selectedIngredients.any(
            (selected) =>
                ingredient.toLowerCase().contains(selected.toLowerCase()),
          );
        });

        return containsSelectedIngredients;
      }).toList();
    });

    print(
        "Filtered Recipes by Ingredients: ${filteredRecipes.map((r) => r['label']).toList()}");
  }

  // MARK: Allergy
  Future<Set<String>?> showAllergyFilterSheet(
      BuildContext context, Set<String> selectedAllergies) async {
    var user = _auth.currentUser;
    if (user == null) return null;

    var userDoc = await _firestore.collection('users').doc(user.uid).get();
    var data = userDoc.data();

    Set<String> loadedAllergies = {};
    if (data != null && data['foodAllergy'] != null) {
      loadedAllergies = Set<String>.from(data['foodAllergy']);
    }

    return await showModalBottomSheet<Set<String>>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AllergyFilter(
          selectedAllergies: loadedAllergies,
          onSelectionChanged: (selected) {
            // Navigator.pop(context, selected);
          },
        );
      },
    );
  }

  void _filterRecipesByAllergies({bool startFromAllRecipes = false}) {
    setState(() {
      print("All Cautions in Recipes:");
      for (var recipe in allRecipes) {
        print("${recipe['label']}: ${recipe['cautions']}");
      }

      print("All cuisine types:");
      for (var recipe in allRecipes) {
        print(recipe['cuisineType']);
      }

      print(
          "Allergy Filtering Started. Selected Allergies: $selectedAllergies");

      filteredRecipes =
          (startFromAllRecipes ? allRecipes : filteredRecipes).where((recipe) {
        if (selectedAllergies.isEmpty) return true; // No allergy filter applied

        var cautions = recipe['cautions'];

        // Ensure cautions is a list before processing
        if (cautions is List) {
          bool containsAllergy = selectedAllergies.any((allergy) {
            return cautions.any((caution) {
              if (caution is String) {
                return caution.toLowerCase().contains(allergy.toLowerCase());
              }
              return false;
            });
          });

          return !containsAllergy; // Exclude recipes that match any selected allergy
        }

        return true; // If no cautions, include the recipe
      }).toList();
    });

    print(
        "Filtered Recipes by Allergies: ${filteredRecipes.map((r) => r['label']).toList()}");
  }

  // MARK: Click
  Future<void> logRecipeClick(String recipeLabel, String recipeSource) async {
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
            'source': recipeSource,
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

  // MARK: Favorite
  Map<String, bool> favoriteRecipes = {};

  Future<void> _loadFavorites() async {
    var user = _auth.currentUser;
    if (user == null) return;

    var favoritesSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    var favoriteSet = favoritesSnapshot.docs.map((doc) => doc.id).toSet();

    setState(() {
      favoriteRecipes = {
        for (var recipe in recipes)
          recipe['label']: favoriteSet.contains(recipe['label'])
      };
    });
  }

  Future<void> _toggleFavorite(
      String recipeLabel, Map<String, dynamic> recipe) async {
    var user = _auth.currentUser;
    if (user == null) return;

    var favoriteRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(recipeLabel);

    if (favoriteRecipes[recipeLabel] == true) {
      // Remove from favorites
      await favoriteRef.delete();
    } else {
      // Add to favorites
      await favoriteRef.set(recipe);
    }

    setState(() {
      favoriteRecipes[recipeLabel] = !favoriteRecipes[recipeLabel]!;
    });
  }

  // Filter recipes based on search query and cuisineType
  void filterRecipes(String query, String cuisineType) {
    setState(() {
      filteredRecipes = recipes
          .where((recipe) =>
              recipe['label'].toLowerCase().contains(query.toLowerCase()) &&
              (cuisineType == "All" ||
                  recipe['cuisineType']
                      .toString()
                      .toLowerCase()
                      .contains(cuisineType.toLowerCase()) ||
                  recipe['label']
                      .toString()
                      .toLowerCase()
                      .contains(cuisineType.toLowerCase())))
          .toList();
    });
  }

  // MARK: Print User Data

  Future<void> printAllUserRecipeData() async {
    try {
      var userCollection = FirebaseFirestore.instance.collection('users');
      var snapshot = await userCollection.get();

      Map<String, int> recipeClickCounts = {};
      Map<String, int> recipeFavoriteCounts = {};
      Map<String, int> recipeLogCounts = {};

      for (var doc in snapshot.docs) {
        var email = doc['email'];
        // print('Email: $email');

        // food_log
        var foodLogCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .collection('food_log');

        var foodLogSnapshot = await foodLogCollection.get();
        for (var foodLogDoc in foodLogSnapshot.docs) {
          var recipeLabel = foodLogDoc['recipe']['label'];
          var dateTimestamp = foodLogDoc['date'];

          if (recipeLabel != null) {
            // print('   Log: $recipeLabel');
            var date = dateTimestamp.toDate();
            var formattedDate = DateFormat('d MMMM yyyy').format(date);
            // print('   Date: $formattedDate');
            if (recipeLogCounts.containsKey(recipeLabel)) {
              recipeLogCounts[recipeLabel] = recipeLogCounts[recipeLabel]! + 1;
            } else {
              recipeLogCounts[recipeLabel] = 1;
            }
          } else {
            // print('   Log: No recipe label found.');
          }
        }

        // Clicks
        var clicksCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .collection('clicks');

        var clicksSnapshot = await clicksCollection.get();
        for (var clickDoc in clicksSnapshot.docs) {
          var recipeName = clickDoc.id;
          var clickCount = clickDoc['clickCount'] as int? ?? 0;

          // print('   ClicksName: $recipeName');
          // print('   Count: $clickCount');

          // Add click count to the recipeClickCounts map
          if (recipeClickCounts.containsKey(recipeName)) {
            recipeClickCounts[recipeName] =
                recipeClickCounts[recipeName]! + clickCount;
          } else {
            recipeClickCounts[recipeName] = clickCount;
          }
        }

        // Favorites
        var favoritesCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .collection('favorites');

        var favoritesSnapshot = await favoritesCollection.get();
        for (var favoritesDoc in favoritesSnapshot.docs) {
          var favoriteName = favoritesDoc.id;
          // print('   Favorites: $favoriteName');

          // Add to the favorite count map
          if (recipeFavoriteCounts.containsKey(favoriteName)) {
            recipeFavoriteCounts[favoriteName] =
                recipeFavoriteCounts[favoriteName]! + 1;
          } else {
            recipeFavoriteCounts[favoriteName] = 1;
          }
        }
      }
      await FirebaseFirestore.instance
          .collection('recipe_stats')
          .doc('current_states')
          .set({
        'timestamp': FieldValue.serverTimestamp(),
        'clicks': recipeClickCounts,
        'favorites': recipeFavoriteCounts,
        'logs': recipeLogCounts,
      });

      print("✅ Recipe stats saved to Firebase.");
    } catch (e) {
      print('Error getting data: $e');
    }
  }

  // MARK: Widget Build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'GinRaiDee',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 5),
              child: Text(
                'Search',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Material(
                borderRadius: BorderRadius.circular(15),
                elevation: 3,
                shadowColor: Colors.black26,
                child: TextFormField(
                  controller: searchController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Color(0xFF1F5F5B), width: 1.5),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: IconButton(
                      icon: Icon(Icons.search, color: Colors.grey[700]),
                      splashRadius: 22,
                      onPressed: () {
                        filterRecipes(
                            searchController.text, selectedCuisineType);
                      },
                    ),
                    hintText: 'Search food...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    suffixIcon: IconButton(
                      onPressed: () async {
                        Map<String, dynamic>? result =
                            await showFilterSheet(context);
                        if (result != null) {
                          setState(() {
                            _selectedCalories = result['calories'];
                            _filterRecipesByCalories();
                            _filterRecipesByCategories();
                            _filterRecipesByIngredients();
                            _filterRecipesByAllergies();
                          });
                          print("Updated Calories: $_selectedCalories");
                        }
                      },
                      icon: Icon(Icons.tune, color: Color(0xFF1F5F5B)),
                      splashRadius: 22,
                    ),
                  ),
                  onFieldSubmitted: (query) {
                    filterRecipes(query, selectedCuisineType);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 5),
              child: Text(
                'Function List',
                style: TextStyleBold.boldTextStyle(),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FunctionCard(
                      imagePath: 'assets/images/calorieTracking.png',
                      functionName: 'Calorie Tracking',
                      destinationScreen: CalorieTrackingScreen(),
                    ),
                    FunctionCard(
                      imagePath: 'assets/images/calorieTracking.png',
                      functionName: 'Nutrition Tracking',
                      destinationScreen: NutritionScreen(),
                    ),
                    FunctionCard(
                      imagePath: 'assets/images/mealPlanning.png',
                      functionName: 'Meal Planning',
                      destinationScreen: MealPlanningScreen(),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Icons.tune,
                      Icons.fastfood,
                      Icons.category,
                      Icons.kitchen,
                      Icons.warning,
                    ].map((icon) {
                      return GestureDetector(
                        onTap: () async {
                          if (icon == Icons.tune) {
                            // Open filter modal
                            Map<String, dynamic>? result =
                                await showFilterSheet(context);
                            if (result != null) {
                              setState(() {
                                _selectedCalories = result['calories'];
                                _filterRecipesByCalories();
                                _filterRecipesByIngredients();
                                _filterRecipesByCategories();
                                _filterRecipesByAllergies();
                              });
                              print("Updated Calories: $_selectedCalories");
                            }
                          } else if (icon == Icons.fastfood) {
                            double? result = await showCalorieFilterSheet(
                                context, _selectedCalories ?? 100);
                            if (result != null) {
                              print("Updated Calories: $result");
                              setState(() {
                                _selectedCalories = result;
                                _filterRecipesByCalories();
                              });
                            }
                          } else if (icon == Icons.category) {
                            Set<String>? result = await showCategoryFilterSheet(
                                context, selectedCategories);
                            if (result != null) {
                              setState(() {
                                selectedCategories = result;
                                _filterRecipesByCategories(
                                    startFromAllRecipes: true);
                              });
                              print("Selected Categories: $selectedCategories");
                            }
                          } else if (icon == Icons.kitchen) {
                            Set<String>? result =
                                await showIngredientFilterSheet(
                                    context, selectedIngredients);
                            if (result != null) {
                              setState(() {
                                selectedIngredients = result;
                                _filterRecipesByIngredients(
                                    startFromAllRecipes: true);
                              });
                              print(
                                  "Selected Ingredients: $selectedIngredients");
                            }
                          } else if (icon == Icons.warning) {
                            Set<String>? result = await showAllergyFilterSheet(
                                context, selectedAllergies);
                            if (result != null) {
                              setState(() {
                                selectedAllergies = result;
                                _filterRecipesByAllergies(
                                    startFromAllRecipes: true);
                              });
                              print("Selected Allergies: $selectedAllergies");
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    icon,
                                    size: 30,
                                    color: Color(0xFF1F5F5B),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                // icon == Icons.tune
                                //     ? 'Edit'
                                // : icon == Icons.category
                                icon == Icons.category
                                    ? 'Category'
                                    : icon == Icons.kitchen
                                        ? 'Ingredients'
                                        : icon == Icons.warning
                                            ? 'Allergy'
                                            : 'Calories',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1F5F5B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     var user = _auth.currentUser;
            //     if (user != null) {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) =>
            //               RecommendationScreen(userId: user.uid),
            //         ),
            //       );
            //     } else {
            //       // Handle case where user is not logged in
            //       // For example, show a login prompt or message
            //       print('User is not logged in.');
            //     }
            //   },
            //   child: Text('to another'),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Recommended Menu🔥',
                style: TextStyleBold.boldTextStyle(),
              ),
            ),
            Column(
              children: [
                Column(
                  children: [
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        // : Container(),
                        : Center(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              width: MediaQuery.of(context).size.width * 0.93,
                              child: Container(
                                // decoration: BoxDecoration(
                                //   boxShadow: [
                                //     BoxShadow(
                                //       color: Colors.black.withOpacity(0.12),
                                //       blurRadius: 3,
                                //       offset: Offset(0, 4),
                                //     ),
                                //   ],
                                // ),
                                child: ListView.builder(
                                  itemCount: recommendedLabels.length,
                                  itemBuilder: (context, index) {
                                    String labelName = recommendedLabels[index];
                                    var recipe = allRecipes.firstWhere(
                                      (r) => r['label'] == labelName,
                                      orElse: () => <String, dynamic>{},
                                    );

                                    String imagePath =
                                        'assets/fetchMenu/${labelName.toLowerCase().replaceAll(' ', '_')}.jpg';

                                    return Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right:
                                                  40.0), // Leave space for icon
                                          child: ListTile(
                                            leading: Image.asset(
                                              imagePath,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object error,
                                                      StackTrace? stackTrace) {
                                                return Image.asset(
                                                  'assets/images/default.png',
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                            title: Text(labelName),
                                            subtitle: recipe.isNotEmpty
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .local_fire_department_outlined,
                                                              color:
                                                                  Colors.red),
                                                          Text(
                                                            "${formatNumber(recipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt())} ${recipe['totalNutrients']['ENERC_KCAL']['unit']}",
                                                          ),
                                                        ],
                                                      ),
                                                      Text(recipe['source']),
                                                    ],
                                                  )
                                                : Text("Details not found"),
                                            onTap: () {
                                              if (recipe.isNotEmpty) {
                                                logRecipeClick(recipe['label'],
                                                    recipe['source']);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        FoodDetailScreen(
                                                            recipe: recipe),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: IconButton(
                                            icon: Icon(
                                              favoriteRecipes[labelName] == true
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              size: 30,
                                              color:
                                                  favoriteRecipes[labelName] ==
                                                          true
                                                      ? Color.fromARGB(
                                                          255, 255, 191, 0)
                                                      : Colors.grey,
                                            ),
                                            onPressed: () {
                                              _toggleFavorite(
                                                  labelName, recipe);
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                    // After loading, the second ListView (filteredRecipes) goes below the first one
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.width * 0.93,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 3,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            itemCount: filteredRecipes.length,
                            itemBuilder: (context, index) {
                              var recipe = filteredRecipes[index];
                              String imagePath =
                                  '${'assets/fetchMenu/' + recipe['label']?.toLowerCase().replaceAll(' ', '_')}.jpg';

                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: ListTile(
                                      leading: Image.asset(
                                        imagePath,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context,
                                            Object error,
                                            StackTrace? stackTrace) {
                                          return Image.asset(
                                            'assets/images/default.png',
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                      title: Text(recipe['label']),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons
                                                    .local_fire_department_outlined,
                                                color: Colors.red,
                                              ),
                                              Text(
                                                "${formatNumber(recipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt())} ${recipe['totalNutrients']['ENERC_KCAL']['unit']}",
                                              ),
                                            ],
                                          ),
                                          Text(recipe['source']),
                                        ],
                                      ),
                                      onTap: () {
                                        logRecipeClick(
                                            recipe['label'], recipe['source']);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FoodDetailScreen(
                                                    recipe: recipe),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Favorite Icon on Top-Right
                                  Positioned(
                                    top: 5, // Adjust top position
                                    right: 5, // Adjust right position
                                    child: IconButton(
                                      icon: Icon(
                                        favoriteRecipes[recipe['label']] == true
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 30,
                                        color:
                                            favoriteRecipes[recipe['label']] ==
                                                    true
                                                ? Color.fromARGB(
                                                    255, 255, 191, 0)
                                                : Colors.grey,
                                      ),
                                      onPressed: () {
                                        _toggleFavorite(
                                            recipe['label'], recipe);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
      // MARK: bottomNavigationBar
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

// MARK: Function Card
class FunctionCard extends StatelessWidget {
  final String imagePath;
  final String functionName;
  final Widget destinationScreen;

  const FunctionCard(
      {super.key,
      required this.imagePath,
      required this.functionName,
      required this.destinationScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destinationScreen),
          );
        },
        child: Container(
          width: MediaQuery.sizeOf(context).width / 3.5,
          height: MediaQuery.sizeOf(context).width / 3,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(alignment: Alignment.bottomCenter, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    width: double.infinity,
                    child: Text(
                      functionName,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextStyleBold {
  static TextStyle boldTextStyle() {
    return TextStyle(fontWeight: FontWeight.w800, fontSize: 16);
  }
}

// MARK: ! Rec System
void fetchAndShowRecommendations(String userId) async {
  final recommendations = await getRecommendedRecipes(userId);
  print("Top recommendations: $recommendations");
}

Future<Map<String, int>> fetchUserData(String userId) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final clickSnapshot = await userRef.collection('clickHistory').get();
  final favoriteSnapshot = await userRef.collection('favoriteFoods').get();
  final foodLogSnapshot = await userRef.collection('foodLog').get();

  final Map<String, int> recipeData = {};

  for (var doc in clickSnapshot.docs) {
    recipeData[doc['label']] = (recipeData[doc['label']] ?? 0) + 1;
  }
  for (var doc in favoriteSnapshot.docs) {
    recipeData[doc['label']] = (recipeData[doc['label']] ?? 0) + 2;
  }
  for (var doc in foodLogSnapshot.docs) {
    recipeData[doc['label']] = (recipeData[doc['label']] ?? 0) + 3;
  }

  return recipeData;
}

Future<Map<String, Map<String, int>>> fetchAllUserData() async {
  final usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();
  final Map<String, Map<String, int>> allUserData = {};

  for (var userDoc in usersSnapshot.docs) {
    final userId = userDoc.id;
    final data = await fetchUserData(userId);
    allUserData[userId] = data;
  }

  return allUserData;
}

double cosineSimilarity(Map<String, int> a, Map<String, int> b) {
  final commonKeys = a.keys.toSet().intersection(b.keys.toSet());

  if (commonKeys.isEmpty) return 0.0;

  final dotProduct =
      commonKeys.fold<double>(0.0, (sum, key) => sum + (a[key]! * b[key]!));
  final magnitudeA =
      sqrt(a.values.fold<double>(0.0, (sum, value) => sum + pow(value, 2)));
  final magnitudeB =
      sqrt(b.values.fold<double>(0.0, (sum, value) => sum + pow(value, 2)));

  if (magnitudeA == 0 || magnitudeB == 0) return 0.0;

  return dotProduct / (magnitudeA * magnitudeB);
}

// MARK: load Recipe
Future<Map<String, dynamic>> loadRecipeData() async {
  final jsonData =
      await rootBundle.loadString('assets/fetchMenu/recipe_output.json');
  final Map<String, dynamic> jsonMap = json.decode(jsonData);
  final List<dynamic> hits = jsonMap['hits'];

  final Map<String, dynamic> recipeMap = {};
  for (var hit in hits) {
    final recipe = hit['recipe'];
    recipeMap[recipe['label']] = recipe;
  }

  print('Total recipes: ${hits.length}');

  return recipeMap;
}

// MARK: Get Rec.
Future<List<String>> getRecommendedRecipes(String currentUserId) async {
  // Fetch aggregated stats from Firestore
  final statsDoc = await FirebaseFirestore.instance
      .collection('recipe_stats')
      .doc('current_states')
      .get();

  if (!statsDoc.exists) {
    print('Stats document not found!');
    return [];
  }

  final Map<String, dynamic> clicks =
      Map<String, dynamic>.from(statsDoc['clicks'] ?? {});
  final Map<String, dynamic> favorites =
      Map<String, dynamic>.from(statsDoc['favorites'] ?? {});
  final Map<String, dynamic> logs =
      Map<String, dynamic>.from(statsDoc['logs'] ?? {});

  // Combine all counts into a unified score map
  final Map<String, double> recipeScores = {};

  clicks.forEach((recipe, count) {
    recipeScores[recipe] = (recipeScores[recipe] ?? 0) + (count as int) * 1.0;
  });
  favorites.forEach((recipe, count) {
    recipeScores[recipe] = (recipeScores[recipe] ?? 0) + (count as int) * 2.5;
  });
  logs.forEach((recipe, count) {
    recipeScores[recipe] = (recipeScores[recipe] ?? 0) + (count as int) * 3.0;
  });

  // Load full recipe data
  final recipeMap = await loadRecipeData();

  // Get current user's food preferences
  final currentUserDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .get();
  final userPrefs = List<String>.from(currentUserDoc['foodIngredient'] ?? []);

  // Boost score based on preferences
  recipeMap.forEach((label, recipe) {
    final ingredients = List<String>.from(recipe['ingredientLines'] ?? []);
    final hasPreferred = ingredients.any((ingredient) => userPrefs
        .any((pref) => ingredient.toLowerCase().contains(pref.toLowerCase())));

    if (hasPreferred) {
      recipeScores[label] = (recipeScores[label] ?? 0) + 10.0;
    }
  });

  // Sort by score
  final sorted = recipeScores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // Debug print
  for (var entry in sorted) {
    print('Recipe: ${entry.key}, Score: ${entry.value}');
  }

  return sorted.map((entry) => entry.key).toList();
}
