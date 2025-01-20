import 'package:flutter/material.dart';
import 'menu_screen.dart';
import 'favorite_screen.dart';
import 'calculate_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_application_1/JsonModels/users.dart';
import 'package:flutter_application_1/JsonModels/menu_item.dart'; // Import the MenuItem model

class Homepage extends StatefulWidget {
  final Users user; // Add user parameter

  Homepage({required this.user}); // Constructor to accept user

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  // Sample list of menu items
  final List<MenuItem> menuItems = [
    MenuItem(
        name: 'Sous Vide City Ham With Balsamic',
        imagePath: 'assets/images/menu/sousvide.png',
        calories: 140),
    MenuItem(
        name: 'Grilled Chicken Salad',
        imagePath: 'assets/images/menu/chicken_salad.png',
        calories: 250),
    MenuItem(
        name: 'Vegetable Stir Fry',
        imagePath: 'assets/images/menu/stir_fry.png',
        calories: 200),
    MenuItem(
        name: 'Pasta Primavera',
        imagePath: 'assets/images/menu/pasta_primavera.png',
        calories: 300),
    MenuItem(
        name: 'Beef Tacos',
        imagePath: 'assets/images/menu/beef_tacos.png',
        calories: 350),
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
        return ProfileScreen(); // Pass user to ProfileScreen
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
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
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
                    padding: const EdgeInsets.only(left: 12, right: 12),
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
                  // Scroll Lists
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        5,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            width: 220,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Function ${index + 1}',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                  for (var item in menuItems) // Loop through the menu items
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: Container(
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
                                  item.imagePath, // Use the image path from the menu item
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name, // Use the name from the menu item
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department_outlined,
                                      color: Colors.red,
                                      size: 17,
                                    ),
                                    Text(
                                      '${item.calories} Kcal', // Use the calorie count from the menu item
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department_outlined,
                                      color: Colors.yellow,
                                      size: 17,
                                    ),
                                    Text(
                                      '${item.calories} Kcal', // Use the calorie count from the menu item
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department_outlined,
                                      color: Colors.blue,
                                      size: 17,
                                    ),
                                    Text(
                                      '${item.calories} Kcal', // Use the calorie count from the menu item
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
                icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.food_bank_outlined), label: 'Menu'),
            NavigationDestination(
                icon: Icon(Icons.favorite_outline), label: 'Favorites'),
            NavigationDestination(
                icon: Icon(Icons.calculate_outlined), label: 'Calculate'),
            NavigationDestination(
                icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
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
