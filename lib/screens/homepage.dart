import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ginraidee/screens/UserDataChartScreen.dart';
import 'package:ginraidee/screens/food_detail_screen.dart';
import 'package:ginraidee/screens/nutrition_tracking_screen.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:intl/intl.dart';

import 'package:ginraidee/screens/menu_screen.dart';
import 'favorite_screen.dart';
import 'calculate_screen.dart';
import 'profile_screen.dart';
import 'calorie_tracking_screen.dart';
import 'meal_planning_screen.dart';

// import 'package:flutter_application_1/api/fetch_food_api.dart';
import 'fetch_food_data.dart';

// Get DB Path
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentIndex = 0;
  int _selectedIndex = 0;
  List foodItems = [];
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();

  List<dynamic> recipes = [];
  List<dynamic> filteredRecipes = [];

  String selectedCuisineType = "All";

  @override
  void initState() {
    super.initState();
    fetchFoodDataFromApi("chicken");
    loadJsonData();
  }

  String formatNumber(int number) {
    return NumberFormat("#,###").format(number);
  }

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

  Future<void> fetchFoodDataFromApi(String query) async {
    setState(() {
      isLoading = true;
    });

    // Call the function that fetches food data
    List<dynamic> fetchedFoodItems = await fetchFoodData(query);

    setState(() {
      foodItems = fetchedFoodItems;
      isLoading = false;
    });

    print("Fetched ${foodItems.length} items.");
  }

  // Click
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

  // final List<Widget> _pages = [
  //   Homepage(),
  //   FavoriteScreen(),
  //   ProfileScreen(),
  // ];

  // Widget _getScreen(int index) {
  //   switch (index) {
  //     case 0:
  //       return _buildHomeScreen();
  //     case 1:
  //       return MenuScreen();
  //     case 2:
  //       return FavoriteScreen();
  //     case 3:
  //       return CalculateScreen();
  //     case 4:
  //       return ProfileScreen();
  //     default:
  //       return _buildHomeScreen();
  //   }
  // }

  // Widget _buildHomeScreen() {
  //   return Scaffold(
  //     appBar: AppBar(
  //       centerTitle: true,
  //       title: Text(
  //         'GinRaiDee',
  //         style: TextStyle(
  //           fontWeight: FontWeight.w600,
  //           fontFamily: 'Inter',
  //           letterSpacing: 1,
  //         ),
  //       ),
  //     ),
  //     body: Column(
  //       children: [
  //         SizedBox(height: 30),
  //         // Search Field
  //         Padding(
  //           padding: const EdgeInsets.only(left: 20, bottom: 5),
  //           child: Align(
  //             alignment: Alignment.centerLeft,
  //             child: Text(
  //               'Search',
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 18,
  //               ),
  //             ),
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 15),
  //           child: Material(
  //             borderRadius: BorderRadius.circular(15),
  //             elevation: 4,
  //             shadowColor: Colors.black,
  //             // child: TextField(
  //             //   // controller: _searchController,
  //             //   controller: _ingredientController,
  //             //   // onFieldSubmitted: _filterFoodItems,
  //             //   onSubmitted: (_) {
  //             //     // Call _searchFood when the user submits the input
  //             //     _searchFood();
  //             //   },

  //             // ),

  //             child: TextField(
  //               controller: searchController,
  //               onSubmitted: (value) {
  //                 searchController.text.trim();
  //               },
  //               decoration: InputDecoration(
  //                 hintText: 'Enter ingredient',
  //                 enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(15),
  //                   borderSide: BorderSide(color: Colors.transparent),
  //                 ),
  //                 filled: true,
  //                 fillColor:
  //                     Colors.grey[250], // Same background color as homepage
  //                 prefixIcon: IconButton(
  //                   icon: Icon(Icons.search),
  //                   onPressed: () {
  //                     fetchFoodDataFromApi(searchController.text.trim());
  //                   },
  //                 ),
  //                 hintStyle: TextStyle(
  //                     color: Colors.grey[700]), // Match the homepage text style
  //               ),
  //             ),
  //           ),
  //         ),

  //         // Function List
  //         SizedBox(height: 10),
  //         Padding(
  //           padding: const EdgeInsets.only(left: 20, bottom: 5),
  //           child: Align(
  //             alignment: Alignment.centerLeft,
  //             child: Text(
  //               'Function List',
  //               style: TextStyleBold.boldTextStyle(),
  //             ),
  //           ),
  //         ),
  //         SizedBox(height: 5),
  //         // Scroll Lists
  //         SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           child: Row(
  //             children: [
  //               FunctionCard(
  //                 imagePath: 'assets/images/calorieTracking.png',
  //                 functionName: 'Calorie Tracking',
  //                 destinationScreen: CalorieTrackingScreen(),
  //               ),
  //               FunctionCard(
  //                 imagePath: 'assets/images/calorieTracking.png',
  //                 functionName: 'Nutrition Tracking',
  //                 destinationScreen: NutritionScreen(),
  //               ),
  //               FunctionCard(
  //                 imagePath: 'assets/images/mealPlanning.png',
  //                 functionName: 'Meal Planning',
  //                 destinationScreen: MealPlanningScreen(),
  //               ),
  //             ],
  //           ),
  //         ),

  //         // Recommended Menu
  //         SizedBox(height: 10),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 20),
  //           child: Align(
  //             alignment: Alignment.centerLeft,
  //             child: Text(
  //               'Recommended Menu🔥',
  //               style: TextStyleBold.boldTextStyle(),
  //             ),
  //           ),
  //         ),

  //         isLoading
  //             ? CircularProgressIndicator()
  //             : Expanded(
  //                 child: foodItems.isEmpty
  //                     ? Center(child: Text("No food found"))
  //                     : ListView.builder(
  //                         itemCount: foodItems.length,
  //                         itemBuilder: (context, index) {
  //                           var food = foodItems[index]['food'];
  //                           return ListTile(
  //                             leading: CachedNetworkImage(
  //                               imageUrl: food['image'] ?? '',
  //                               width: 50,
  //                               height: 50,
  //                               fit: BoxFit.cover,
  //                               placeholder: (context, url) =>
  //                                   CircularProgressIndicator(), // Shows a loading spinner
  //                               errorWidget: (context, url, error) =>
  //                                   Image.asset(
  //                                 'assets/images/default.png',
  //                                 width: 50,
  //                                 height: 50,
  //                                 fit: BoxFit.cover,
  //                               ),
  //                             ),
  //                             title: Text(food['label'] ?? "Unknown"),
  //                             subtitle: Text(
  //                                 "Calories: ${food['nutrients']['ENERC_KCAL'] ?? 'N/A'} kcal"),
  //                             onTap: () {
  //                               // Navigator.push(
  //                               //   context,
  //                               //   // MaterialPageRoute(
  //                               //   //   builder: (context) => RecipeDetailScreen(
  //                               //   //     recipe: food,
  //                               //   //   ),
  //                               //   // ),
  //                               //   MaterialPageRoute(
  //                               //     builder: (context) =>
  //                               //         FoodDetailScreen(menuItem: food),
  //                               //   ),
  //                               // );
  //                             },
  //                           );
  //                         },
  //                       ),
  //               ),
  //       ],
  //     ),
  //   );
  // }

  void _refreshFavorites() {}

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: Scaffold(
    //     body: _getScreen(_selectedIndex),
    //     bottomNavigationBar: NavigationBar(
    //       selectedIndex: _selectedIndex,
    //       indicatorColor: Color(0xff4D7881),
    //       onDestinationSelected: (int index) {
    //         setState(() {
    //           _selectedIndex = index;
    //         });
    //       },
    //       destinations: [
    //         NavigationDestination(
    //             icon: Icon(
    //               Icons.home_outlined,
    //               color: Colors.black,
    //               size: 30,
    //             ),
    //             label: 'Home'),
    //         NavigationDestination(
    //             icon: Icon(
    //               Icons.food_bank_outlined,
    //               color: Colors.black,
    //               size: 30,
    //             ),
    //             label: 'Menu'),
    //         NavigationDestination(
    //             icon: Icon(
    //               Icons.favorite_outline,
    //               color: Colors.black,
    //               size: 30,
    //             ),
    //             label: 'Favorites'),
    //         NavigationDestination(
    //             icon: Icon(
    //               Icons.calculate_outlined,
    //               color: Colors.black,
    //               size: 30,
    //             ),
    //             label: 'Calculate'),
    //         NavigationDestination(
    //             icon: Icon(
    //               Icons.person_outline,
    //               color: Colors.black,
    //               size: 30,
    //             ),
    //             label: 'Profile'),
    //       ],
    //     ),
    //   ),
    // );

    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: Scaffold(
    //       // body: BottomNavBar(),
    //       ),
    // );

    // return MaterialApp(
    //   builder: (context, child) => BottomNavBar(),
    // );

    // return _buildHomeScreen();
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
            SingleChildScrollView(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Recommended Menu🔥',
                style: TextStyleBold.boldTextStyle(),
              ),
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    shrinkWrap: true,
                    physics:
                        NeverScrollableScrollPhysics(), // Prevent nested scrolling
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
                                errorBuilder: (context, error, stackTrace) {
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
                                      Icon(Icons.local_fire_department_outlined,
                                          color: Colors.red),
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
                                    recipe['label'], recipe['shareAs']);
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
                            top: 5,
                            right: 5,
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
          ],
        ),
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

class FunctionCard extends StatelessWidget {
  final String imagePath;
  final String functionName;
  final Widget destinationScreen;

  FunctionCard(
      {required this.imagePath,
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

              // Display the search results
              // Inside the FunctionCard widget, inside the ListView.builder:
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
