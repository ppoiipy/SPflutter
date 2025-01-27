import 'package:flutter/material.dart';
import 'package:flutter_application_1/SQLite/sqlite.dart';
import 'package:flutter_application_1/JsonModels/menu_item.dart';
import 'package:flutter_application_1/screens/food_detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
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
    MenuItem(
      name: 'Sous Vide City Ham With Balsamic',
      imagePath: 'assets/images/default.png',
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
                'Your Favourite Cuisine ♥',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
            ),
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
                      Stack(children: [
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
                        Transform.translate(
                          offset: Offset(-12, -12),
                          child: Icon(Icons.star_rate_rounded,
                              color: const Color.fromARGB(255, 255, 191, 0),
                              size: 31),
                        ),
                      ]),
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
}
