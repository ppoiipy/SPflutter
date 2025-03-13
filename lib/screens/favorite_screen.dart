import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle

import 'package:flutter_application_1/screens/food_detail_screen.dart';
import 'package:flutter_application_1/api/fetch_recipe_api.dart'; // Ensure this is correctly set up
import 'homepage.dart';
import 'menu_screen.dart';
import 'calculate_screen.dart';
import 'profile_screen.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final int _currentIndex = 2;
  List<dynamic> recipes = [];
  List<dynamic> filteredRecipes = [];

  Map<String, bool> favoriteRecipes = {};
  List<Map<String, dynamic>> _favoriteRecipes =
      []; // This stores the actual favorite recipes
  Map<String, bool> favoriteStatus =
      {}; // This stores the favorite status for each recipe

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    loadJsonData();
  }

  // Load favorite recipes from Firestore
  Future<void> _loadFavorites() async {
    var user = _auth.currentUser;
    if (user == null) return;

    // Fetch favorite recipes from Firestore
    var snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    List<Map<String, dynamic>> favoriteRecipesList = [];
    Map<String, bool> favoriteRecipesMap = {};

    for (var doc in snapshot.docs) {
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

  void loadJsonData() async {
    try {
      String jsonData =
          await rootBundle.loadString('assets/fetchMenu/recipe_output.json');
      Map<String, dynamic> jsonMap = json.decode(jsonData);
      setState(() {
        recipes = jsonMap['hits']?.map((hit) => hit['recipe'])?.toList() ?? [];
        filteredRecipes = List.from(recipes);
      });
    } catch (e) {
      // Handle error (e.g., JSON parsing or loading issue)
      print('Error loading JSON: $e');
    }
  }

  // Function to format recipe name to match image name
  String formatRecipeName(String recipeName) {
    // Remove special characters and replace spaces with underscores
    return recipeName.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
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

    bool isFavorite = favoriteRecipes[recipeLabel] == true;

    if (isFavorite) {
      // Remove from favorites
      await favoriteRef.delete();
    } else {
      // Add to favorites
      await favoriteRef.set(recipe);
    }

    setState(() {
      // Toggle the favorite status locally and update UI
      favoriteRecipes[recipeLabel] = !isFavorite;

      // If the recipe is not already in _favoriteRecipes, add it
      if (!isFavorite) {
        _favoriteRecipes.add(recipe);
      } else {
        // Remove the recipe from _favoriteRecipes if it's being unfavorited
        _favoriteRecipes
            .removeWhere((favRecipe) => favRecipe['label'] == recipeLabel);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            'Favorite Recipes',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              letterSpacing: 1,
            ),
          )),
      body: _favoriteRecipes.isEmpty
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
          : ListView.builder(
              itemCount: _favoriteRecipes.length,
              itemBuilder: (context, index) {
                var recipe = _favoriteRecipes[index];
                String recipeName = recipe['label']; // Recipe name
                String imageName = formatRecipeName(
                    recipeName); // Format it to match image name
                String imagePath =
                    'assets/fetchMenu/$imageName.jpg'; // Image path

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
                          errorBuilder: (BuildContext context, Object error,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_fire_department_outlined,
                                  color: Colors.red,
                                ),
                                Text(
                                  "${recipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt()} ${recipe['totalNutrients']['ENERC_KCAL']['unit']}",
                                ),
                              ],
                            ),
                            Text(recipe['source']),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FoodDetailScreen(recipe: recipe),
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
              MaterialPageRoute(builder: (context) => MenuScreen()),
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
              Icons.food_bank_outlined,
            ),
            label: 'Search',
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
