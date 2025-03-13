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
  Set<String> selectedTechniques = {};
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
                      .contains(cuisineType.toLowerCase())))
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
      isScrollControlled: true,
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
      BuildContext context, Set<String> selectedCategories) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TechniqueFilter(
          selectedTechniques: selectedTechniques,
          onSelectionChanged: (Set<String> updatedTechniques) {
            setState(() {
              selectedTechniques = updatedTechniques;
            });
          },
        );
      },
    );
  }

  Future<Set<String>?> showTechniqueFilterSheet(
      BuildContext context, Set<String> selectedTechniques) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return TechniqueFilter(
          selectedTechniques: selectedTechniques,
          onSelectionChanged: (selected) {
            Navigator.pop(context, selected);
          },
        );
      },
    );
  }

  Future<Set<String>?> showIngredientFilterSheet(
      BuildContext context, Set<String> selectedIngredients) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return IngredientFilter(
          selectedIngredients: selectedIngredients,
          onSelectionChanged: (selected) {
            Navigator.pop(context, selected);
          },
        );
      },
    );
  }

  Future<Set<String>?> showAllergyFilterSheet(
      BuildContext context, Set<String> selectedAllergies) {
    return showModalBottomSheet<Set<String>>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return AllergyFilter(
          selectedAllergies: selectedAllergies,
          onSelectionChanged: (selected) {
            Navigator.pop(context, selected);
          },
        );
      },
    );
  }

// // Open Technique Filter
//   Future<String?> showTechniqueFilterSheet(BuildContext context) {
//     return showModalBottomSheet<String>(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       isScrollControlled: true,
//       builder: (context) {
//         return TechniqueFilterSheet(
//           onTechniqueChanged: (technique) {
//             Navigator.pop(context, technique);
//           },
//         );
//       },
//     );
//   }

// // Open Ingredients Filter
//   Future<String?> showIngredientsFilterSheet(BuildContext context) {
//     return showModalBottomSheet<String>(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       isScrollControlled: true,
//       builder: (context) {
//         return IngredientsFilterSheet(
//           onIngredientsChanged: (ingredients) {
//             Navigator.pop(context, ingredients);
//           },
//         );
//       },
//     );
//   }

// // Open Allergy Filter
//   Future<String?> showAllergyFilterSheet(BuildContext context) {
//     return showModalBottomSheet<String>(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       isScrollControlled: true,
//       builder: (context) {
//         return AllergyFilterSheet(
//           onAllergyChanged: (allergy) {
//             Navigator.pop(context, allergy);
//           },
//         );
//       },
//     );
//   }

//   Future<void> _showCalorieBottomSheet(BuildContext context) async {
//     double? selectedCalories =
//         await showCalorieFilterSheet(context, _selectedCalories ?? 100);
//     if (selectedCalories != null) {
//       setState(() {
//         _selectedCalories = selectedCalories; // Update the selected calories
//         // Optionally, filter the recipes based on the selected calories here
//       });
//     }
//   }

//   Future<void> _showCategoryFilter(BuildContext context) async {
//     String? selectedCategory = await showCategoryFilterSheet(context);
//     if (selectedCategory != null) {
//       print("Selected Category: $selectedCategory");
//     }
//   }

//   Future<void> _showTechniqueFilter(BuildContext context) async {
//     String? selectedTechnique = await showTechniqueFilterSheet(context);
//     if (selectedTechnique != null) {
//       print("Selected Technique: $selectedTechnique");
//     }
//   }

//   Future<void> _showIngredientsFilter(BuildContext context) async {
//     String? selectedIngredients = await showIngredientsFilterSheet(context);
//     if (selectedIngredients != null) {
//       print("Selected Ingredients: $selectedIngredients");
//     }
//   }

//   Future<void> _showAllergyFilter(BuildContext context) async {
//     String? selectedAllergy = await showAllergyFilterSheet(context);
//     if (selectedAllergy != null) {
//       print("Selected Allergy: $selectedAllergy");
//     }
//   }

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
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Material(
                  borderRadius: BorderRadius.circular(15),
                  elevation: 4,
                  shadowColor: Colors.black,
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      filled: true,
                      fillColor: Colors.grey[250],
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          filterRecipes(
                              searchController.text, selectedCuisineType);
                        },
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          // _showCalorieBottomSheet(context);
                          openFilterSheet();
                        },
                        child: Icon(Icons.tune),
                      ),
                      hintText: 'Auto-Gen food name',
                      hintStyle: TextStyle(
                          color: const Color.fromARGB(255, 72, 72, 72)),
                    ),
                    // onChanged: (query) {
                    //   filterRecipes(query, selectedCuisineType);
                    // },
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
                  Icons.category,
                  Icons.science,
                  Icons.kitchen,
                  Icons.warning,
                  Icons.fastfood,
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
                      } else if (icon == Icons.science) {
                        Set<String>? result = await showTechniqueFilterSheet(
                            context, selectedTechniques);
                        if (result != null) {
                          setState(() {
                            selectedTechniques = result;
                          });
                          print("Selected Techniques: $selectedTechniques");
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
                      //  else if (icon == Icons.science) {
                      //   // Open technique filter modal
                      //   await _showTechniqueFilter(context);
                      // } else if (icon == Icons.kitchen) {
                      //   // Open ingredients filter modal
                      //   await _showIngredientsFilter(context);
                      // } else if (icon == Icons.warning) {
                      //   // Open allergy filter modal
                      //   await _showAllergyFilter(context);
                      // }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(icon, size: 30, color: Colors.black),
                            ),
                          ),
                          Text(
                            icon == Icons.tune
                                ? 'Edit'
                                : icon == Icons.category
                                    ? 'Category'
                                    : icon == Icons.science
                                        ? 'Technique'
                                        : icon == Icons.kitchen
                                            ? 'Ingredients'
                                            : icon == Icons.warning
                                                ? 'Allergy'
                                                : 'Calories',
                            style: TextStyle(fontSize: 12),
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
