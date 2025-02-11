import 'dart:ffi';
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

  late Future<List<FoodItem>?> _foodFuture; // Allow nullable list

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

  void _updateDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                // Search field
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
                          Text(
                            'Search',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (selectedTab == 'Search')
                            Container(
                              height: 3,
                              width: 80,
                              color: Colors.white,
                            ),
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
                          Text(
                            'Favorites',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (selectedTab == 'Favorites')
                            Container(
                              height: 3,
                              width: 95,
                              color: Colors.white,
                            ),
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
                          Flexible(
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.shopping_basket_outlined),
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      width: double.infinity,
                                      child: Text(
                                        'Search',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.list_alt),
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      width: double.infinity,
                                      child: Text(
                                        'Diary',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //
                    Container(
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.sizeOf(context).width,
                      height: 50,
                      color: Color(0xFF40C5BD),
                      child: Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text('Recently listed',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),

                    // Food Lists

                    //
                    // FutureBuilder<List<FoodItem>?>(
                    //     future: _foodFuture,
                    //     builder: (context, snapshot) {
                    //       if (snapshot.connectionState ==
                    //           ConnectionState.waiting) {
                    //         return Center(child: CircularProgressIndicator());
                    //       } else if (snapshot.hasError) {
                    //         return Center(
                    //             child: Text("Error: ${snapshot.error}"));
                    //       } else if (!snapshot.hasData ||
                    //           snapshot.data!.isEmpty) {
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
                    //                       'Cooking Technique',
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
                    //                       'Cooking Recipe',
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
                    //
                  ],
                )
              : Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(color: Colors.white, width: 2)),
                          color: Color(0xFF40C5BD)),
                      width: MediaQuery.sizeOf(context).width,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _updateDate(-1);
                            },
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy').format(selectedDate),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _updateDate(1);
                            },
                            child: Icon(Icons.arrow_forward_ios,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Image.asset(
                      'assets/images/error.png',
                      width: 200,
                    ),
                    SizedBox(height: 20),
                    Text('There are no food log today',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),

          //
        ],
      ),
    );
  }
}
