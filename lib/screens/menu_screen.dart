import 'package:flutter/material.dart';
import 'package:flutter_application_1/SQLite/sqlite.dart';
import 'package:flutter_application_1/JsonModels/menu_item.dart';
import 'package:flutter_application_1/screens/food_detail_screen.dart';
import 'package:flutter_application_1/screens/recipe_detail_screen.dart';
import 'package:flutter_application_1/api/fetch_food_api.dart';
import 'package:flutter_application_1/api/fetch_recipe_api.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> {
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
          ingredient: "",
        ); // or set an empty list here if needed
      } else {
        _foodFuture = FoodApiService.fetchFoodData(
            ingredient: ""); // Pass the query to fetch data
      }
    });
  }

  double _maxCalories = 500; // Initial value for maximum calories
  List<FoodItem> _filteredFoods = [];

  // Function to fetch food data based on max calorie filter
  Future<List<FoodItem>?> _fetchFilteredFood() async {
    return await FoodApiService.fetchFoodData(
      ingredient: "chicken", // Example ingredient
      maxCalories: _maxCalories,
    );
  }

  // final List<MenuItem> menuItems = [
  //   MenuItem(
  //     name: 'Sous Vide City Ham With Balsamic',
  //     imagePath: 'assets/images/menu/sousvide.png',
  //     calories: 140,
  //     cookingTechnique: '',
  //     cookingRecipe: '',
  //   ),
  //   MenuItem(
  //     name: 'Grilled Chicken Salad',
  //     imagePath: 'assets/images/default.png',
  //     calories: 250,
  //     cookingTechnique: '',
  //     cookingRecipe: '',
  //   ),
  //   MenuItem(
  //     name: 'Vegetable Stir Fry',
  //     imagePath: 'assets/images/default.png',
  //     calories: 200,
  //     cookingTechnique: '',
  //     cookingRecipe: '',
  //   ),
  //   MenuItem(
  //     name: 'Pasta Primavera',
  //     imagePath: 'assets/images/default.png',
  //     calories: 300,
  //     cookingTechnique: '',
  //     cookingRecipe: '',
  //   ),
  //   MenuItem(
  //     name: 'Beef Tacos',
  //     imagePath: 'assets/images/default.png',
  //     calories: 350,
  //     cookingTechnique: '',
  //     cookingRecipe: '',
  //   ),
  // ];

  // recipe
  final TextEditingController _ingredientController = TextEditingController();
  // double? _maxCalories;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
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
                child: TextField(
                  controller: _ingredientController,
                  onSubmitted: (_) {
                    _searchFood();
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    filled: true,
                    fillColor: Colors.grey[250],
                    prefixIcon: GestureDetector(
                      onTap: () {
                        _filterFoodItems(_searchController.text);
                      },
                      child: Icon(Icons.search),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _showCalorieBottomSheet(context);
                      },
                      child: Icon(Icons.tune),
                    ),
                    hintText: 'Auto-Gen food name',
                    hintStyle:
                        TextStyle(color: const Color.fromARGB(255, 72, 72, 72)),
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
                children: [
                  Icons.tune,
                  Icons.category,
                  Icons.science,
                  Icons.kitchen,
                  Icons.warning,
                  Icons.fastfood
                ].map((icon) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(icon, size: 30, color: Colors.black),
                          ),
                        ),
                        Text(
                          icon == Icons.edit
                              ? 'Edit'
                              : icon == Icons.category
                                  ? 'Category'
                                  : icon == Icons.science
                                      ? 'Technique'
                                      : icon == Icons.kitchen
                                          ? 'Ingredients'
                                          : icon == Icons.warning
                                              ? 'Allergy'
                                              : 'Calories',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        // SizedBox(height: 10),
        // Slider(
        //   value: _maxCalories,
        //   min: 0,
        //   max: 1000,
        //   divisions: 100,
        //   label: _maxCalories.toStringAsFixed(0),
        //   onChanged: (value) {
        //     setState(() {
        //       _maxCalories = value;
        //     });
        //   },
        // ),
        // ElevatedButton(
        //   onPressed: _searchFood,
        //   child: Text("Filter Foods"),
        // ),

        // Expanded(
        //   child: _filteredFoods.isEmpty
        //       ? Center(child: CircularProgressIndicator())
        //       : ListView.builder(
        //           itemCount: _filteredFoods.length,
        //           itemBuilder: (context, index) {
        //             final food = _filteredFoods[index];
        //             return ListTile(
        //               title: Text(food.name),
        //               subtitle:
        //                   Text('Calories: ${food.calories.toStringAsFixed(0)}'),
        //               leading: Image.network(food.imageUrl),
        //             );
        //           },
        //         ),
        // ),

        // Expanded(
        //   child: FutureBuilder<List<FoodItem>?>(
        //     future: _fetchFilteredFood(), // Fetch filtered foods asynchronously
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return Center(
        //             child:
        //                 CircularProgressIndicator()); // Show loading indicator
        //       } else if (snapshot.hasError) {
        //         return Center(
        //             child:
        //                 Text("Error: ${snapshot.error}")); // Show error message
        //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        //         return Center(
        //             child:
        //                 Text("No food items found")); // Show message if no data
        //       }

        //       final foodItems = snapshot.data!;

        //       return ListView.builder(
        //         itemCount: foodItems.length,
        //         itemBuilder: (context, index) {
        //           final item = foodItems[index];
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
        //               crossAxisAlignment: CrossAxisAlignment.start,
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
        //                     menuItem: MenuItem(
        //                       name: item.name,
        //                       imagePath: item.imageUrl,
        //                       calories: item.calories,
        //                       cookingTechnique: item.cookingTechnique,
        //                       cookingRecipe: item.cookingRecipe,
        //                     ),
        //                   ),
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
                          // subtitle: Text(
                          //     "Calories: ${recipe.calories.toStringAsFixed(1)} kcal\nSource: ${recipe.source}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department_outlined,
                                    color: Colors.red,
                                    size: 17,
                                  ),
                                  Text("${recipe.calories.toInt()} Kcal"),
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
                                    // item.cookingTechnique,
                                    "",
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
                                    // recipe.cookingRecipe ?? "N/A",
                                    "",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
      ]),
    );
  }

  void _showCalorieBottomSheet(BuildContext context) {
    double _selectedCalories = 100;
    List<String> ingredients = ['Broccoli', 'Fish', 'Rice', 'Butter'];
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
      'American',
      'Asian',
      'British',
      'Caribbean',
      'Central Europe',
      'Chinese',
      'Eastern Europe',
      'French',
      'Indian',
      'Italian',
      'Japanese',
      'Kosher',
      'Mediterranean',
      'Mexican',
      'Middle Eastern',
      'Nordic',
      'South American',
      'South East Asian'
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
                        controller: _searchController,
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
                      // value: _selectedCalories,
                      value: _maxCalories,
                      min: 0,
                      max: 1000,
                      divisions: 100,
                      label: _maxCalories.toStringAsFixed(0),
                      // onChanged: (value) {
                      //   setState(() {
                      //     _selectedCalories = value;
                      //   });
                      // },
                      onChanged: (value) {
                        setState(() {
                          _maxCalories = value;
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
                          onPressed: () {
                            _fetchFilteredFood;
                            Navigator.pop(context);
                          },
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

  // //
  // void _showCategorySheet(BuildContext context) {}

  // //
  // void _showCookingTechniqueSheet(BuildContext context) {}

  // //
  // void _showCookingTechniqueSheet(BuildContext context) {}

  // //
  // void _showIngredientSheet(BuildContext context) {}

  // //
  // void _showCalorieSheet(BuildContext context) {}
}

class TextStyleBold {
  static TextStyle boldTextStyle() {
    return TextStyle(fontWeight: FontWeight.w800, fontSize: 16);
  }
}
