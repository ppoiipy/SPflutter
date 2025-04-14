import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:ginraidee/api/fetch_food_api.dart';
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
  int _selectedDuration = 1;
  void _updateMealPlan(int duration) {
    setState(() {
      _selectedDuration = duration;
    });
  }

  String selectedTab = 'Search';
  DateTime selectedDate = DateTime.now();
  late Future<List<FoodItem>?> _foodFuture;
  List<Map<String, dynamic>> _favoriteRecipes = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentIndex = 0;

  List<dynamic> recipes = [];
  List<dynamic> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> allRecipes = [];
  Random _random = Random();

  // MARK: initState
  @override
  void initState() {
    super.initState();
    _loadUserData();
    // trackData();
    _loadFoodLog();
    _loadRecipes();
    _loadWeightGoal();
    _controller.text = userData?['weightGoal']?.toString() ?? '';
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

  Future<void> _loadRecipes() async {
    try {
      // Load the JSON file from assets
      String jsonString =
          await rootBundle.loadString('assets/recipe_output.json');

      // Decode the JSON string into a List of Maps
      List<dynamic> jsonResponse = json.decode(jsonString);

      // Cast the dynamic list to a List<Map<String, dynamic>>
      setState(() {
        allRecipes = List<Map<String, dynamic>>.from(jsonResponse);
      });
    } catch (e) {
      print('Error loading recipes: $e');
    }
  }

  Map<String, dynamic>? _getRandomRecipeForCategory(String category) {
    // Filter recipes based on the meal category
    List<Map<String, dynamic>> categoryRecipes = allRecipes.where((recipe) {
      return recipe['mealType'] == category;
    }).toList();

    // If there are recipes for this category, return a random one
    if (categoryRecipes.isNotEmpty) {
      Random random = Random();
      return categoryRecipes[random.nextInt(categoryRecipes.length)];
    }

    return null; // If no recipes for the category
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

  // Future<void> _saveWeightGoal() async {
  //   final String uid = _auth.currentUser?.uid ?? '';
  //   final String weightGoal = _controller.text.trim();

  //   if (weightGoal.isEmpty) return;

  //   setState(() {
  //     _isSaving = true;
  //   });

  //   try {
  //     await FirebaseFirestore.instance.collection('users').doc(uid).update({
  //       'weightGoal': weightGoal,
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Weight goal saved!')),
  //     );
  //   } catch (e) {
  //     print('Error updating weight goal: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to save.')),
  //     );
  //   } finally {
  //     setState(() {
  //       _isSaving = false;
  //     });
  //   }
  // }

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
      bmr = (9.99 * weight) + (6.25 * height) - (4.92 * age) + 5;
    } else {
      bmr = (9.99 * weight) + (6.25 * height) - (4.92 * age) - 161;
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

  // MARK: UI - Build Meal
  Widget _buildMealPlans() {
    return Expanded(
      child: SingleChildScrollView(
          child: Column(
        children: [
          _buildMealCategory('Breakfast', selectedDate),
          _buildMealCategory('Lunch', selectedDate),
          _buildMealCategory('Dinner', selectedDate),
        ],
      )),
    );
  }

  Widget _buildMealCategory(String category, DateTime date) {
    // Get a random recipe for the category
    String formattedDate = DateFormat('dd').format(date);
    var randomRecipe = _getRandomRecipeForCategory(category);

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // '$category for Day $formattedDate',
            category,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          randomRecipe == null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("No meals available"),
                )
              : ListTile(
                  leading: Image.asset(
                    'assets/fetchMenu/' +
                        randomRecipe['label']
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
                  title: Text(randomRecipe['label'] ?? 'Unknown Recipe'),
                  subtitle: Text(
                      "${formatNumber(randomRecipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt())} kcal"),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.teal[700]),
                    onSelected: (String value) {
                      if (value == 'delete') {
                        _removeMeal(randomRecipe);
                      } else if (value == 'change') {
                        _changeMeal(randomRecipe);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'change',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.teal),
                              SizedBox(width: 8),
                              Text('Change Menu'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete Meal'),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                  onTap: () {
                    logRecipeClick(
                        randomRecipe['label'], randomRecipe['shareAs']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodDetailScreen(
                          recipe: randomRecipe,
                          selectedDate: selectedDate,
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
  // Widget _buildMealCategory(String category) {
  //   // Filter meals by selected date and category
  //   List<Map<String, dynamic>> meals =
  //       _loggedMeals.where((meal) => meal['mealType'] == category).toList();

  //   return Container(
  //     padding: EdgeInsets.all(8),
  //     margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //     width: MediaQuery.sizeOf(context).width,
  //     decoration: BoxDecoration(
  //       color: Colors.grey[200],
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           category,
  //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         ),
  //         meals.isEmpty
  //             ? Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Text("No meals logged"),
  //               )
  //             : Column(
  //                 children: meals.map((meal) {
  //                   var recipe = meal['recipe'];
  //                   return ListTile(
  //                     leading: Image.asset(
  //                       'assets/fetchMenu/' +
  //                           recipe['label']
  //                               ?.toLowerCase()
  //                               .replaceAll(' ', '_') +
  //                           '.jpg',
  //                       width: 50,
  //                       height: 50,
  //                       fit: BoxFit.cover,
  //                       errorBuilder: (context, error, stackTrace) {
  //                         return Image.asset(
  //                           'assets/images/default.png', // Fallback image
  //                           width: 50,
  //                           height: 50,
  //                           fit: BoxFit.cover,
  //                         );
  //                       },
  //                     ),
  //                     title: Text(recipe['label'] ?? 'Unknown Recipe'),
  //                     subtitle: Text(
  //                         "${formatNumber(recipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt())} kcal"),
  //                     trailing: PopupMenuButton<String>(
  //                       icon: Icon(Icons.more_vert, color: Colors.teal[700]),
  //                       onSelected: (String value) {
  //                         if (value == 'delete') {
  //                           _removeMeal(
  //                               meal); // Call your existing remove function
  //                         } else if (value == 'change') {
  //                           _changeMeal(
  //                               meal); // Add your function to change the meal
  //                         }
  //                       },
  //                       itemBuilder: (BuildContext context) {
  //                         return [
  //                           PopupMenuItem<String>(
  //                             value: 'change',
  //                             child: Row(
  //                               children: [
  //                                 Icon(Icons.edit, color: Colors.teal),
  //                                 SizedBox(width: 8),
  //                                 Text('Change Menu'),
  //                               ],
  //                             ),
  //                           ),
  //                           PopupMenuItem<String>(
  //                             value: 'delete',
  //                             child: Row(
  //                               children: [
  //                                 Icon(Icons.delete, color: Colors.red),
  //                                 SizedBox(width: 8),
  //                                 Text('Delete Meal'),
  //                               ],
  //                             ),
  //                           ),
  //                         ];
  //                       },
  //                     ),
  //                     onTap: () {
  //                       logRecipeClick(recipe['label'], recipe['shareAs']);

  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => FoodDetailScreen(
  //                             recipe: recipe,
  //                             selectedDate:
  //                                 selectedDate, // Pass selected date here
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   );
  //                 }).toList(),
  //               ),
  //       ],
  //     ),
  //   );
  // }

  // MARK: END UI - Build Meal

  List<Map<String, dynamic>> _loggedMeals = [];

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

  // MARK: Date
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

  // MARK: Date Selector
  Widget _buildDateSelector() {
    List<DateTime> programDays = List.generate(
      _selectedDuration,
      (index) => DateTime.now().add(Duration(days: index)),
    );

    List<DateTime> last7Days =
        List.generate(7, (index) => DateTime.now().add(Duration(days: index)));

    return Container(
      height: 100,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: programDays.length, // ← use the correct list length here
        itemBuilder: (context, index) {
          DateTime date = programDays[index];
          bool isSelected = selectedDate.day == date.day &&
              selectedDate.month == date.month &&
              selectedDate.year == date.year;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = date;
                });
                _loadFoodLog();
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text("Program Duration: ",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: _selectedDuration,
                  items: [1, 7, 15, 30].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value days'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedDuration = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          _buildDateSelector(),
          SizedBox(
            child: Text(
              'TDEE: ${_calculateTDEE() != null ? _calculateTDEE()!.toStringAsFixed(2) : "N/A"} kcal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Goal: ${calculateDailyCalorieGoal()?.toStringAsFixed(2) ?? "N/A"} kcal/day',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveWeightGoal,
                    icon: _isSaving
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Icons.save,
                            color: Colors.teal[800],
                          ),
                    label: _isSaving
                        ? Text('')
                        : Text(
                            'Save',
                            style: TextStyle(color: Colors.teal[800]),
                          ),
                    style: ElevatedButton.styleFrom(
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
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 10),
                child: Text(
                  DateFormat('EEEE, d MMM').format(selectedDate),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(
                  Icons.add_circle,
                  size: 32,
                  color: Colors.teal[800],
                ),
              ),
            ],
          ),
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
