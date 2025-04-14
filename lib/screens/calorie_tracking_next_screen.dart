import 'dart:convert';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:ginraidee/screens/calorie_tracking_screen.dart';
import 'package:ginraidee/api/fetch_food_api.dart';
import 'package:ginraidee/screens/food_detail_screen.dart';

class CalorieTrackingNextScreen extends StatefulWidget {
  final String mealType;

  CalorieTrackingNextScreen({required this.mealType});

  @override
  _CalorieTrackingNextScreenState createState() =>
      _CalorieTrackingNextScreenState();
}

class _CalorieTrackingNextScreenState extends State<CalorieTrackingNextScreen> {
  String selectedTab = 'History';
  DateTime selectedDate = DateTime.now();
  late Future<List<FoodItem>?> _foodFuture;
  List<Map<String, dynamic>> _favoriteRecipes = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchFoodData();
    _loadFavorites();
    loadJsonData();
    _loadFoodLog();
  }

  String formatNumber(int number) {
    return NumberFormat("#,###").format(number);
  }

  void _fetchFoodData([String ingredient = ""]) {
    print("Fetching data for: $ingredient");
    setState(() {
      _foodFuture = FoodApiService.fetchFoodData(ingredient: "");
    });
  }

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
      // favoriteRecipes = favoriteRecipesMap; // Update the map of favorite states
    });
  }

  // void _toggleFavorite(String recipeLabel, Map<String, dynamic> recipe) {
  //   setState(() {
  //     if (favoriteRecipes[recipeLabel] == true) {
  //       favoriteRecipes.remove(recipeLabel);
  //       _favoriteRecipes.removeWhere((item) => item['label'] == recipeLabel);
  //     } else {
  //       favoriteRecipes[recipeLabel] = true;
  //       _favoriteRecipes.add(recipe);
  //     }
  //   });

  //   print("Updated Favorites: $_favoriteRecipes"); // Debugging
  // }

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

  List<dynamic> recipes = [];
  List<dynamic> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();

  // Load data from JSON file in assets/fetchMenu
  void loadJsonData() async {
    String jsonData =
        await rootBundle.loadString('assets/fetchMenu/recipe_output.json');
    Map<String, dynamic> jsonMap = json.decode(jsonData);
    recipes = jsonMap['hits'].map((hit) => hit['recipe']).toList();

    await _loadFavorites();

    setState(() {
      filteredRecipes = List.from(recipes);
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

  String formatRecipeName(String recipeName) {
    // Remove special characters and replace spaces with underscores
    return recipeName.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
  }

  // Function to show meal plans (Breakfast, Lunch, Dinner) on the Diary Tab
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

  // #V1
  // Widget _buildMealCategory(String category) {
  //   List<Map<String, dynamic>> meals =
  //       _loggedMeals.where((meal) => meal['mealType'] == category).toList();

  //   return Container(
  //     padding: EdgeInsets.all(8),
  //     margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.grey[300],
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
  //                       'assets/fetchMenu/${formatRecipeName(recipe['label'])}.jpg',
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
  //                         "${recipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt()} kcal"),
  //                     trailing: IconButton(
  //                       icon: Icon(Icons.delete, color: Colors.red),
  //                       onPressed: () => _removeMeal(meal),
  //                     ),
  //                     onTap: () {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) =>
  //                               FoodDetailScreen(recipe: recipe),
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

  // #V2
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
                        logRecipeClick(recipe['label'], recipe['source']);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetailScreen(
                              recipe: recipe,
                              selectedDate: selectedDate,
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

  Future<void> _pickDate() async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height / 3.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1F5F5B), Color(0xFF40C5BD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    centerTitle: true,
                    title: Text(
                      // widget.mealType,
                      'Calorie Tracking',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        letterSpacing: 1,
                      ),
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CalorieTrackingScreen()));
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.black45),
                      prefixIcon: Icon(Icons.search, color: Colors.black54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedTab = 'History';
                        });
                        _loadFoodLog();
                      },
                      child: Column(
                        children: [
                          Text('History',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500)),
                          if (selectedTab == 'History')
                            Container(
                                height: 3, width: 80, color: Colors.white),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedTab = 'Search';
                        });
                      },
                      child: Column(
                        children: [
                          Text('Search',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500)),
                          if (selectedTab == 'Search')
                            Container(
                                height: 3, width: 80, color: Colors.white),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedTab = 'Favorites';
                        });
                      },
                      child: Column(
                        children: [
                          Text('Favorites',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500)),
                          if (selectedTab == 'Favorites')
                            Container(
                                height: 3, width: 95, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon:
                          Icon(Icons.arrow_left, color: Colors.white, size: 32),
                      onPressed: () => _changeDate(-1),
                    ),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Text(
                        DateFormat('dd MMM yyyy').format(selectedDate),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => _changeDate(1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          selectedTab == 'Search'
              ? SizedBox(
                  height: MediaQuery.of(context).size.height / 1.43,
                  child: ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      var recipe = filteredRecipes[index];
                      String imagePath = 'assets/fetchMenu/' +
                          recipe['label']?.toLowerCase().replaceAll(' ', '_') +
                          '.jpg';

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
                                    Object error, StackTrace? stackTrace) {
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_fire_department_outlined,
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
                                    builder: (context) => FoodDetailScreen(
                                      recipe: recipe,
                                      selectedDate: selectedDate,
                                    ),
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
                                color: favoriteRecipes[recipe['label']] == true
                                    ? Color.fromARGB(255, 255, 191, 0)
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                _toggleFavorite(recipe['label'], recipe);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              : selectedTab == 'Favorites'
                  ? _favoriteRecipes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/error.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'No favorite recipes added yet.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _favoriteRecipes.length,
                            itemBuilder: (context, index) {
                              var recipe = _favoriteRecipes[index];
                              String recipeName = recipe['label'];
                              String imagePath = 'assets/fetchMenu/' +
                                  recipe['label']
                                      ?.toLowerCase()
                                      .replaceAll(' ', '_') +
                                  '.jpg';

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
                                      title: Text(recipeName),
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
                                              recipe: recipe,
                                              selectedDate: selectedDate,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
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
                        )
                  : _buildMealPlans(),
        ],
      ),
    );
  }
}
