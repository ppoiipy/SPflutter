import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/food_detail_screen.dart';
import 'package:flutter_application_1/screens/recipe_detail_screen.dart';

import 'menu_screen.dart';
import 'favorite_screen.dart';
import 'calculate_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_application_1/JsonModels/users.dart';
import 'package:flutter_application_1/JsonModels/menu_item.dart';
import 'calorie_tracking_screen.dart';
import 'meal_planning_screen.dart';
import 'package:flutter_application_1/api/fetch_food_api.dart';
import 'package:flutter_application_1/api/fetch_recipe_api.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  String loggedInEmail = "johndoe@example.com";

  late Future<List<FoodItem>?> _foodFuture; // Allow nullable list

  // List<FoodItem> _filteredFoodItems = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFoodData(); // Initially fetch with default ingredient
  }

  // Fetch food data from the API with the provided ingredient
  void _fetchFoodData([String ingredient = ""]) {
    print(
        "Fetching data for: $ingredient"); // Debugging: Check what ingredient is being used
    setState(() {
      _foodFuture = FoodApiService.fetchFoodData(ingredient: "");
    });
  }

  // Called when the search field value changes
  void _filterFoodItems(String query) {
    print("Searching for: $query"); // Debugging query
    setState(() {
      if (query.isEmpty) {
        // Clear the food data by calling the fetch with a default ingredient
        _foodFuture = FoodApiService.fetchFoodData(
            ingredient: ""); // or set an empty list here if needed
      } else {
        _foodFuture = FoodApiService.fetchFoodData(
            ingredient: ""); // Pass the query to fetch data
      }
    });
  }

  final TextEditingController _ingredientController = TextEditingController();
  double? _maxCalories;
  List<String> _selectedAllergies = [];
  bool _isVegetarian = false;
  bool _isGlutenFree = false;
  List<RecipeItem>? _foodResults;
  bool _isLoading = false;

  // recipe
  void _searchFood() async {
    setState(() => _isLoading = true);

    String ingredient = _ingredientController.text.trim();
    if (ingredient.isEmpty) {
      print('Ingredient is empty');
      return;
    }

    // Fetch recipes with additional filter parameters
    List<RecipeItem>? results = await RecipeApiService.fetchRecipes(
      ingredient: ingredient,
      maxCalories: _maxCalories,
      isVegetarian: _isVegetarian,
      isGlutenFree: _isGlutenFree,
      selectedAllergies: _selectedAllergies,
    );

    setState(() {
      _foodResults = results;
      _isLoading = false;
    });
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return MenuScreen();
      case 2:
        return FavoriteScreen();
      case 3:
        return CalculateScreen();
      case 4:
        return ProfileScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'GinRaiDee',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 30),
          // Search Field
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
              child: TextField(
                // controller: _searchController,
                controller: _ingredientController,
                // onFieldSubmitted: _filterFoodItems,
                onSubmitted: (_) {
                  // Call _searchFood when the user submits the input
                  _searchFood();
                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  filled: true,
                  fillColor: Colors.grey[250],
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search),
                    // onPressed: () => _filterFoodItems(_searchController.text),
                    onPressed: _searchFood,
                  ),
                  hintText: 'Enter food name',
                  hintStyle: TextStyle(color: Colors.grey[700]),
                ),
              ),
            ),
          ),

          // Function List
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Function List',
                style: TextStyleBold.boldTextStyle(),
              ),
            ),
          ),
          SizedBox(height: 5),
          // Scroll Lists
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
                  imagePath: 'assets/images/mealPlanning.png',
                  functionName: 'Meal Planning',
                  destinationScreen: MealPlanningScreen(),
                ),
              ],
            ),
          ),

          // Recommended Menu
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recommended Menu🔥',
                style: TextStyleBold.boldTextStyle(),
              ),
            ),
          ),

          // Expanded(
          //   child: FutureBuilder<List<FoodItem>?>(
          //     future: _foodFuture,
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return Center(child: CircularProgressIndicator());
          //       } else if (snapshot.hasError) {
          //         return Center(child: Text("Error: ${snapshot.error}"));
          //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //         return Center(child: Text("No food items found"));
          //       }

          //       return ListView.builder(
          //         itemCount: snapshot.data!.length,
          //         itemBuilder: (context, index) {
          //           final item = snapshot.data![index];
          //           return ListTile(
          //             leading: Image.network(
          //               item.imageUrl.isNotEmpty
          //                   ? item.imageUrl
          //                   : 'assets/images/default.png',
          //               width: 60,
          //               height: 60,
          //               errorBuilder: (context, error, stackTrace) {
          //                 return Image.asset(
          //                   'assets/images/default.png',
          //                   width: 60,
          //                   height: 60,
          //                   fit: BoxFit.cover,
          //                 );
          //               },
          //               fit: BoxFit.cover,
          //             ),
          //             title: Text(item.name),
          //             subtitle: Column(
          //               children: [
          //                 Row(
          //                   children: [
          //                     Icon(
          //                       Icons.local_fire_department_outlined,
          //                       color: Colors.red,
          //                       size: 17,
          //                     ),
          //                     Text("${item.calories.toInt()} Kcal"),
          //                   ],
          //                 ),
          //                 Row(
          //                   children: [
          //                     Image.asset(
          //                       'assets/images/skillet.png',
          //                       color: Colors.yellow,
          //                       width: 17,
          //                     ),
          //                     Text(
          //                       item.cookingTechnique,
          //                       style: TextStyle(fontSize: 14),
          //                     ),
          //                   ],
          //                 ),
          //                 Row(
          //                   children: [
          //                     Icon(
          //                       Icons.receipt_long_outlined,
          //                       color: Colors.blue,
          //                       size: 17,
          //                     ),
          //                     Text(
          //                       item.cookingRecipe,
          //                       style: TextStyle(fontSize: 14),
          //                     ),
          //                   ],
          //                 ),
          //               ],
          //             ),
          //             onTap: () {
          //               Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                   builder: (context) => FoodDetailScreen(
          //                       menuItem: MenuItem(
          //                     name: item.name,
          //                     imagePath: item.imageUrl,
          //                     calories: item.calories,
          //                     cookingTechnique: item.cookingTechnique,
          //                     cookingRecipe: item.cookingRecipe,
          //                   )),
          //                 ),
          //               );
          //             },
          //           );
          //         },
          //       );
          //     },
          //   ),
          // ),
          Expanded(
            child: _foodResults == null
                ? Center(child: Text("No results yet"))
                : _foodResults!.isEmpty
                    ? Center(child: Text("No matching recipes found"))
                    : ListView.builder(
                        itemCount: _foodResults!.length,
                        itemBuilder: (context, index) {
                          final recipe = _foodResults![index];
                          return ListTile(
                            leading: Image.network(recipe.imageUrl,
                                width: 50, height: 50, fit: BoxFit.cover),
                            title: Text(recipe.name),
                            subtitle: Text(
                                "Calories: ${recipe.calories.toStringAsFixed(1)} kcal\nSource: ${recipe.source}"),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              // Navigate to the RecipeDetailScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecipeDetailScreen(recipe: recipe),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        indicatorColor: Color(0xff4D7881),
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                color: Colors.black,
                size: 30,
              ),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(
                Icons.food_bank_outlined,
                color: Colors.black,
                size: 30,
              ),
              label: 'Menu'),
          NavigationDestination(
              icon: Icon(
                Icons.favorite_outline,
                color: Colors.black,
                size: 30,
              ),
              label: 'Favorites'),
          NavigationDestination(
              icon: Icon(
                Icons.calculate_outlined,
                color: Colors.black,
                size: 30,
              ),
              label: 'Calculate'),
          NavigationDestination(
              icon: Icon(
                Icons.person_outline,
                color: Colors.black,
                size: 30,
              ),
              label: 'Profile'),
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
          width: 200,
          height: 140,
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

// import 'package:flutter/material.dart';
// import 'firestore.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   final Firestore firestoreService = Firestore();

//   final TextEditingController textController = TextEditingController();

//   void openUserBox() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         content: TextField(
//           controller: textController,
//         ),
//         actions: [
//           ElevatedButton(
//               onPressed: () {
//                 firestoreService.addNote(textController.text);

//                 textController.clear();

//                 Navigator.pop(context);
//               },
//               child: Text('Add'))
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notes'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: openUserBox,
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
