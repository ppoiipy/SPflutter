import 'package:flutter/material.dart';
import 'package:flutter_application_1/SQLite/sqlite.dart';
import 'package:flutter_application_1/JsonModels/menu_item.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {
  final List<MenuItem> menuItems = [
    MenuItem(
      name: 'Sous Vide City Ham With Balsamic',
      imagePath: 'assets/images/menu/sousvide.png',
      calories: 140,
    ),
    MenuItem(
      name: 'Grilled Chicken Salad',
      imagePath: 'assets/images/default.png',
      calories: 250,
    ),
    MenuItem(
      name: 'Vegetable Stir Fry',
      imagePath: 'assets/images/default.png',
      calories: 200,
    ),
    MenuItem(
      name: 'Pasta Primavera',
      imagePath: 'assets/images/default.png',
      calories: 300,
    ),
    MenuItem(
      name: 'Beef Tacos',
      imagePath: 'assets/images/default.png',
      calories: 350,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: 30),
          Container(
            child: AppBar(
              centerTitle: true,
              title: Text(
                'GinRaiDee',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
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
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: GestureDetector(
                        onTap: () {},
                        child: Icon(Icons.tune),
                      ),
                      hintText: 'Auto-Gen food name',
                      hintStyle: TextStyle(
                          color: const Color.fromARGB(255, 72, 72, 72)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Popular Categories
          SizedBox(height: 10),
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: Offset(20, 0),
                  child: Text(
                    'Popular Categories',
                    style: TextStyleBold.boldTextStyle(),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Scroll Lists
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Container(
                            width: 65,
                            height: 65,
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
                          Text(
                            'Food',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          // Function Lists
          FunctionList(),
          SizedBox(height: 10),

          // Display the menu items
          for (var item in menuItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
                              '${item.calories} Kcal',
                              style: TextStyle(fontSize: 14),
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
                              '${item.calories}',
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
                              '${item.calories}',
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
        ]),
      ),
    );
  }
}

class TextStyleBold {
  static TextStyle boldTextStyle() {
    return TextStyle(fontWeight: FontWeight.w800, fontSize: 16);
  }
}

class FunctionList extends StatefulWidget {
  const FunctionList({Key? key}) : super(key: key);

  @override
  FunctionListState createState() => FunctionListState();
}

class FunctionListState extends State<FunctionList> {
  final List<Map<String, dynamic>> functionItems = [
    {
      'icon': Icons.tune,
      'label': 'Settings',
      'description': 'Adjust app preferences',
    },
    {
      'label': 'Category',
      'description': 'Browse food categories',
    },
    {
      'label': 'Cooking Technique',
      'description': 'Explore cooking techniques',
    },
    {
      'label': 'Ingredients',
      'description': 'Find ingredients info',
    },
    {
      'label': 'Calories',
      'description': 'Check calorie intake',
    },
    {
      'label': 'Allergies',
      'description': 'Manage allergy preferences',
    },
  ];

  void _showCalorieBottomSheet(BuildContext context) {
    double _selectedCalories = 100;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Calories',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Calories: ${_selectedCalories.toStringAsFixed(0)} Kcal',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Slider(
                    value: _selectedCalories,
                    min: 0,
                    max: 1000,
                    divisions: 100,
                    label: _selectedCalories.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        _selectedCalories = value;
                      });
                    },
                    thumbColor: Color(0xFF1f5f5b),
                    activeColor: Color(0xFF1f5f5b),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Apply',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3fcc6e)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          functionItems.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (functionItems[index]['label'] == 'Calories') {
                      _showCalorieBottomSheet(context);
                    } else {
                      // Other actions for other options
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: functionItems[index]['icon'] != null
                          ? Icon(
                              functionItems[index]['icon'],
                              size: 24,
                              color: Colors.black,
                            )
                          : Text(
                              functionItems[index]['label'],
                              style:
                                  TextStyle(fontSize: 12, color: Colors.black),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
