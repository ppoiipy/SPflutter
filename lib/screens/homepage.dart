import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/food_detail_screen.dart';
import 'menu_screen.dart';
import 'favorite_screen.dart';
import 'calculate_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_application_1/JsonModels/users.dart';
import 'package:flutter_application_1/JsonModels/menu_item.dart';
import 'calorie_tracking_screen.dart';
import 'meal_planning_screen.dart';

class Homepage extends StatefulWidget {
  final Users user;

  Homepage({required this.user});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  String loggedInEmail = "johndoe@example.com";

  // Sample list of menu items
  final List<MenuItem> menuItems = [
    MenuItem(
      name: 'Sous Vide City Ham With Balsamic',
      imagePath: 'assets/images/menu/sousvide.png',
      calories: 140,
      cookingTechnique: '',
      cookingRecipe: '',
    ),
    MenuItem(
      name: 'Grilled Chicken Salad',
      imagePath: 'assets/images/default.png',
      calories: 250,
      cookingTechnique: '',
      cookingRecipe: '',
    ),
    MenuItem(
      name: 'Vegetable Stir Fry',
      imagePath: 'assets/images/default.png',
      calories: 200,
      cookingTechnique: '',
      cookingRecipe: '',
    ),
    MenuItem(
      name: 'Pasta Primavera',
      imagePath: 'assets/images/default.png',
      calories: 300,
      cookingTechnique: '',
      cookingRecipe: '',
    ),
    MenuItem(
      name: 'Beef Tacos',
      imagePath: 'assets/images/default.png',
      calories: 350,
      cookingTechnique: '',
      cookingRecipe: '',
    ),
  ];

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
        return ProfileScreen(userEmail: loggedInEmail);
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
              Container(
                child: AppBar(
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
              ),

              // Search Field
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(20, -5),
                      child: Text(
                        'Search',
                        style: TextStyleBold.boldTextStyle(),
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
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          filled: true,
                          fillColor: Colors.grey[250],
                          suffixIcon: Icon(Icons.search),
                          hintText: 'Auto-Gen food name',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 72, 72, 72)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Function List
              SizedBox(height: 10),
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(20, 0),
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
                ],
              ),

              // Recommended Menu
              SizedBox(height: 10),
              Column(
                children: [
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

                  // Display the menu items
                  for (var item in menuItems)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FoodDetailScreen(menuItem: item),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: 80,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    item.imagePath,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.local_fire_department_outlined,
                                        color: Colors.red,
                                        size: 17,
                                      ),
                                      Text(
                                        '${item.calories} Kcal',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/skillet.png',
                                        color: Colors.yellow,
                                        width: 17,
                                      ),
                                      Text(
                                        '${item.cookingTechnique}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        color: Colors.blue,
                                        size: 17,
                                      ),
                                      Text(
                                        '${item.cookingRecipe}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
