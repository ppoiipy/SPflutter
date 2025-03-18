// 5
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:flutter/material.dart';
import 'food_detail_screen.dart';
import 'filter_sheet.dart';
import 'homepage.dart';
import 'favorite_screen.dart';
import 'calculate_screen.dart';
import 'profile_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final int _currentIndex = 1;

  Map<String, dynamic>? selectedFilters;
  double? _selectedCalories;
  Set<String> selectedCategories = {};
  Set<String> selectedIngredients = {};
  Set<String> selectedAllergies = {};

  List<dynamic> recipes = [];
  List<dynamic> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();
  String selectedCuisineType = "All";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, bool> favoriteRecipes = {};

  @override
  void initState() {
    super.initState();
    loadJsonData();
    _loadUserFilters(); // Load filters from Firebase when screen starts
  }

  // Load user-selected filters from Firebase
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
                      .contains(cuisineType.toLowerCase())) &&
              (selectedCategories.isEmpty ||
                  selectedCategories.contains(recipe['cuisineType'])))
          .toList();
    });
  }

  // Call Filter Sheet Function
  void openFilterSheet() async {
    final filters = await showFilterSheet(context);
    if (filters != null) {
      setState(() {
        selectedFilters = filters; // Store the complete filter data
      });
      print("Selected Filters: $selectedFilters");
    }
  }

  // Open Calorie Filter
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

  // Open Category Filter
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
          height: MediaQuery.of(context).size.height *
              0.5, // Set a reasonable height
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
            // Update selected ingredients
            setState(() {
              selectedIngredients = selected;
            });
          },
        );
      },
    );
  }

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

    return showModalBottomSheet<Set<String>>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AllergyFilter(
          selectedAllergies: loadedAllergies,
          onSelectionChanged: (selected) {
            // Update selected ingredients
            setState(() {
              selectedAllergies = selected;
            });
          },
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Recipe Search',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Field
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Search',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
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
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12), // Better spacing
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
                        splashRadius: 22, // Better touch feedback
                        onPressed: () {
                          filterRecipes(
                              searchController.text, selectedCuisineType);
                        },
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.tune, color: Color(0xFF1F5F5B)),
                        splashRadius: 22,
                        onPressed: () {
                          openFilterSheet();
                        },
                      ),
                      hintText: 'Search food...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                    onFieldSubmitted: (query) {
                      filterRecipes(query, selectedCuisineType);
                    },
                  ),
                ),
              ),
            ],
          ),

          // Cuisine Type Filter Dropdown
          // Padding(
          //   padding: EdgeInsets.all(10),
          //   child: DropdownButton<String>(
          //     value: selectedCuisineType,
          //     onChanged: (String? newValue) {
          //       setState(() {
          //         selectedCuisineType = newValue!;
          //       });
          //       filterRecipes(searchController.text, selectedCuisineType);
          //     },
          //     items: <String>[
          //       'All',
          //       'Italian',
          //       'Chinese',
          //       'Indian',
          //       'Mexican',
          //       'American',
          //       'Japanese',
          //       'Asian',
          //       'Thai'
          //     ].map<DropdownMenuItem<String>>((String value) {
          //       return DropdownMenuItem<String>(
          //         value: value,
          //         child: Text(value),
          //       );
          //     }).toList(),
          //   ),
          // ),

          // Scroll List
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icons.tune,
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
                          print("Updated Calories: ${result['calories']}");
                          // TODO: Update UI with selected filters
                        }
                      } else if (icon == Icons.fastfood) {
                        double? result = await showCalorieFilterSheet(
                            context, _selectedCalories ?? 100);
                        if (result != null) {
                          print("Updated Calories: $result");
                          setState(() {
                            _selectedCalories =
                                result; // Update the calorie filter value
                            // Optionally, you can filter recipes based on the selected calories here
                          });
                        }
                      } else if (icon == Icons.category) {
                        // Open the category filter modal
                        Set<String>? result = await showCategoryFilterSheet(
                            context, selectedCategories);
                        if (result != null) {
                          setState(() {
                            // Update the selected categories
                            selectedCategories = result;
                          });
                          print("Selected Categories: $selectedCategories");
                        }
                      } else if (icon == Icons.kitchen) {
                        // Open the category filter modal
                        Set<String>? result = await showIngredientFilterSheet(
                            context, selectedIngredients);
                        if (result != null) {
                          setState(() {
                            // Update the selected categories
                            selectedIngredients = result;
                          });
                          print("Selected Categories: $selectedIngredients");
                        }
                      } else if (icon == Icons.warning) {
                        Set<String>? result = await showAllergyFilterSheet(
                            context, selectedAllergies);
                        if (result != null) {
                          setState(() {
                            selectedAllergies = result;
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
                          SizedBox(height: 5), // Add spacing
                          Text(
                            icon == Icons.tune
                                ? 'Edit'
                                : icon == Icons.category
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

          SizedBox(height: 10),

          // Recipe List
          Expanded(
            child: ListView.builder(
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                var recipe = filteredRecipes[index];
                String imagePath = 'assets/fetchMenu/' +
                    recipe['label'].replaceAll(' ', '_') +
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
                                  "${recipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt()} ${recipe['totalNutrients']['ENERC_KCAL']['unit']}",
                                ),
                              ],
                            ),
                            Text(recipe['source']),
                          ],
                        ),
                        onTap: () {
                          logRecipeClick(recipe['label'], recipe['shareAs']);

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
          ),
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
