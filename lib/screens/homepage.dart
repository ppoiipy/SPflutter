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

// import 'package:';

// import 'package:flutter_application_1/api/fetch_food_api.dart';
// import 'fetch_food_data.dart';

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

  // Timer? _recipeStatsTimer;

  List<dynamic> recipes = [];
  List<dynamic> filteredRecipes = [];

  Map<String, dynamic>? selectedFilters;
  double? _selectedCalories;
  Set<String> selectedCategories = {};
  Set<String> selectedIngredients = {};
  Set<String> selectedAllergies = {};

  List<Map<String, dynamic>> allRecipes = [];

  String selectedCuisineType = "All";

  late Future<void> _filterDataFuture;

  // MARK: initState
  @override
  void initState() {
    super.initState();
    loadJsonData();
    _loadUserFilters();
    printAllUserRecipeData();
    loadRecommendations();
    loadRecipeData();
    _filterDataFuture = _loadDataAndApplyFilters();
  }

  Future<void> _loadDataAndApplyFilters() async {
    // Ensure that data is loaded first
    // await loadJsonData();
    _loadUserFilters();
    loadRecommendations();
    loadRecipeData();

    // After all data is loaded, apply filters based on user data
    _applyFiltersFromUserData();

    Timer.periodic(Duration(seconds: 5), (timer) async {
      if (_searchQuery == null || _searchQuery.isEmpty) {
        // applySearchFilter();
        _applyFiltersFromUserData(); // Only apply when not searching
        loadRecommendations();
      }
    });
  }

  @override
  void dispose() {
    // _recipeStatsTimer?.cancel();
    super.dispose();
  }

  // Future<void> loadRecommendations() async {
  //   User? user = _auth.currentUser; // Get current user
  //   if (user != null) {
  //     final results =
  //         // await getCollaborativeRecommendations(user.uid);
  //         await getRecommendedRecipes(user.uid);
  //     setState(() {
  //       recommendedLabels = results;
  //       isLoading = false;
  //     });
  //   } else {
  //     print('User not logged in!');
  //   }
  // }

  // MARK: load ver 1
  Future<void> loadRecommendations() async {
    User? user = _auth.currentUser; // Get current user
    if (user != null) {
      final results = await getCollaborativeRecommendations(user.uid);
      await getRecommendedRecipes(user.uid);
      setState(() {
        recommendedLabels = results;
        isLoading = false;
      });
    } else {
      print('User not logged in!');
    }
  }

  // MARK: load ver 2
  // Future<void> loadRecommendations() async {
  //   User? user = _auth.currentUser; // Get current user
  //   if (user != null) {
  //     // Get raw recommendations
  //     final results = await getRecommendedRecipes(
  //         user.uid); // Or getCollaborativeRecommendations

  //     // Apply user filters to recommendations
  //     final filteredResults = await _applyFiltersFromUserData(results);

  //     setState(() {
  //       recommendedLabels = filteredResults;
  //       isLoading = false;
  //     });
  //   } else {
  //     print('User not logged in!');
  //   }
  // }

  String formatNumber(int number) {
    return NumberFormat("#,###").format(number);
  }

  Future<void> _loadUserFilters() async {
    var user = _auth.currentUser;
    if (user == null) return;

    var userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists && mounted) {
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
      // filteredRecipes = List.from(recipes);
      allRecipes = List.from(recipes);
    });
  }

  // Call Filter Sheet Function
  // void openFilterSheet() async {
  //   // Show the filter sheet and wait for the selected filters
  //   final filters = await showFilterSheet(context);

  //   if (filters != null) {
  //     // If filters are selected, apply them
  //     setState(() {
  //       selectedFilters = filters; // Store the selected filters
  //       _selectedCalories = filters['calories']; // Get calories filter
  //     });

  //     // Apply the filters on the recipes based on the selected filters
  //     _filterRecipesByCalories();
  //     _filterRecipesByIngredients();

  //     print("Selected Filters: $selectedFilters");
  //   }
  // }

  // Future<Map<String, dynamic>?> showFilterSheet(context) {
  //   return showModalBottomSheet<Map<String, dynamic>>(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     isScrollControlled: true,
  //     builder: (context) {
  //       return FilterSheet(
  //         initialCalories: _selectedCalories, // Pass the current value
  //         onFiltersApplied: (filters) {
  //           Navigator.pop(context, filters);
  //         },
  //       );
  //     },
  //   );
  // }

  void openFilterSheet() async {
    // Show the filter sheet and wait for the selected filters
    final filters = await showFilterSheet(context as BuildContext);

    if (filters != null) {
      setState(() {
        selectedFilters = filters; // Store the selected filters
        _selectedCalories = filters['calories']; // Get calories filter
      });

      // Apply the filters on the recipes based on the selected filters
      await _applyFilters();
    }
  }

  Future<Map<String, dynamic>?> showFilterSheet(BuildContext context) {
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

  Future<void> _applyFilters() async {
    // Step 1: Apply Calorie Filter
    // _filterRecipesByCalories(startFromAllRecipes: true);

    // Step 2: Apply Category Filter
    _filterRecipesByCategories(startFromAllRecipes: false);

    // Step 3: Apply Ingredient Filter
    _filterRecipesByIngredients(startFromAllRecipes: false);

    // Step 4: Apply Allergy Filter
    _filterRecipesByAllergies(startFromAllRecipes: false);
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
        if (_selectedCalories == null) return true; // No calorie filter

        try {
          final nutrients = recipe['totalNutrients'];
          if (nutrients == null || nutrients['ENERC_KCAL'] == null)
            return false;

          final calorie =
              (nutrients['ENERC_KCAL']['quantity'] as num).toDouble();
          return calorie <= _selectedCalories!;
        } catch (e) {
          print("Error parsing calories: $e");
          return false;
        }
      }).toList();
    });

    print(
        "Filtered Recipes by Calories: ${filteredRecipes.map((r) => r['label']).toList()}");
  }

  // void _filterRecipesByCalories({bool startFromAllRecipes = false}) {
  //   setState(() {
  //     filteredRecipes =
  //         (startFromAllRecipes ? allRecipes : filteredRecipes).where((recipe) {
  //       if (_selectedCalories == null) {
  //         return true; // No calorie filter applied
  //       }

  //       // Ensure the recipe has a calorie value and apply the filter
  //       var recipeCalories = recipe['calories'];
  //       if (recipeCalories != null) {
  //         return recipeCalories <= _selectedCalories;
  //       }

  //       return false;
  //     }).toList();
  //   });

  //   print(
  //       "Filtered Recipes by Calories: ${filteredRecipes.map((r) => r['label']).toList()}");
  // }

  // MARK: Category
  // Future<Set<String>?> showCategoryFilterSheet(
  //     BuildContext context, Set<String> selectedCategories) async {
  //   var user = _auth.currentUser;
  //   if (user == null) return null;

  //   // Fetch categories from Firebase
  //   var userDoc = await _firestore.collection('users').doc(user.uid).get();
  //   var data = userDoc.data();

  //   Set<String> loadedCategories = {};
  //   if (data != null && data['foodCategory'] != null) {
  //     loadedCategories = Set<String>.from(data['foodCategory']);
  //   }

  //   return showModalBottomSheet<Set<String>>(
  //     context: context,
  //     isScrollControlled: false, // Prevents full-screen height
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Container(
  //         width: MediaQuery.of(context).size.width,
  //         height: MediaQuery.of(context).size.height * 0.5,
  //         padding: const EdgeInsets.all(16.0),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         child: CategoryFilter(
  //           selectedCategories: loadedCategories,
  //           onSelectionChanged: (selected) {
  //             print("Ingredient Selection Updated: $selected");
  //             // Navigator.pop(context, selected);
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<Set<String>?> showCategoryFilterSheet(
      BuildContext context, Set<String> selectedCategories) async {
    var user = _auth.currentUser;
    if (user == null) return null;

    var userDoc = await _firestore.collection('users').doc(user.uid).get();
    var data = userDoc.data();

    Set<String> loadedCategories = {};
    if (data != null && data['foodCategory'] != null) {
      loadedCategories = Set<String>.from(data['foodCategory']);
    }

    return await showModalBottomSheet<Set<String>>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Padding(padding: EdgeInsets.only(top: 200));
        return CategoryFilter(
          selectedCategories: loadedCategories,
          onSelectionChanged: (selected) {
            // Navigator.pop(context, selected);
          },
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
        "Filtered Recipes by Cuisines: ${filteredRecipes.map((r) => r['label']).toList()}");
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
            print("Ingredient Selection Updated: $selected");
            // Navigator.pop(context, selected);
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

  void applyAllFilters(
      String query, String cuisineType, List<String> recommendedLabels) {
    List<dynamic> filtered = allRecipes;

    // Category filter
    if (selectedCategories != null && selectedCategories.isNotEmpty) {
      filtered = filtered
          .where((recipe) => selectedCategories.contains(recipe['category']))
          .toList();
    }

    // Ingredient filter
    if (selectedIngredients.isNotEmpty) {
      filtered = filtered.where((recipe) {
        return selectedIngredients
            .every((ingredient) => recipe['ingredients'].contains(ingredient));
      }).toList();
    }

    // Calorie filter
    if (_selectedCalories != null) {
      filtered = filtered
          .where((recipe) =>
              recipe['calories'] != null &&
              recipe['calories'] <= _selectedCalories)
          .toList();
    }

    // Allergy filter
    if (selectedAllergies.isNotEmpty) {
      filtered = filtered.where((recipe) {
        return !selectedAllergies
            .any((allergy) => recipe['ingredients'].contains(allergy));
      }).toList();
    }

    // Search + Cuisine Type filter
    if (query.isNotEmpty || cuisineType != "All") {
      filtered = filtered.where((recipe) {
        final label = recipe['label']?.toString().toLowerCase() ?? '';
        final cuisine = recipe['cuisineType']?.toString().toLowerCase() ?? '';
        final searchMatch = label.contains(query.toLowerCase());
        final cuisineMatch = cuisineType == "All" ||
            cuisine.contains(cuisineType.toLowerCase()) ||
            label.contains(cuisineType.toLowerCase());
        return searchMatch && cuisineMatch;
      }).toList();
    }

    // Prioritize recommended labels
    if (recommendedLabels.isNotEmpty) {
      filtered.sort((a, b) {
        final aLabel = a['label']?.toString() ?? '';
        final bLabel = b['label']?.toString() ?? '';
        final aIndex = recommendedLabels.indexOf(aLabel);
        final bIndex = recommendedLabels.indexOf(bLabel);

        if (aIndex == -1 && bIndex == -1) return 0;
        if (aIndex == -1) return 1;
        if (bIndex == -1) return -1;
        return aIndex.compareTo(bIndex);
      });
    }

    setState(() {
      filteredRecipes = filtered;
    });
  }

  // MARK: NEW

  // MARK: Worked
  // List<dynamic> allRecipes = []; // Full recipe list
  // List<dynamic> filteredRecipes = []; // Recipes after applying the filter

  // Selected filters
  String? _selectedCuisine;
  String? _selectedCategory;
  // double _selectedCalories = 2000; // Default max calories
  List<String> recommendedRecipes = [];

  // MARK: apply ver 1.
  Future<void> _applyFiltersFromUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final userData = doc.data();
    if (userData == null) return;

    final dynamic calorieRaw = userData['calories'];
    final dynamic allergyRaw = userData['foodAllergy'];
    final dynamic foodIngredientRaw = userData['foodIngredient'];

    final double? userCalorie = calorieRaw is num
        ? calorieRaw.toDouble()
        : double.tryParse(calorieRaw.toString());

    final Set<String> userAllergy = {
      if (allergyRaw is List)
        ...allergyRaw.map((e) => e.toString().toLowerCase()),
      if (allergyRaw is String) allergyRaw.toLowerCase(),
    };

    final Set<String> userFoodIngredients = {
      if (foodIngredientRaw is List)
        ...foodIngredientRaw.map((e) => e.toString().toLowerCase()),
      if (foodIngredientRaw is String) foodIngredientRaw.toLowerCase(),
    };

    setState(() {
      List<dynamic> currentList = List.from(allRecipes);

      // Apply the filters as per user preferences
      if (userCalorie != null) {
        currentList = currentList.where((recipe) {
          final nutrients = recipe['totalNutrients'];
          final energy = nutrients?['ENERC_KCAL'];
          final value = energy?['quantity']?.toDouble();
          return value != null && value <= userCalorie;
        }).toList();
      }

      if (userAllergy.isNotEmpty) {
        currentList = currentList.where((recipe) {
          final recipeAllergy = recipe['cautions'];
          final Set<String> recipeAllergySet = {
            if (recipeAllergy is List)
              ...recipeAllergy.map((a) => a.toString().toLowerCase()),
            if (recipeAllergy is String) recipeAllergy.toLowerCase(),
          };

          final hasConflict =
              userAllergy.intersection(recipeAllergySet).isNotEmpty;
          return !hasConflict;
        }).toList();
      }

      if (userFoodIngredients.isNotEmpty) {
        currentList = currentList.where((recipe) {
          final ingredientLines = recipe['ingredientLines'];
          if (ingredientLines is List) {
            return ingredientLines.any((ingredient) {
              return userFoodIngredients.any(
                (userIngredient) => ingredient
                    .toString()
                    .toLowerCase()
                    .contains(userIngredient),
              );
            });
          }
          return false;
        }).toList();
      }

      if (_selectedCuisine != null) {
        currentList = currentList.where((recipe) {
          final cuisineType = recipe['cuisineType'];
          return cuisineType
              .toString()
              .toLowerCase()
              .contains(_selectedCuisine!.toLowerCase());
        }).toList();
      }

      if (_selectedCategory != null) {
        currentList = currentList.where((recipe) {
          final categoryType = recipe['foodCategory'];
          return categoryType != null &&
              categoryType
                  .toString()
                  .toLowerCase()
                  .contains(_selectedCategory!.toLowerCase());
        }).toList();
      }

      currentList = currentList.where((recipe) {
        final ingredientLines = recipe['ingredientLines'];
        return ingredientLines is List && ingredientLines.isNotEmpty;
      }).toList();

      // Add recommended labels to the filtered list if available
      if (recommendedLabels.isNotEmpty) {
        // Combine filtered recipes with recommended recipes (avoiding duplicates)
        currentList.addAll(allRecipes.where((recipe) {
          final label = recipe['label']?.toString().toLowerCase() ?? '';
          return recommendedLabels.any(
            (recommendedLabel) =>
                label.contains(recommendedLabel.toLowerCase()),
          );
        }));
      }

      filteredRecipes = currentList;

      // Now get the recommendations based on the filtered recipes
      // _fetchRecommendations(user.uid);
    });
  }

  void applySearchFilter() async {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        filteredRecipes = filteredRecipes.where((recipe) {
          final label = recipe['label']?.toString().toLowerCase() ?? '';
          return label.contains(_searchQuery);
        }).toList();
      }
    });
  }

  String _searchQuery = '';

  // MARK: with rec system
  // Future<List<String>> _applyFiltersFromUserData(
  //     List<dynamic> allRecipes) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return [];

  //   final doc = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(user.uid)
  //       .get();

  //   if (!doc.exists) return [];

  //   final userData = doc.data();
  //   if (userData == null) return [];

  //   final dynamic calorieRaw = userData['calories'];
  //   final dynamic allergyRaw = userData['foodAllergy'];
  //   final dynamic foodIngredientRaw = userData['foodIngredient'];

  //   final double? userCalorie = calorieRaw is num
  //       ? calorieRaw.toDouble()
  //       : double.tryParse(calorieRaw.toString());

  //   final Set<String> userAllergy = {
  //     if (allergyRaw is List)
  //       ...allergyRaw.map((e) => e.toString().toLowerCase()),
  //     if (allergyRaw is String) allergyRaw.toLowerCase(),
  //   };

  //   final Set<String> userFoodIngredients = {
  //     if (foodIngredientRaw is List)
  //       ...foodIngredientRaw.map((e) => e.toString().toLowerCase()),
  //     if (foodIngredientRaw is String) foodIngredientRaw.toLowerCase(),
  //   };

  //   // Apply filters
  //   List<String> currentList = [];

  //   // Filter by calories, allergies, ingredients, etc.
  //   List<dynamic> filteredList = List.from(allRecipes);

  //   // Apply various filters (as before)...
  //   // After filtering, you can extract the recipe names or relevant string data:

  //   currentList = filteredList.map<String>((recipe) {
  //     return recipe['label'] ??
  //         ''; // assuming 'label' is the string you're filtering
  //   }).toList();

  //   return currentList;
  // }

  // // Fetch recommendations based on collaborative filtering
  // Future<void> _fetchRecommendations(String userId) async {
  //   final recommendations = await getCollaborativeRecommendations(userId);

  //   setState(() {
  //     recommendedRecipes = recommendations;
  //   });
  // }

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
      body: FutureBuilder(
          future: _filterDataFuture,
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 5),
                    child: Text(
                      'Search',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                            borderSide: BorderSide(
                                color: Color(0xFF1F5F5B), width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search, color: Colors.grey[700]),
                            splashRadius: 22,
                            // onPressed: () {
                            //   filterRecipes(
                            //       searchController.text, selectedCuisineType);
                            //   applyAllFilters(searchController.text,
                            //       selectedCuisineType, recommendedLabels);
                            // },
                            onPressed: () {
                              // setState(() {
                              //   _searchQuery =
                              //       searchController.text.trim().toLowerCase();
                              // });
                              // applyAllFilters(_searchQuery, selectedCuisineType,
                              //     recommendedLabels);
                              applySearchFilter();
                            },
                          ),
                          hintText: 'Search food...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              Map<String, dynamic>? result =
                                  await showFilterSheet(context);
                              print(
                                  "FilterSheet returned: $result"); // 👈 Check this
                              if (result != null) {
                                setState(() {
                                  _selectedCalories = result['calories'];
                                  selectedIngredients = result['ingredients'];
                                  selectedAllergies = result['allergies'];
                                  selectedCategories =
                                      result['category']; // Error likely here
                                });
                                applyAllFilters(searchController.text,
                                    selectedCuisineType, recommendedLabels);
                                User? user =
                                    _auth.currentUser; // Get current user
                                if (user != null) {
                                  final results =
                                      await getCollaborativeRecommendations(
                                          user.uid);
                                  await getRecommendedRecipes(user.uid);
                                  setState(() {
                                    recommendedLabels = results;
                                    isLoading = false;
                                  });
                                } else {
                                  print('User not logged in!');
                                }
                              }
                              setState(() async {
                                User? user =
                                    _auth.currentUser; // Get current user
                                if (user != null) {
                                  final results =
                                      await getCollaborativeRecommendations(
                                          user.uid);
                                  await getRecommendedRecipes(user.uid);
                                  setState(() {
                                    recommendedLabels = results;
                                    isLoading = false;
                                  });
                                } else {
                                  print('User not logged in!');
                                }
                              });
                            },
                            icon: Icon(Icons.tune, color: Color(0xFF1F5F5B)),
                            splashRadius: 22,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            // _searchQuery = value.trim().toLowerCase();
                            applyAllFilters(_searchQuery, selectedCuisineType,
                                recommendedLabels);
                          });
                          // applyAllFilters(_searchQuery, selectedCuisineType,
                          //     recommendedLabels);
                          // applySearchFilter();
                        },
                        onFieldSubmitted: (query) {
                          setState(() {
                            _searchQuery = query.trim().toLowerCase();
                          });
                          applyAllFilters(_searchQuery, selectedCuisineType,
                              recommendedLabels);
                        },
                      ),
                    ),
                  ),
                  // MARK: To Delete
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Recommended Recipes',
                  //       style: TextStyle(
                  //           fontSize: 18, fontWeight: FontWeight.bold),
                  //     ),
                  //     IconButton(
                  //       icon: Icon(Icons.filter_alt, color: Colors.deepOrange),
                  //       tooltip: "Filter from preferences",
                  //       onPressed: () async {
                  //         // Get the current user
                  //         final user = FirebaseAuth.instance.currentUser;
                  //         if (user != null) {
                  //           // Assuming getRecommendedRecipes takes the user UID as an argument
                  //           List<dynamic> allRecipes =
                  //               await getRecommendedRecipes(user.uid);
                  //           // Apply filters based on user preferences
                  //           // MARK: apply ver 1
                  //           _applyFiltersFromUserData();
                  //           // MARK: apply ver 2
                  //           // await _applyFiltersFromUserData(allRecipes);
                  //         } else {
                  //           // Handle case where the user is not logged in
                  //           print("No user logged in.");
                  //         }
                  //       },
                  //     ),
                  //   ],
                  // ),

                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 5),
                    child: Text(
                      'Function List',
                      style: TextStyleBold.boldTextStyle(),
                    ),
                  ),
                  SizedBox(height: 5),
                  // Card Lists
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
                  // Filter Lists
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
                                    print(
                                        "Updated Calories: $_selectedCalories");
                                    setState(() {
                                      loadRecommendations();
                                    });
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
                                  Set<String>? result =
                                      await showCategoryFilterSheet(
                                          context, selectedCategories);
                                  if (result != null) {
                                    setState(() {
                                      selectedCategories = result;
                                      _filterRecipesByCategories(
                                          startFromAllRecipes: true);
                                    });
                                    print(
                                        "Selected Cuisines: $selectedCategories");
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
                                  Set<String>? result =
                                      await showAllergyFilterSheet(
                                          context, selectedAllergies);
                                  if (result != null) {
                                    setState(() {
                                      selectedAllergies = result;
                                      _filterRecipesByAllergies(
                                          startFromAllRecipes: true);
                                    });
                                    print(
                                        "Selected Allergies: $selectedAllergies");
                                  }
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 7),
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
                                          ? 'Cuisines'
                                          : icon == Icons.kitchen
                                              ? 'Ingredients'
                                              : icon == Icons.warning
                                                  ? 'Allergies'
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
                  // Recommendation Lists
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
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
                                  // child: SizedBox(
                                  //   height: MediaQuery.of(context).size.height *
                                  //       0.5,
                                  //   width: MediaQuery.of(context).size.width *
                                  //       0.93,
                                  //   child: Container(
                                  //     decoration: BoxDecoration(
                                  //       boxShadow: [
                                  //         BoxShadow(
                                  //           color:
                                  //               Colors.black.withOpacity(0.12),
                                  //           blurRadius: 3,
                                  //           offset: Offset(0, 4),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     child: ListView.builder(
                                  //       itemCount: recommendedLabels.length,
                                  //       itemBuilder: (context, index) {
                                  //         String labelName =
                                  //             recommendedLabels[index];
                                  //         var recipe = allRecipes.firstWhere(
                                  //           (r) => r['label'] == labelName,
                                  //           orElse: () => <String, dynamic>{},
                                  //         );

                                  //         String imagePath =
                                  //             'assets/fetchMenu/${labelName.toLowerCase().replaceAll(' ', '_')}.jpg';

                                  //         return Stack(
                                  //           children: [
                                  //             Padding(
                                  //               padding: const EdgeInsets.only(
                                  //                   right:
                                  //                       40.0), // Leave space for icon
                                  //               child: ListTile(
                                  //                 leading: Image.asset(
                                  //                   imagePath,
                                  //                   width: 50,
                                  //                   height: 50,
                                  //                   fit: BoxFit.cover,
                                  //                   errorBuilder:
                                  //                       (BuildContext context,
                                  //                           Object error,
                                  //                           StackTrace?
                                  //                               stackTrace) {
                                  //                     return Image.asset(
                                  //                       'assets/images/default.png',
                                  //                       width: 50,
                                  //                       height: 50,
                                  //                       fit: BoxFit.cover,
                                  //                     );
                                  //                   },
                                  //                 ),
                                  //                 title: Text(labelName),
                                  //                 subtitle: recipe.isNotEmpty
                                  //                     ? Column(
                                  //                         crossAxisAlignment:
                                  //                             CrossAxisAlignment
                                  //                                 .start,
                                  //                         children: [
                                  //                           Row(
                                  //                             children: [
                                  //                               Icon(
                                  //                                   Icons
                                  //                                       .local_fire_department_outlined,
                                  //                                   color: Colors
                                  //                                       .red),
                                  //                               Text(
                                  //                                 "${formatNumber(recipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt())} ${recipe['totalNutrients']['ENERC_KCAL']['unit']}",
                                  //                               ),
                                  //                             ],
                                  //                           ),
                                  //                           Text(recipe[
                                  //                               'source']),
                                  //                         ],
                                  //                       )
                                  //                     : Text(
                                  //                         "Details not found"),
                                  //                 onTap: () {
                                  //                   if (recipe.isNotEmpty) {
                                  //                     logRecipeClick(
                                  //                         recipe['label'],
                                  //                         recipe['source']);
                                  //                     Navigator.push(
                                  //                       context,
                                  //                       MaterialPageRoute(
                                  //                         builder: (context) =>
                                  //                             FoodDetailScreen(
                                  //                                 recipe:
                                  //                                     recipe),
                                  //                       ),
                                  //                     );
                                  //                   }
                                  //                 },
                                  //               ),
                                  //             ),
                                  //             Positioned(
                                  //               top: 10,
                                  //               right: 10,
                                  //               child: IconButton(
                                  //                 icon: Icon(
                                  //                   favoriteRecipes[
                                  //                               labelName] ==
                                  //                           true
                                  //                       ? Icons.star
                                  //                       : Icons.star_border,
                                  //                   size: 30,
                                  //                   color:
                                  //                       favoriteRecipes[
                                  //                                   labelName] ==
                                  //                               true
                                  //                           ? Color.fromARGB(
                                  //                               255,
                                  //                               255,
                                  //                               191,
                                  //                               0)
                                  //                           : Colors.grey,
                                  //                 ),
                                  //                 onPressed: () {
                                  //                   _toggleFavorite(
                                  //                       labelName, recipe);
                                  //                 },
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         );
                                  //       },
                                  //     ),
                                  //   ),
                                  // ),
                                  ),

                          // After loading, the second ListView (filteredRecipes) goes below the first one
                          Center(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              width: MediaQuery.of(context).size.width * 0.93,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    // BoxShadow(
                                    //   color: Colors.black.withOpacity(0.12),
                                    //   blurRadius: 3,
                                    //   offset: Offset(0, 4),
                                    // ),
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
                                          padding:
                                              const EdgeInsets.only(right: 20),
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
                                            },
                                          ),
                                        ),
                                        // Favorite Icon on Top-Right
                                        Positioned(
                                          top: 5, // Adjust top position
                                          right: 5, // Adjust right position
                                          child: IconButton(
                                            icon: Icon(
                                              favoriteRecipes[
                                                          recipe['label']] ==
                                                      true
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              size: 30,
                                              color: favoriteRecipes[
                                                          recipe['label']] ==
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
            );
          }),
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
// void fetchAndShowRecommendations(String userId) async {
//   final recommendations = await getRecommendedRecipes(userId);
//   print("Top recommendations: $recommendations");
// }

Future<Map<String, int>> fetchUserData(String userId) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final clickSnapshot = await userRef.collection('clickHistory').get();
  final favoriteSnapshot = await userRef.collection('favoriteFoods').get();
  final foodLogSnapshot = await userRef.collection('foodLog').get();

  final Map<String, int> recipeData = {};

  for (var doc in clickSnapshot.docs) {
    // print('click label: ${doc.data()}');
    recipeData[doc['label']] = (recipeData[doc['label']] ?? 0) + 1;
  }

  for (var doc in favoriteSnapshot.docs) {
    // print('favorite label: ${doc.data()}');
    recipeData[doc['label']] = (recipeData[doc['label']] ?? 0) + 2;
  }

  for (var doc in foodLogSnapshot.docs) {
    // print('food log label: ${doc.data()}');
    recipeData[doc['label']] = (recipeData[doc['label']] ?? 0) + 3;
  }

  // print('Recipe data for $userId: $recipeData');
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
  final allKeys = <String>{...a.keys, ...b.keys};
  final aVector = allKeys.map((k) => a[k] ?? 0).toList();
  final bVector = allKeys.map((k) => b[k] ?? 0).toList();

  // print("Comparing vectors:");
  // print("A: $aVector");
  // print("B: $bVector");

  if (aVector.every((element) => element == 0) ||
      bVector.every((element) => element == 0)) {
    return 0.0; // No similarity if either vector is all zeros
  }

  final dotProduct =
      List.generate(aVector.length, (i) => aVector[i] * bVector[i])
          .reduce((a, b) => a + b);

  final aMagnitude = sqrt(aVector.map((x) => x * x).reduce((a, b) => a + b));
  final bMagnitude = sqrt(bVector.map((x) => x * x).reduce((a, b) => a + b));

  if (aMagnitude == 0 || bMagnitude == 0) return 0.0;

  return dotProduct / (aMagnitude * bMagnitude);
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

  print('Total menus: ${hits.length}');

  return recipeMap;
}

List filterRecipes({
  required Map<String, dynamic> recipeMap,
  required double minCalorie,
  required double maxCalorie,
  required List<String> categories,
  required List<String> requiredIngredients,
  required List<String> allergies,
  String query = '',
}) {
  return recipeMap.entries
      .where((entry) {
        final recipe = entry.value;
        final label = recipe['label'].toString().toLowerCase();
        final calories = (recipe['calories'] as num).toDouble();
        final recipeCategory = recipe['category']?.toString() ?? '';
        final ingredientLines =
            List<String>.from(recipe['ingredientLines'] ?? []);

        // Filter by calorie
        if (calories < minCalorie || calories > maxCalorie) return false;

        // Filter by category
        if (categories.isNotEmpty &&
            !categories.any((cat) =>
                recipeCategory.toLowerCase().contains(cat.toLowerCase()))) {
          return false;
        }

        // Filter by must-have ingredients
        if (requiredIngredients.isNotEmpty &&
            !requiredIngredients.every((ing) => ingredientLines.any(
                (line) => line.toLowerCase().contains(ing.toLowerCase())))) {
          return false;
        }

        // Filter by allergies
        if (allergies.isNotEmpty &&
            ingredientLines.any((line) => allergies.any((allergy) =>
                line.toLowerCase().contains(allergy.toLowerCase())))) {
          return false;
        }

        // Filter by search query in label
        if (query.isNotEmpty && !label.contains(query.toLowerCase())) {
          return false;
        }

        return true;
      })
      .map((entry) => entry.value)
      .toList();
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

  final currentUserData = await fetchUserData(currentUserId);
  final allUserData = await fetchAllUserData();

  final Map<String, double> similarityScores = {};

  allUserData.forEach((otherUserId, data) {
    if (otherUserId != currentUserId) {
      similarityScores[otherUserId] = cosineSimilarity(currentUserData, data);
    }
  });

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
    // print('Recipe: ${entry.key}, Score: ${entry.value}');
  }

  return sorted.map((entry) => entry.key).toList();
}

Future<List<String>> getCollaborativeRecommendations(
    String currentUserId) async {
  final currentUserData = await fetchUserData(currentUserId);
  final allUserData = await fetchAllUserData();

  final Map<String, double> similarityScores = {};

  allUserData.forEach((otherUserId, data) {
    if (otherUserId != currentUserId) {
      similarityScores[otherUserId] = cosineSimilarity(currentUserData, data);
    }
  });

  final topUsers = similarityScores.entries.where((e) => e.value > 0).toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // print("Similarity scores: $similarityScores");
  // print("Top similar users: $topUsers");

  final Map<String, double> recommendedRecipes = {};

  for (var entry in topUsers.take(5)) {
    final otherUserId = entry.key;
    final similarity = entry.value;
    final otherUserData = allUserData[otherUserId]!;

    otherUserData.forEach((recipe, count) {
      recommendedRecipes[recipe] =
          (recommendedRecipes[recipe] ?? 0) + count * similarity;
    });
  }
  print("Weighted recipe scores: $recommendedRecipes");

  final sorted = recommendedRecipes.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  print("Sorted recommendations: $sorted");

  final recommendedLabels = sorted.map((e) => e.key).toList();
  print("Final recommended recipe labels: $recommendedLabels");
  return recommendedLabels;

  // return sorted.map((e) => e.key).toList();
}
