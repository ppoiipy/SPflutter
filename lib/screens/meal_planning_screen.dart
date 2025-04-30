import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// import 'package:ginraidee/api/fetch_food_api.dart';
import 'package:ginraidee/screens/homepage.dart';
import 'package:ginraidee/screens/history_screen.dart';
import 'package:ginraidee/screens/favorite_screen.dart';
import 'package:ginraidee/screens/calculate_screen.dart';
import 'package:ginraidee/screens/profile_screen.dart';
import 'package:ginraidee/screens/food_detail_screen.dart';

class MealPlanningScreen extends StatefulWidget {
  const MealPlanningScreen({super.key});

  @override
  _MealPlanningScreenState createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen> {
  int _selectedDuration = 7;
  void _updateMealPlan(int duration) {
    setState(() {
      _selectedDuration = duration;
    });
  }

  String selectedTab = 'Search';
  DateTime selectedDate = DateTime.now();
  // late Future<List<FoodItem>?> _foodFuture;
  List<Map<String, dynamic>> _favoriteRecipes = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentIndex = 0;

  List<dynamic> recipes = [];
  List<dynamic> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> allRecipes = [];
  Random _random = Random();
  bool mealsGenerated = false; // Flag to track meal generation
  // MARK: V1
  Map<String, List<Map<String, dynamic>>> mealPlan = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
  };
  // MARK: V2
  Map<DateTime, List<Map<String, dynamic>>> mealsByDate = {};

  // MARK: initState
  @override
  void initState() {
    super.initState();
    _loadUserData();
    // trackData();
    _loadFoodLog();
    // _loadRecipes();
    _loadRecipesFromJson();
    _loadWeightGoal();
    _controller.text = userData?['weightGoal']?.toString() ?? '';
    // _initializeMealsIfNeeded();
    _initializeMeals();
    generateOrLoadMealPlan(selectedDate);
  }

  void _initializeMeals() {
    if (!mealsGenerated) {
      // Generate and save meals for the first time
      // _refreshMeals();
      _generateMeals();
      mealsGenerated = true; // Set the flag after meals are generated
    }
  }

  // MARK: V1
  void _generateMeals() {
    double dailyCalorieGoal = calculateDailyCalorieGoal() ?? 2000;
    double breakfastCalories = dailyCalorieGoal * 0.3;
    double lunchCalories = dailyCalorieGoal * 0.35;
    double dinnerCalories = dailyCalorieGoal * 0.35;

    _loadRecipesFromJson().then((recipes) {
      setState(() {
        // Save the meals to the state for later reuse
        mealPlan['Breakfast'] = _getRecipesForMeal(recipes, breakfastCalories,
            shuffle: false); // No shuffle
        mealPlan['Lunch'] = _getRecipesForMeal(recipes, lunchCalories,
            shuffle: false); // No shuffle
        mealPlan['Dinner'] = _getRecipesForMeal(recipes, dinnerCalories,
            shuffle: false); // No shuffle
      });
    });
  }

  // MARK: V2

  // void _initializeMeals() {
  //   double dailyCalorieGoal = calculateDailyCalorieGoal() ?? 2000;
  //   double breakfastCalories = dailyCalorieGoal * 0.3;
  //   double lunchCalories = dailyCalorieGoal * 0.4;
  //   double dinnerCalories = dailyCalorieGoal * 0.3;

  //   _loadRecipesFromJson().then((recipes) {
  //     setState(() {
  //       dailyMeals['Breakfast'] =
  //           _getRecipesForMeal(recipes, breakfastCalories, shuffle: false);
  //       dailyMeals['Lunch'] = _getRecipesForMeal(recipes, lunchCalories);
  //       dailyMeals['Dinner'] = _getRecipesForMeal(recipes, dinnerCalories);
  //     });
  //   });
  // }

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
          _selectedActivityLevel =
              userData?["activityLevel"] ?? "Moderately active (3-5 days/week)";
          _weightController.text = userData?["weight"].toString() ?? '';
          _heightController.text = userData?["height"].toString() ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Future<void> _loadRecipes() async {
  //   try {
  //     // Load the JSON file from assets
  //     String jsonString =
  //         await rootBundle.loadString('assets/fetchMenu/recipe_output.json');

  //     // Decode the JSON string into a List of Maps
  //     List<dynamic> jsonResponse = json.decode(jsonString);

  //     // Cast the dynamic list to a List<Map<String, dynamic>>
  //     setState(() {
  //       allRecipes = List<Map<String, dynamic>>.from(jsonResponse);
  //     });
  //   } catch (e) {
  //     print('Error loading recipes: $e');
  //   }
  // }

  Map<String, dynamic>? _getRandomRecipeForCategory(String category) {
    if (recipes.isEmpty) return null;

    // If your recipe data has no 'category', use all recipes
    final random = Random();
    return recipes[random.nextInt(recipes.length)];
  }

  Future<List<Map<String, dynamic>>> _loadRecipesFromJson() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/fetchMenu/recipe_output.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      if (jsonMap['hits'] != null && jsonMap['hits'] is List) {
        final List<dynamic> hits = jsonMap['hits'];
        final List<Map<String, dynamic>> recipes = hits
            .map((hit) => Map<String, dynamic>.from(hit['recipe']))
            .toList();
        return recipes;
      } else {
        print("Key 'hits' is missing or not a list.");
        return [];
      }
    } catch (e) {
      print("Error loading menus: $e");
      return [];
    }
  }

// Filter recipes based on the daily calorie goal.
  Map<String, dynamic>? _getRandomRecipeByCalories(double targetCalories) {
    final filtered = recipes.where((r) {
      final kcal = r['totalNutrients']?['ENERC_KCAL']?['quantity'];
      return kcal != null &&
          kcal > targetCalories - 100 &&
          kcal < targetCalories + 100;
    }).toList();

    if (filtered.isEmpty) return null;
    return filtered[Random().nextInt(filtered.length)];
  }

  // MARK: Click
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

  // MARK: Format Num
  String formatNumber(int number) {
    return NumberFormat("#,###").format(number);
  }

  // void _fetchFoodData([String ingredient = ""]) {
  //   print("Fetching data for: $ingredient");
  //   setState(() {
  //     _foodFuture = FoodApiService.fetchFoodData(ingredient: "");
  //   });
  // }

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

    List<Map<String, dynamic>> favoriteRecipesList = [];
    Map<String, bool> favoriteRecipesMap = {};

    for (var doc in favoritesSnapshot.docs) {
      var recipe = doc.data();
      favoriteRecipesList.add(recipe);
      favoriteRecipesMap[recipe['label']] =
          true; // Mark this recipe as favorited
    }

    setState(() {
      _favoriteRecipes = favoriteRecipesList;
      favoriteRecipes = favoriteRecipesMap; // Update the map of favorite states
    });
  }

  void _toggleFavorite(String recipeLabel, Map<String, dynamic> recipe) {
    setState(() {
      if (favoriteRecipes[recipeLabel] == true) {
        favoriteRecipes.remove(recipeLabel);
        _favoriteRecipes.removeWhere((item) => item['label'] == recipeLabel);
      } else {
        favoriteRecipes[recipeLabel] = true;
        _favoriteRecipes.add(recipe);
      }
    });

    print("Updated Favorites: $_favoriteRecipes"); // Debugging
  }

  // MARK: Weight Goal
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;
  bool _isLoading = true;

  Future<void> _loadWeightGoal() async {
    final String uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null && data.containsKey('weightGoal')) {
        _controller.text = data['weightGoal'].toString();
      }
    } catch (e) {
      print('Error loading weight goal: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveWeightGoal() async {
    final String uid = _auth.currentUser?.uid ?? '';
    final String weightGoal = _controller.text.trim();

    setState(() {
      _isSaving = true;
    });

    try {
      double? newGoal = double.tryParse(_controller.text);
      if (newGoal == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid weight goal')),
        );
        return;
      }

      // Assume `userId` is already available
      await FirebaseFirestore.instance.collection('users').doc(uid).update(
          {'weightGoal': newGoal.toString()}); // or double if stored that way

      // Update local userData
      setState(() {
        userData!['weightGoal'] = newGoal;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Weight goal updated')),
      );
    } catch (e) {
      print("Error saving weight goal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update weight goal')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // MARK: BMI BMR TDEE
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // MARK: BMI
  double? _calculatedBMI() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      return weight / ((height / 100) * (height / 100)); // BMI formula
    }
    return null; // Return null if the input values are invalid
  }

  String _bmiCategory(double? bmi) {
    if (bmi == null) return "N/A";

    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi < 24.9) {
      return "Normal weight";
    } else if (bmi < 29.9) {
      return "Overweight";
    } else {
      return "Obese";
    }
  }

  final List<String> activityLevels = [
    "Sedentary (little to no exercise)",
    "Lightly active (1-3 days/week)",
    "Moderately active (3-5 days/week)",
    "Very active (6-7 days/week)",
    "Super active (very hard exercise, physical job)"
  ];

  String _selectedActivityLevel = "Moderately active (3-5 days/week)";

  // MARK: TDEE & BMR
  double? _calculateTDEE() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final dobString = userData?["dob"] ?? '';
    final gender = userData?["gender"] ?? "Male";

    // Check if weight, height, dob, and gender are valid
    if (weight == null ||
        height == null ||
        dobString.isEmpty ||
        gender.isEmpty) {
      print('Missing data for TDEE calculation');
      return null; // Return null if any necessary data is missing
    }

    // Convert dob string to DateTime with error handling
    DateTime dob;
    try {
      dob = DateTime.parse(dobString);
    } catch (e) {
      print('Error parsing DOB: $e');
      return null; // Return null if DOB is invalid
    }

    int age = _calculateAge(dob);

    // Calculate BMR using the Mifflin-St Jeor Equation
    double bmr;
    if (gender == "Male") {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Assign activity factor based on the activity level
    double activityFactor;
    switch (_selectedActivityLevel) {
      case "Sedentary (little to no exercise)":
        activityFactor = 1.2;
        break;
      case "Lightly active (1-3 days/week)":
        activityFactor = 1.375;
        break;
      case "Moderately active (3-5 days/week)":
        activityFactor = 1.55;
        break;
      case "Very active (6-7 days/week)":
        activityFactor = 1.725;
        break;
      case "Super active (very hard exercise, physical job)":
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.55; // Default to "Moderately active"
    }

    return bmr * activityFactor;
  }

  // MARK: Age
  int _calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--; // Adjust age if the birthday hasn't occurred yet this year
    }
    return age;
  }

  double? calculateDailyCalorieGoal() {
    if (userData == null ||
        userData!['weight'] == null ||
        userData!['weightGoal'] == null) {
      return null;
    }

    double weight = double.tryParse(userData!['weight'].toString()) ?? 0;
    double weightGoal =
        double.tryParse(userData!['weightGoal'].toString()) ?? 0;
    double? baseTDEE = _calculateTDEE(); // Your existing function

    if (baseTDEE == null) return null;

    double goalDiffKg = weightGoal - weight; // Positive = gain, Negative = lose
    double totalExtraCalories = goalDiffKg * 7700;

    // Avoid divide by zero
    if (_selectedDuration <= 0) return baseTDEE;

    double dailyAdjustment = totalExtraCalories / _selectedDuration;

    return baseTDEE + dailyAdjustment;
  }

  // void _refreshMeals() {
  //   final used = <Map<String, dynamic>>[];
  //   final double goalCalories = calculateDailyCalorieGoal() ?? 2000;

  //   Map<String, dynamic>? getUniqueRecipe(double calories) {
  //     final filtered = recipes.where((r) {
  //       final kcal = r['totalNutrients']?['ENERC_KCAL']?['quantity'];
  //       return kcal != null &&
  //           kcal > calories - 100 &&
  //           kcal < calories + 100 &&
  //           !used.contains(r);
  //     }).toList();

  //     if (filtered.isEmpty) return null;
  //     final selected = filtered[Random().nextInt(filtered.length)];
  //     used.add(selected);
  //     return selected;
  //   }

  //   setState(() {
  //     dailyMeals['Breakfast'] = _getRecipesForMeal(
  //         recipes.cast<Map<String, dynamic>>(), goalCalories * 0.3);
  //     dailyMeals['Lunch'] = _getRecipesForMeal(
  //         recipes.cast<Map<String, dynamic>>(), goalCalories * 0.4);
  //     dailyMeals['Dinner'] = _getRecipesForMeal(
  //         recipes.cast<Map<String, dynamic>>(), goalCalories * 0.3);
  //   });
  // }

  // MARK: V1
  // void _refreshMeals(DateTime selectedDate) async {
  //   setState(() {
  //     dailyMeals.clear(); // Clear current meals to show loading if needed
  //   });

  //   double dailyCalorieGoal = calculateDailyCalorieGoal() ?? 2000;
  //   double breakfastCalories = dailyCalorieGoal * 0.3;
  //   double lunchCalories = dailyCalorieGoal * 0.35;
  //   double dinnerCalories = dailyCalorieGoal * 0.35;

  //   final recipes = await _loadRecipesFromJson();
  //   if (recipes.isEmpty) return;

  //   // Get recommended meals for each
  //   final breakfast =
  //       _getRecipesForMeal(recipes, breakfastCalories, shuffle: true);
  //   final lunch = _getRecipesForMeal(recipes, lunchCalories, shuffle: true);
  //   final dinner = _getRecipesForMeal(recipes, dinnerCalories, shuffle: true);

  //   // Save to local state
  //   setState(() {
  //     dailyMeals['Breakfast'] = breakfast;
  //     dailyMeals['Lunch'] = lunch;
  //     dailyMeals['Dinner'] = dinner;
  //   });

  //   // Save to Firestore
  //   final userId = FirebaseAuth.instance.currentUser!.uid;
  //   final mealPlanRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('meal_plan')
  //       .doc(DateFormat('yyyy-MM-dd')
  //           .format(selectedDate)); // format: "2025-04-26"

  //   await mealPlanRef.set({
  //     'date': Timestamp.fromDate(selectedDate),
  //     'Breakfast': breakfast,
  //     'Lunch': lunch,
  //     'Dinner': dinner,
  //   });
  // }
  // MARK: V2
  void _refreshMeals(DateTime selectedDate) async {
    setState(() {
      dailyMeals.clear(); // Clear the current meal plan to force a refresh
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final mealPlanRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('meal_plan')
        .doc(DateFormat('yyyy-MM-dd')
            .format(selectedDate)); // Use formatted date

    // Generate the new meal plan
    double dailyCalorieGoal = calculateDailyCalorieGoal() ?? 2000;
    double breakfastCalories = dailyCalorieGoal * 0.3;
    double lunchCalories = dailyCalorieGoal * 0.35;
    double dinnerCalories = dailyCalorieGoal * 0.35;

    final recipes = await _loadRecipesFromJson();
    if (recipes.isEmpty) return;

    // Get recommended meals for each
    final breakfast =
        _getRecipesForMeal(recipes, breakfastCalories, shuffle: true);
    final lunch = _getRecipesForMeal(recipes, lunchCalories, shuffle: true);
    final dinner = _getRecipesForMeal(recipes, dinnerCalories, shuffle: true);

    // Save the newly generated meal plan to Firestore
    await mealPlanRef.set({
      'date': Timestamp.fromDate(selectedDate),
      'Breakfast': breakfast,
      'Lunch': lunch,
      'Dinner': dinner,
    });

    // Update the UI with the newly generated meal plan
    setState(() {
      dailyMeals['Breakfast'] = breakfast;
      dailyMeals['Lunch'] = lunch;
      dailyMeals['Dinner'] = dinner;
    });
  }

  Future<void> generateOrLoadMealPlan(DateTime date) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final mealPlanRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('meal_plan')
        .doc(DateFormat('yyyy-MM-dd').format(date));

    final mealPlanSnapshot = await mealPlanRef.get();

    if (mealPlanSnapshot.exists) {
      // If meal plan exists, load it
      final data = mealPlanSnapshot.data();
      setState(() {
        dailyMeals['Breakfast'] =
            List<Map<String, dynamic>>.from(data?['Breakfast'] ?? []);
        dailyMeals['Lunch'] =
            List<Map<String, dynamic>>.from(data?['Lunch'] ?? []);
        dailyMeals['Dinner'] =
            List<Map<String, dynamic>>.from(data?['Dinner'] ?? []);
      });
    } else {
      // If no meal plan exists, generate a new one
      await _generateAndSaveMealPlan(date);
    }
  }

  Future<void> _generateAndSaveMealPlan(DateTime date) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final mealPlanRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('meal_plan')
        .doc(DateFormat('yyyy-MM-dd').format(date));

    final double dailyCalorieGoal = calculateDailyCalorieGoal() ?? 2000;
    final double breakfastCalories = dailyCalorieGoal * 0.3;
    final double lunchCalories = dailyCalorieGoal * 0.35;
    final double dinnerCalories = dailyCalorieGoal * 0.35;

    final recipes = await _loadRecipesFromJson();
    if (recipes.isEmpty) return;

    final breakfast =
        _getRecipesForMeal(recipes, breakfastCalories, shuffle: true);
    final lunch = _getRecipesForMeal(recipes, lunchCalories, shuffle: true);
    final dinner = _getRecipesForMeal(recipes, dinnerCalories, shuffle: true);

    await mealPlanRef.set({
      'date': Timestamp.fromDate(date),
      'Breakfast': breakfast,
      'Lunch': lunch,
      'Dinner': dinner,
    });

    setState(() {
      dailyMeals['Breakfast'] = breakfast;
      dailyMeals['Lunch'] = lunch;
      dailyMeals['Dinner'] = dinner;
    });
  }

  // MARK: UI - Build Meal
  // MARK: V1
  // List<Map<String, dynamic>> _getRecipesForMeal(
  //     List<Map<String, dynamic>> recipes, double targetCalories,
  //     {bool shuffle = false}) {
  //   final used = <Map<String, dynamic>>[];
  //   final remaining = List<Map<String, dynamic>>.from(recipes);

  //   if (shuffle) {
  //     remaining.shuffle(); // Only shuffle when needed
  //   }

  //   double totalCalories = 0;
  //   List<Map<String, dynamic>> selectedRecipes = [];

  //   for (final recipe in remaining) {
  //     final kcal =
  //         recipe['totalNutrients']?['ENERC_KCAL']?['quantity']?.toDouble();
  //     if (kcal == null || used.contains(recipe)) continue;

  //     if (totalCalories + kcal <= targetCalories + 50) {
  //       selectedRecipes.add(recipe);
  //       used.add(recipe);
  //       totalCalories += kcal;
  //     }

  //     if (totalCalories >= targetCalories - 50) break;
  //   }

  //   return selectedRecipes;
  // }
  // MARK: V2
  List<Map<String, dynamic>> _getRecipesForMeal(
      List<Map<String, dynamic>> recipes, double calorieGoal,
      {bool shuffle = false}) {
    List<Map<String, dynamic>> selectedRecipes = [];
    double totalCalories = 0;

    List<Map<String, dynamic>> availableRecipes = List.from(recipes);
    if (shuffle) {
      availableRecipes.shuffle();
    }

    for (final recipe in availableRecipes) {
      final totalNutrients = recipe['totalNutrients'];
      if (totalNutrients == null || totalNutrients['ENERC_KCAL'] == null) {
        continue; // Skip recipes without calorie info
      }

      final recipeCalories =
          (totalNutrients['ENERC_KCAL']['quantity'] as num).toDouble();

      if (recipeCalories > 1200) {
        continue; // Skip super high-calorie recipes
      }

      // Check if adding this recipe would exceed the calorieGoal
      if (totalCalories + recipeCalories <= calorieGoal) {
        selectedRecipes.add(recipe);
        totalCalories += recipeCalories;
      }

      // If close enough (e.g., 95% of goal), stop early to avoid infinite loop
      if (totalCalories >= calorieGoal * 0.95) {
        break;
      }
    }

    return selectedRecipes;
  }

  // List<Map<String, dynamic>> _getRecipesForMeal(
  //     List<Map<String, dynamic>> recipes, double targetCalories,
  //     {bool shuffle = false}) {
  //   final used = <Map<String, dynamic>>[];
  //   final remaining = List<Map<String, dynamic>>.from(recipes);

  //   // Shuffle only if the flag is true (i.e., during refresh)
  //   if (shuffle) {
  //     remaining.shuffle();
  //   }

  //   double totalCalories = 0;
  //   List<Map<String, dynamic>> selectedRecipes = [];

  //   for (final recipe in remaining) {
  //     final kcal =
  //         recipe['totalNutrients']?['ENERC_KCAL']?['quantity']?.toDouble();
  //     if (kcal == null || used.contains(recipe)) continue;

  //     if (totalCalories + kcal <= targetCalories + 50) {
  //       selectedRecipes.add(recipe);
  //       used.add(recipe);
  //       totalCalories += kcal;
  //     }

  //     if (totalCalories >= targetCalories - 50) break;
  //   }

  //   return selectedRecipes;
  // }

  // MARK: V1
  Widget _buildMealPlans() {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMealCategory('Breakfast', selectedDate),
                  _buildMealCategory('Lunch', selectedDate),
                  _buildMealCategory('Dinner', selectedDate),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: V2

  Widget _buildMealCategory(String category, DateTime date) {
    double dailyCalorieGoal = calculateDailyCalorieGoal() ?? 2000;
    double calorieGoal;

    switch (category) {
      case 'Breakfast':
        calorieGoal = dailyCalorieGoal * 0.3;
        break;
      case 'Lunch':
        calorieGoal = dailyCalorieGoal * 0.35;
        break;
      case 'Dinner':
        calorieGoal = dailyCalorieGoal * 0.35;
        break;
      default:
        calorieGoal = dailyCalorieGoal / 3;
    }

    IconData categoryIcon;
    switch (category) {
      case 'Breakfast':
        categoryIcon = Icons.free_breakfast;
        break;
      case 'Lunch':
        categoryIcon = Icons.lunch_dining;
        break;
      case 'Dinner':
        categoryIcon = Icons.dinner_dining;
        break;
      default:
        categoryIcon = Icons.fastfood;
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadRecipesFromJson(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading recipes'));
        }

        final recipes = snapshot.data ?? [];

        final filteredRecipes = recipes.where((recipe) {
          final totalNutrients = recipe['totalNutrients'];
          if (totalNutrients == null || totalNutrients['ENERC_KCAL'] == null) {
            return false; // If missing calories data, skip this recipe
          }
          double calories =
              (totalNutrients['ENERC_KCAL']['quantity'] as num).toDouble();
          return calories <= 1200; // ✅ Only keep recipes with ≤ 1200 calories
        }).toList();

        List<Map<String, dynamic>> selectedRecipes = dailyMeals[category] ?? [];

        int totalCalories = selectedRecipes.fold(0, (sum, recipe) {
          double calories =
              (recipe['totalNutrients']['ENERC_KCAL']['quantity'] as num)
                  .toDouble();
          return sum + calories.toInt();
        });

        double progress = (totalCalories / calorieGoal).clamp(0, 1);

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(categoryIcon, color: Colors.teal[600], size: 24),
                    SizedBox(width: 8),
                    Text(
                      category,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                      '${formatNumber(totalCalories)} / ${formatNumber(calorieGoal.toInt())} kcal',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.teal,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
                SizedBox(height: 12),
                selectedRecipes.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text("No meals available in this category"),
                        ),
                      )
                    : Column(
                        children: selectedRecipes.map((selectedRecipe) {
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/fetchMenu/' +
                                      selectedRecipe['label']
                                          ?.toLowerCase()
                                          .replaceAll(' ', '_') +
                                      '.jpg',
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/default.png',
                                      width: 55,
                                      height: 55,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                              title: Text(
                                selectedRecipe['label'] ?? 'Unknown Recipe',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                "${formatNumber(selectedRecipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt())} kcal",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: Colors.teal),
                                onSelected: (String value) async {
                                  final userId =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  if (value == 'delete' && userId != null) {
                                    setState(() {
                                      selectedRecipes.remove(selectedRecipe);
                                    });

                                    final mealPlanDoc = await FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .doc(userId)
                                        .collection('meal_plan')
                                        .doc(DateFormat('yyyy-MM-dd')
                                            .format(selectedDate))
                                        .get();

                                    if (mealPlanDoc.exists) {
                                      final mealData = mealPlanDoc.data();
                                      final updatedMeals =
                                          List<Map<String, dynamic>>.from(
                                        mealData?[selectedRecipe['mealType']] ??
                                            [],
                                      );

                                      updatedMeals.removeWhere((meal) =>
                                          meal['label'] ==
                                          selectedRecipe['label']);

                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userId)
                                          .collection('meal_plan')
                                          .doc(DateFormat('yyyy-MM-dd')
                                              .format(selectedDate))
                                          .update({
                                        selectedRecipe['mealType']:
                                            updatedMeals,
                                      });
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "${selectedRecipe['label']} has been deleted.")),
                                    );
                                  } else if (value == 'favorite') {
                                    _changeMeal(
                                        selectedRecipe); // You can remove this if not needed.
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    PopupMenuItem<String>(
                                      value: 'addLog',
                                      child: Row(
                                        children: [
                                          Icon(Icons.add_circle_outline,
                                              color: Colors.green),
                                          SizedBox(width: 8),
                                          Text('Add Log Menu'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete Menu'),
                                        ],
                                      ),
                                    ),
                                  ];
                                },
                              ),
                              onTap: () {
                                logRecipeClick(
                                  selectedRecipe['label'],
                                  selectedRecipe['source'],
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodDetailScreen(
                                      recipe: selectedRecipe,
                                      selectedDate: selectedDate,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  // MARK: END UI - Build Meal

  Map<String, List<Map<String, dynamic>>> dailyMeals = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
  };

  List<Map<String, dynamic>> _loggedMeals = [];

  // MARK: V1
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
  // MARK: V2
  // void _loadFoodLog() async {
  //   // Fetch or generate meals for the selected date if they aren't already loaded
  //   if (!mealsByDate.containsKey(selectedDate)) {
  //     // Logic to load meals for the selected date
  //     var meals = await _fetchMealsForDate(
  //         selectedDate); // Replace with your meal fetching logic
  //     setState(() {
  //       mealsByDate[selectedDate] = meals;
  //     });
  //   }
  // }

  // MARK: Date Selector
  // MARK: V1
  Widget _buildDateSelector() {
    List<DateTime> programDays = List.generate(
      _selectedDuration,
      (index) => DateTime.now().add(Duration(days: index)),
    );

    return Container(
      height: 100,
      alignment: Alignment.center,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: programDays.length,
          itemBuilder: (context, index) {
            DateTime date = programDays[index];
            bool isSelected = selectedDate.day == date.day &&
                selectedDate.month == date.month &&
                selectedDate.year == date.year;

            bool isFirstOfMonth = date.day == 1;
            bool isLastOfMonth = (index + 1 < programDays.length) &&
                date.month != programDays[index + 1].month;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    selectedDate = date;
                  });

                  await generateOrLoadMealPlan(selectedDate);

                  final allMeals = [
                    ...?dailyMeals['Breakfast'],
                    ...?dailyMeals['Lunch'],
                    ...?dailyMeals['Dinner'],
                  ];

                  double totalCalories = 0;
                  for (var meal in allMeals) {
                    if (meal.containsKey('calories')) {
                      totalCalories += (meal['calories'] as num).toDouble();
                    }
                  }

                  final dailyGoal = calculateDailyCalorieGoal() ?? 2000;
                  final lowerThreshold = dailyGoal * 0.8;

                  if (totalCalories > dailyGoal ||
                      totalCalories < lowerThreshold) {
                    await _generateAndSaveMealPlan(selectedDate);
                  }
                },
                child: Column(
                  children: [
                    Text(
                      DateFormat.E().format(date),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.teal : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.teal : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.teal),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    if (isFirstOfMonth || isLastOfMonth)
                      Text(
                        DateFormat.MMM().format(date),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.teal,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  // MARK: V2

  Future<void> _changeMeal(Map<String, dynamic> meal) async {
    // Implement the logic to allow the user to change the meal.
    // You could use a dialog or navigate to a new screen for editing the meal.
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

  // MARK: add meal to history
  Future<void> addMealsToHistory(
    List<Map<String, dynamic>>
        meals, // List of meals (for breakfast, lunch, etc.)
    DateTime date, // The selected date
    String mealType, // The meal type (e.g., Breakfast, Lunch, etc.)
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final logRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('food_log');
    final firestoreTimestamp = Timestamp.fromDate(date);
    final loggedDate = Timestamp.fromDate(DateTime.now());

    // Loop through the list of meals and add them as separate logs
    for (var meal in meals) {
      await logRef.add({
        'recipe': meal, // Meal details (e.g., name, ingredients, etc.)
        'mealType': mealType, // Meal type (Breakfast, Lunch, etc.)
        'date': firestoreTimestamp, // Timestamp for the selected date
        'loggedDate': loggedDate, // Timestamp for the current time of logging
      });

      // Optional: Show a snack bar for each added meal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${meal['label']} added to $mealType")),
      );
    }
  }

  // MARK: Widget Build
  @override
  Widget build(BuildContext context) {
    int totalCalorieLimit = (_calculateTDEE() ?? 2000).toInt();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Meal Plan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 1,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Homepage()));
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program Duration Selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.timer, color: Colors.teal[700]),
                SizedBox(width: 10),
                Text(
                  "Program Duration:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(width: 12),
                // MARK: V1
                // DropdownButton<int>(
                //   value: _selectedDuration,
                //   underline: SizedBox(),
                //   style: TextStyle(fontSize: 16, color: Colors.black),
                //   items: [1, 7, 15, 30].map((int value) {
                //     return DropdownMenuItem<int>(
                //       value: value,
                //       child: Text('$value days'),
                //     );
                //   }).toList(),
                //   onChanged: (int? newValue) {
                //     if (newValue != null) {
                //       setState(() {
                //         _selectedDuration = newValue;
                //       });
                //     }
                //   },
                // ),
                // MARK: V2
                DropdownButton<int>(
                  value: _selectedDuration,
                  items: [
                    DropdownMenuItem(child: Text("1 Week"), value: 7),
                    DropdownMenuItem(child: Text("15 Days"), value: 15),
                    DropdownMenuItem(child: Text("1 Month"), value: 30),
                    DropdownMenuItem(child: Text("2 Month"), value: 60),
                    DropdownMenuItem(child: Text("3 Month"), value: 90),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        // Validate the selected value to ensure it's one of the allowed values
                        if ([7, 15, 30, 60, 90].contains(value)) {
                          _selectedDuration = value!;
                          _generateMeals(); // Regenerate meals for the new duration
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Date Selector
          _buildDateSelector(),

          // Daily Calorie Goal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.flag, color: Colors.teal[700]),
                SizedBox(width: 10),
                Text(
                  'Goal: ${calculateDailyCalorieGoal()?.toStringAsFixed(2) ?? "N/A"} kcal/day',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),

          // Weight Goal Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight Goal (kg)',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            _saveWeightGoal();
                            // _refreshMeals(selectedDate);
                          },
                    icon: _isSaving
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.save, color: Colors.teal[800]),
                    label: _isSaving
                        ? SizedBox.shrink()
                        : Text(
                            'Save',
                            style: TextStyle(color: Colors.teal[800]),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[50],
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Date Header + Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('EEEE, d MMM').format(selectedDate),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon:
                      Icon(Icons.add_circle, size: 28, color: Colors.teal[800]),
                  onPressed: () async {
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    final dateKey =
                        DateFormat('yyyy-MM-dd').format(selectedDate);

                    if (userId == null) return;

                    final mealPlanDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('meal_plan')
                        .doc(dateKey)
                        .get();

                    if (mealPlanDoc.exists) {
                      final mealData = mealPlanDoc.data();

                      for (final mealType in ['Breakfast', 'Lunch', 'Dinner']) {
                        final meals = List<Map<String, dynamic>>.from(
                            mealData?[mealType] ?? []);

                        // Loop through each meal and add them individually to the history
                        for (final meal in meals) {
                          await addMealsToHistory([meal], selectedDate,
                              mealType); // Add each meal separately
                        }
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Meals added to food log for ${DateFormat('d MMM').format(selectedDate)}")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "No meals found in meal plan for this date.")),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.refresh, size: 28, color: Colors.teal[800]),
                  onPressed: () {
                    _refreshMeals(selectedDate);
                  },
                ),
              ],
            ),
          ),

          // Meal Plan UI
          _buildMealPlans(),
        ],
      ),
      // MARK: bottomNav
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(color: Colors.black),
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
