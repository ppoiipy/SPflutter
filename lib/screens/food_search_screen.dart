// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_application_1/api/fetch_recipe_api.dart';
// import 'recipe_detail_screen.dart'; // Import the new screen

// class FoodSearchScreen extends StatefulWidget {
//   @override
//   _FoodSearchScreenState createState() => _FoodSearchScreenState();
// }

// class _FoodSearchScreenState extends State<FoodSearchScreen> {
//   final TextEditingController _ingredientController = TextEditingController();
//   double? _maxCalories;
//   List<String> _selectedAllergies = [];
//   List<RecipeItem>? _foodResults;
//   bool _isLoading = false;

//   final List<String> allergens = [
//     "Gluten",
//     "Dairy",
//     "Peanuts",
//     "Shellfish",
//     "Eggs",
//     "Soy",
//   ];

//   void _searchFood() async {
//     setState(() => _isLoading = true);

//     String ingredient = _ingredientController.text.trim();
//     if (ingredient.isEmpty) {
//       print('Ingredient is empty');
//       return;
//     }

//     List<RecipeItem>? results = await RecipeApiService.fetchRecipes(
//       ingredient: ingredient,
//       maxCalories: null, // Test without maxCalories
//     );

//     setState(() {
//       _foodResults = results;
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Food Search")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _ingredientController,
//               decoration: InputDecoration(
//                 labelText: "Enter Ingredient (e.g., pork, chicken)",
//                 border: OutlineInputBorder(),
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: _searchFood,
//                 ),
//               ),
//             ),
//             SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: _searchFood,
//               child: Text("Search"),
//             ),
//             SizedBox(height: 16),
//             _isLoading
//                 ? CircularProgressIndicator()
//                 : Expanded(
//                     child: _foodResults == null
//                         ? Center(child: Text("No results yet"))
//                         : _foodResults!.isEmpty
//                             ? Center(child: Text("No matching recipes found"))
//                             : ListView.builder(
//                                 itemCount: _foodResults!.length,
//                                 itemBuilder: (context, index) {
//                                   final recipe = _foodResults![index];
//                                   return ListTile(
//                                     leading: Image.network(recipe.imageUrl,
//                                         width: 50,
//                                         height: 50,
//                                         fit: BoxFit.cover),
//                                     title: Text(recipe.name),
//                                     subtitle: Text(
//                                         "Calories: ${recipe.calories.toStringAsFixed(1)} kcal\nSource: ${recipe.source}"),
//                                     trailing: Icon(Icons.arrow_forward),
//                                     onTap: () {
//                                       // Navigate to the RecipeDetailScreen
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               RecipeDetailScreen(
//                                                   recipe: recipe),
//                                         ),
//                                       );
//                                     },
//                                   );
//                                 },
//                               ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application_1/api/fetch_recipe_api.dart';
import 'recipe_detail_screen.dart'; // Import the new screen

class FoodSearchScreen extends StatefulWidget {
  @override
  _FoodSearchScreenState createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  double? _maxCalories;
  List<String> _selectedAllergies = [];
  bool _isVegetarian = false;
  bool _isGlutenFree = false;
  List<RecipeItem>? _foodResults;
  bool _isLoading = false;

  final List<String> allergens = [
    "Gluten",
    "Dairy",
    "Peanuts",
    "Shellfish",
    "Eggs",
    "Soy",
  ];

  // Search function with filters
  void _searchFood() async {
    setState(() => _isLoading = true);

    String ingredient = _ingredientController.text.trim();
    if (ingredient.isEmpty) {
      print('Ingredient is empty');
      return;
    }

    // Fetch recipes with additional filter parameters
    List<RecipeItem>? results = await RecipeApiService.fetchRecipes(
      // ingredient: ingredient,
      // maxCalories: _maxCalories,
      // isVegetarian: _isVegetarian,
      // isGlutenFree: _isGlutenFree,
      // selectedAllergies: _selectedAllergies,
      query: ingredient,
      maxCalories: _maxCalories,
    );

    setState(() {
      _foodResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Food Search")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ingredientController,
              decoration: InputDecoration(
                labelText: "Enter Ingredient (e.g., pork, chicken)",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchFood,
                ),
              ),
            ),
            SizedBox(height: 12),

            // Filters Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Vegetarian filter
                FilterChip(
                  label: Text("Vegetarian"),
                  selected: _isVegetarian,
                  onSelected: (selected) {
                    setState(() {
                      _isVegetarian = selected;
                    });
                  },
                ),
                // Gluten-Free filter
                FilterChip(
                  label: Text("Gluten-Free"),
                  selected: _isGlutenFree,
                  onSelected: (selected) {
                    setState(() {
                      _isGlutenFree = selected;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 12),

            // Allergen filters
            Wrap(
              spacing: 8,
              children: allergens.map((allergen) {
                return ChoiceChip(
                  label: Text(allergen),
                  selected: _selectedAllergies.contains(allergen),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAllergies.add(allergen);
                      } else {
                        _selectedAllergies.remove(allergen);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchFood,
              child: Text("Search"),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
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
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover),
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
                                              RecipeDetailScreen(
                                                  recipe: recipe),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                  ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:math';
// import 'package:flutter/material.dart';

// class FoodSearchScreen extends StatefulWidget {
//   @override
//   _FoodSearchScreenState createState() => _FoodSearchScreenState();
// }

// class _FoodSearchScreenState extends State<FoodSearchScreen> {
//   final List<Map<String, dynamic>> foodDatabase = [
//     {
//       'name': 'Grilled Chicken Salad',
//       'calories': 350,
//       'allergens': [],
//       'dietType': 'Balanced'
//     },
//     {
//       'name': 'Avocado Toast',
//       'calories': 280,
//       'allergens': ['gluten'],
//       'dietType': 'Vegetarian'
//     },
//     {
//       'name': 'Salmon & Quinoa Bowl',
//       'calories': 450,
//       'allergens': ['fish'],
//       'dietType': 'High Protein'
//     },
//     {
//       'name': 'Vegan Buddha Bowl',
//       'calories': 400,
//       'allergens': ['nuts'],
//       'dietType': 'Vegan'
//     },
//     {
//       'name': 'Egg Omelette with Spinach',
//       'calories': 320,
//       'allergens': ['eggs'],
//       'dietType': 'Low Carb'
//     },
//     {
//       'name': 'Chicken Stir-Fry',
//       'calories': 420,
//       'allergens': [],
//       'dietType': 'Balanced'
//     },
//     {
//       'name': 'Beef Tacos',
//       'calories': 500,
//       'allergens': ['gluten'],
//       'dietType': 'High Protein'
//     },
//     {
//       'name': 'Greek Yogurt with Berries',
//       'calories': 250,
//       'allergens': ['dairy'],
//       'dietType': 'Low Carb'
//     },
//     {
//       'name': 'Tofu & Vegetable Stir-Fry',
//       'calories': 380,
//       'allergens': ['soy'],
//       'dietType': 'Vegan'
//     },
//     {
//       'name': 'Brown Rice & Grilled Salmon',
//       'calories': 470,
//       'allergens': ['fish'],
//       'dietType': 'Balanced'
//     },
//     {
//       'name': 'Lentil Soup',
//       'calories': 330,
//       'allergens': [],
//       'dietType': 'Vegan'
//     },
//     {
//       'name': 'Pasta Primavera',
//       'calories': 520,
//       'allergens': ['gluten'],
//       'dietType': 'Vegetarian'
//     },
//     {
//       'name': 'Baked Sweet Potato & Chicken',
//       'calories': 430,
//       'allergens': [],
//       'dietType': 'Balanced'
//     },
//     {
//       'name': 'Steamed Fish & Quinoa',
//       'calories': 400,
//       'allergens': ['fish'],
//       'dietType': 'High Protein'
//     },
//     {
//       'name': 'Cottage Cheese & Fruit',
//       'calories': 290,
//       'allergens': ['dairy'],
//       'dietType': 'Low Carb'
//     },
//     {
//       'name': 'Vegetable Curry with Rice',
//       'calories': 480,
//       'allergens': [],
//       'dietType': 'Vegan'
//     },
//   ];

//   List<Map<String, dynamic>> recommendedFoods = [];

//   void recommendFood({
//     required double bmi,
//     required double bmr,
//     required double tdee,
//     required String weightGoal,
//     required List<String> allergies,
//   }) {
//     int calorieTarget;
//     if (weightGoal == 'lose') {
//       calorieTarget = (tdee * 0.8).toInt(); // 20% deficit
//     } else if (weightGoal == 'gain') {
//       calorieTarget = (tdee * 1.1).toInt(); // 10% surplus
//     } else {
//       calorieTarget = tdee.toInt(); // Maintain weight
//     }

//     // Filter foods based on calories and allergies
//     List<Map<String, dynamic>> filteredFoods = foodDatabase.where((food) {
//       bool matchesCalories = food['calories'] <= calorieTarget;
//       bool noAllergyMatch = !food['allergens'].any(allergies.contains);
//       return matchesCalories && noAllergyMatch;
//     }).toList();

//     // Randomize and pick meals
//     filteredFoods.shuffle(Random());
//     int numMeals = Random().nextInt(1) + 6;

//     setState(() {
//       recommendedFoods = filteredFoods.take(numMeals).toList();
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     recommendFood(
//       bmi: 22.0,
//       bmr: 1600,
//       tdee: 2200,
//       weightGoal: 'maintain',
//       allergies: ['nuts', 'fish', 'soy'],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             AppBar(
//               title: Text("Recommended Meals"),
//             ),
//             if (recommendedFoods.isNotEmpty)
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: recommendedFoods.length,
//                   itemBuilder: (context, index) {
//                     final food = recommendedFoods[index];
//                     return Card(
//                       elevation: 3,
//                       margin: EdgeInsets.symmetric(vertical: 8),
//                       child: ListTile(
//                         title: Text(food['name']),
//                         subtitle: Text("${food['calories']} cal"),
//                         trailing: IconButton(
//                           icon: Icon(Icons.shuffle),
//                           onPressed: () => recommendFood(
//                             bmi: 22.0,
//                             bmr: 1600,
//                             tdee: 2200,
//                             weightGoal: 'maintain',
//                             allergies: [
//                               'nuts',
//                               'fish',
//                               'soy',
//                               'gluten',
//                               'eggs',
//                               'dairy'
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               )
//             else
//               Center(
//                 child: Text(
//                   "No suitable meals found",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: () => recommendFood(
//                 bmi: 22.0,
//                 bmr: 1600,
//                 tdee: 2200,
//                 weightGoal: 'maintain',
//                 allergies: ['nuts'],
//               ),
//               icon: Icon(Icons.refresh),
//               label: Text("Refresh Meals"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
