import 'dart:convert';
import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/fetch_food_api.dart';
import 'package:flutter_application_1/JsonModels/menu_item.dart';
import 'package:flutter_application_1/screens/food_detail_screen.dart';

class MealPlanningNextScreen extends StatefulWidget {
  final String pageName;

  MealPlanningNextScreen({required this.pageName});

  @override
  MealPlanningNextScreenState createState() => MealPlanningNextScreenState();
}

class MealPlanningNextScreenState extends State<MealPlanningNextScreen> {
  String selectedTab = 'Search';
  DateTime selectedDate = DateTime.now();
  late Future<List<FoodItem>?> _foodFuture;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _favoriteRecipes = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchFoodData(); // Initially fetch food data
    _loadFavorites();
    loadJsonData();
  }

  // Fetch food data from the API (can be extended to include daily meals based on the date)
  void _fetchFoodData([String ingredient = ""]) {
    print("Fetching data for: $ingredient");
    setState(() {
      _foodFuture = FoodApiService.fetchFoodData(ingredient: "");
    });
  }

  // Load favorite recipes from Firestore
  Future<void> _loadFavorites() async {
    var user = _auth.currentUser;
    if (user == null) return;

    var snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    List<Map<String, dynamic>> favoriteRecipes = [];
    for (var doc in snapshot.docs) {
      favoriteRecipes.add(doc.data());
    }

    setState(() {
      _favoriteRecipes = favoriteRecipes;
    });
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
          ],
        ),
      ),
    );
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

  // Function to display a meal category (e.g., Breakfast, Lunch, Dinner)
  Widget _buildMealCategory(String category) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 4),
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
          // Example meal list for each category (you can replace with actual meal data)
          for (int i = 1; i < 4; i++)
            ListTile(
              title: Text('$category Meal $i'),
              subtitle: Text('Meal details here'),
              onTap: () {},
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top container with search and tabs
          Container(
            width: MediaQuery.sizeOf(context).width,
            height: 180,
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
                    backgroundColor: Colors.transparent,
                    centerTitle: true,
                    title: Text(
                      widget.pageName,
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
                        Navigator.pop(context);
                      },
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.calendar_today_outlined,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    style: TextStyle(color: Colors.white),
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
                    // onChanged: _filterFoodItems,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
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
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedTab = 'Diary';
                        });
                      },
                      child: Column(
                        children: [
                          Text('Diary',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500)),
                          if (selectedTab == 'Diary')
                            Container(
                                height: 3, width: 80, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          selectedTab == 'Search'
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Wrapping ListView.builder with Expanded
                          Expanded(
                            child: SingleChildScrollView(
                              // Wrapping in SingleChildScrollView for better scrolling behavior
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap:
                                        true, // This tells the ListView to take as much space as it needs
                                    physics:
                                        NeverScrollableScrollPhysics(), // Disable internal scroll
                                    itemCount: filteredRecipes.length < 3
                                        ? filteredRecipes.length
                                        : 3, // Show only 3 items
                                    itemBuilder: (context, index) {
                                      var recipe = filteredRecipes[index];
                                      String imagePath = 'assets/fetchMenu/' +
                                          recipe['label'].replaceAll(' ', '_') +
                                          '.jpg';

                                      return ListTile(
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
                                                    "${recipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt().toString()} ${recipe['totalNutrients']['ENERC_KCAL']['unit']}"),
                                              ],
                                            ),
                                            Text(recipe['source'])
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FoodDetailScreen(
                                                      recipe: recipe),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Other UI elements for the search tab
                  ],
                )
              : selectedTab == 'Favorites'
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: _favoriteRecipes.length,
                        itemBuilder: (context, index) {
                          var recipe = _favoriteRecipes[index];
                          return ListTile(
                            leading: recipe['imageUrl'] != null
                                ? Image.network(recipe['imageUrl'],
                                    width: 50, height: 50)
                                : Icon(Icons.image, size: 50),
                            title: Text(recipe['label'] ?? 'Unknown Recipe'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FoodDetailScreen(recipe: recipe),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  : _buildMealPlans(), // Show diary meals when Diary tab is selected
        ],
      ),
    );
  }
}
