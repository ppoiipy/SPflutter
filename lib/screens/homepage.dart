import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/UserDataChartScreen.dart';
import 'package:flutter_application_1/screens/botton_nav_bar.dart';
import 'package:flutter_application_1/screens/food_detail_screen.dart';
import 'package:flutter_application_1/screens/nutrition_tracking_screen.dart';

import 'package:flutter_application_1/screens/menu_screen.dart';
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
  int _currentIndex = 0;
  int _selectedIndex = 0;
  List foodItems = [];
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFoodDataFromApi("chicken"); // Fetch default data on screen load
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
      body: Column(
        children: [
          // SizedBox(height: 30),
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
              // child: TextField(
              //   // controller: _searchController,
              //   controller: _ingredientController,
              //   // onFieldSubmitted: _filterFoodItems,
              //   onSubmitted: (_) {
              //     // Call _searchFood when the user submits the input
              //     _searchFood();
              //   },

              // ),

              child: TextField(
                controller: searchController,
                onSubmitted: (value) {
                  searchController.text.trim();
                },
                decoration: InputDecoration(
                  hintText: 'Enter ingredient',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  filled: true,
                  fillColor:
                      Colors.grey[250], // Same background color as homepage
                  prefixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      fetchFoodDataFromApi(searchController.text.trim());
                    },
                  ),
                  hintStyle: TextStyle(
                      color: Colors.grey[700]), // Match the homepage text style
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
                  // destinationScreen: CalorieTrackingScreen(),
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

          isLoading
              ? CircularProgressIndicator()
              : Expanded(
                  child: foodItems.isEmpty
                      ? Center(child: Text("No food found"))
                      : ListView.builder(
                          itemCount: foodItems.length,
                          itemBuilder: (context, index) {
                            var food = foodItems[index]['food'];
                            return ListTile(
                              leading: CachedNetworkImage(
                                imageUrl: food['image'] ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(), // Shows a loading spinner
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                  'assets/images/default.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(food['label'] ?? "Unknown"),
                              subtitle: Text(
                                  "Calories: ${food['nutrients']['ENERC_KCAL'] ?? 'N/A'} kcal"),
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   // MaterialPageRoute(
                                //   //   builder: (context) => RecipeDetailScreen(
                                //   //     recipe: food,
                                //   //   ),
                                //   // ),
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //         FoodDetailScreen(menuItem: food),
                                //   ),
                                // );
                              },
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
