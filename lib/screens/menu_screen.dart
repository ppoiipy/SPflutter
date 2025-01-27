import 'package:flutter/material.dart';
import 'package:flutter_application_1/SQLite/sqlite.dart';
import 'package:flutter_application_1/JsonModels/menu_item.dart';
import 'package:flutter_application_1/screens/food_detail_screen.dart';

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
                        onTap: () {
                          _showCalorieBottomSheet(context);
                        },
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

          // Display the menu items
          for (var item in menuItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodDetailScreen(menuItem: item),
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
        ]),
      ),
    );
  }

  void _showCalorieBottomSheet(BuildContext context) {
    double _selectedCalories = 100;
    List<String> ingredients = ['Broccoli', 'Broccoli', 'Broccoli', 'Butter'];
    List<String> cookingTechniques = [
      'Boiling',
      'Frying',
      'Baking',
      'Roasting',
      'Grilling',
      'Steaming',
      'Poaching',
      'Broiling',
      'ETC'
    ];
    Set<String> selectedCookingTechniques = {};
    List<String> foodAllergy = [
      'Egg',
      'Milk',
      'Fish',
      'Crustacean Shellfish',
      'Tree Nuts',
      'Sesame',
      'Wheat',
      'Soybeans'
    ];
    Set<String> selectedFoodAllergy = {};
    List<String> foodCategory = [
      'Italian',
      'Japanese',
      'Chinese',
      'Korean',
      'Thai'
    ];
    Set<String> selectedFoodCategory = {};

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: MediaQuery.sizeOf(context).width,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Filter',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Material(
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
                          hintText: 'Ingredient',
                          hintStyle: TextStyle(
                              color: const Color.fromARGB(255, 72, 72, 72)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 0,
                      children: List.generate(
                        ingredients.length,
                        (index) => Chip(
                          label: Text(ingredients[index]),
                          backgroundColor: Color(0xFF39C184).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Color(0xFF39C184).withOpacity(0.5),
                                  width: 1),
                              borderRadius: BorderRadius.circular(7)),
                          deleteIcon: Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              ingredients.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Calories
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Calories',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 5),
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
                    SizedBox(height: 10),

                    // Cooking Techniques
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Cooking Techniques',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 0,
                        children: List.generate(
                          cookingTechniques.length,
                          (index) {
                            String technique = cookingTechniques[index];
                            bool isSelected =
                                selectedCookingTechniques.contains(technique);
                            return ChoiceChip(
                              label: Text(technique),
                              selected: isSelected,
                              selectedColor: Color(0xFF39C184).withOpacity(0.5),
                              side: BorderSide(
                                color: isSelected
                                    ? Color(0xFF39C184).withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.4),
                                width: 1,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedCookingTechniques.add(technique);
                                  } else {
                                    selectedCookingTechniques.remove(technique);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Allergy
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Food Allergy',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 0,
                        children: List.generate(
                          foodAllergy.length,
                          (index) {
                            String allergy = foodAllergy[index];
                            bool isSelected =
                                selectedFoodAllergy.contains(allergy);

                            return ChoiceChip(
                              label: Text(allergy),
                              selected: isSelected,
                              selectedColor: Color(0xFF39C184).withOpacity(0.5),
                              side: BorderSide(
                                color: isSelected
                                    ? Color(0xFF39C184).withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.4),
                                width: 1,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedFoodAllergy.add(allergy);
                                  } else {
                                    selectedFoodAllergy.remove(allergy);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Category
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Category',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 0,
                        children: List.generate(
                          foodCategory.length,
                          (index) {
                            String category = foodCategory[index];
                            bool isSelected =
                                selectedFoodCategory.contains(category);

                            return ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              selectedColor: Color(0xFF39C184).withOpacity(0.5),
                              side: BorderSide(
                                color: isSelected
                                    ? Color(0xFF39C184).withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.4),
                                width: 1,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedFoodCategory.add(category);
                                  } else {
                                    selectedFoodCategory.remove(category);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Apply Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Reset',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              minimumSize: Size(120, 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7))),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Apply',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF3fcc6e),
                              minimumSize: Size(120, 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7))),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TextStyleBold {
  static TextStyle boldTextStyle() {
    return TextStyle(fontWeight: FontWeight.w800, fontSize: 16);
  }
}
