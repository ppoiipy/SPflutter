import 'package:flutter/material.dart';

class Food {
  final String name;
  final double calories;
  final List<String> ingredients;
  final String category;
  final String cookingTechnique;
  final List<String> allergens;
  final List<String> flavorProfile;

  Food({
    required this.name,
    required this.calories,
    required this.ingredients,
    required this.category,
    required this.cookingTechnique,
    required this.allergens,
    required this.flavorProfile,
  });
}

class FoodFilterScreen extends StatefulWidget {
  @override
  _FoodFilterScreenState createState() => _FoodFilterScreenState();
}

class _FoodFilterScreenState extends State<FoodFilterScreen> {
  List<Food> foodDatabase = [
    // 🥩 Pork Dishes
    Food(
      name: "Grilled Pork Salad",
      calories: 350,
      ingredients: ["pork loin", "lettuce", "tomato", "olive oil", "lemon"],
      category: "Salad",
      cookingTechnique: "Grilled",
      allergens: [],
      flavorProfile: ["savory", "fresh"],
    ),
    Food(
      name: "Pork & Vegetable Soup",
      calories: 290,
      ingredients: ["pork shoulder", "carrots", "onion", "garlic", "spices"],
      category: "Soup",
      cookingTechnique: "Boiled",
      allergens: [],
      flavorProfile: ["savory", "mild"],
    ),
    Food(
      name: "Fried Pork Rice",
      calories: 550,
      ingredients: ["pork", "rice", "oil", "soy sauce"],
      category: "Rice Dish",
      cookingTechnique: "Fried",
      allergens: ["soy"],
      flavorProfile: ["salty", "crispy"],
    ),
    Food(
      name: "Pork Stir-Fry with Vegetables",
      calories: 420,
      ingredients: ["pork", "bell pepper", "broccoli", "soy sauce", "garlic"],
      category: "Stir-Fry",
      cookingTechnique: "Sautéed",
      allergens: ["soy"],
      flavorProfile: ["savory", "umami"],
    ),
    Food(
      name: "Pork and Egg Noodle Soup",
      calories: 480,
      ingredients: ["pork", "egg noodles", "broth", "onion", "herbs"],
      category: "Noodle Soup",
      cookingTechnique: "Boiled",
      allergens: ["egg"],
      flavorProfile: ["rich", "hearty"],
    ),

    // 🍗 Chicken Dishes
    Food(
      name: "Grilled Chicken Salad",
      calories: 320,
      ingredients: ["chicken", "lettuce", "tomato", "olive oil"],
      category: "Salad",
      cookingTechnique: "Grilled",
      allergens: [],
      flavorProfile: ["savory", "fresh"],
    ),
    Food(
      name: "Chicken Teriyaki with Brown Rice",
      calories: 450,
      ingredients: ["chicken", "teriyaki sauce", "brown rice", "sesame seeds"],
      category: "Asian",
      cookingTechnique: "Grilled",
      allergens: ["soy"],
      flavorProfile: ["sweet", "savory"],
    ),
    Food(
      name: "Chicken & Quinoa Bowl",
      calories: 390,
      ingredients: ["chicken", "quinoa", "avocado", "spinach", "lime"],
      category: "Healthy Bowl",
      cookingTechnique: "Grilled",
      allergens: [],
      flavorProfile: ["light", "fresh"],
    ),

    // 🥦 Vegetarian Dishes
    Food(
      name: "Mushroom & Tofu Stir-Fry",
      calories: 280,
      ingredients: ["tofu", "mushroom", "soy sauce", "ginger", "garlic"],
      category: "Stir-Fry",
      cookingTechnique: "Sautéed",
      allergens: ["soy"],
      flavorProfile: ["umami", "savory"],
    ),
    Food(
      name: "Avocado & Chickpea Salad",
      calories: 320,
      ingredients: ["avocado", "chickpeas", "olive oil", "lemon", "herbs"],
      category: "Salad",
      cookingTechnique: "Raw",
      allergens: [],
      flavorProfile: ["creamy", "fresh"],
    ),
    Food(
      name: "Vegan Thai Green Curry",
      calories: 410,
      ingredients: ["coconut milk", "tofu", "eggplant", "green curry paste"],
      category: "Curry",
      cookingTechnique: "Boiled",
      allergens: ["coconut"],
      flavorProfile: ["spicy", "creamy"],
    ),

    // 🥚 Egg-Based Dishes
    Food(
      name: "Omelette with Spinach & Feta",
      calories: 340,
      ingredients: ["eggs", "spinach", "feta cheese", "onion"],
      category: "Breakfast",
      cookingTechnique: "Pan-Fried",
      allergens: ["egg", "dairy"],
      flavorProfile: ["savory", "creamy"],
    ),
    Food(
      name: "Egg & Avocado Toast",
      calories: 360,
      ingredients: ["egg", "avocado", "whole grain bread", "lemon"],
      category: "Breakfast",
      cookingTechnique: "Pan-Fried",
      allergens: ["egg", "gluten"],
      flavorProfile: ["creamy", "fresh"],
    ),
  ];

  String preferredIngredient = "pork";
  double maxCalories = 400;

  List<Food> filterFood(
      List<Food> foodList, String preferredIngredient, double maxCalories) {
    List<Food> filtered = foodList.where((food) {
      bool containsIngredient = food.ingredients.any((ing) =>
          ing.toLowerCase().contains(preferredIngredient.toLowerCase()));
      bool withinCalories = food.calories <= maxCalories;
      return containsIngredient && withinCalories;
    }).toList();

    if (filtered.isEmpty) {
      filtered = foodList.where((food) {
        bool containsIngredient = food.ingredients.any((ing) =>
            ing.toLowerCase().contains(preferredIngredient.toLowerCase()));
        bool withinCalories =
            food.calories <= maxCalories + 150; // Allow up to 550 kcal
        return containsIngredient && withinCalories;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    List<Food> filteredFood =
        filterFood(foodDatabase, preferredIngredient, maxCalories);

    return Scaffold(
      appBar: AppBar(title: Text("Food Recommendations")),
      body: filteredFood.isEmpty
          ? Center(child: Text("No matching food found."))
          : ListView.builder(
              itemCount: filteredFood.length,
              itemBuilder: (context, index) {
                Food food = filteredFood[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(food.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${food.calories} kcal | ${food.category}"),
                    trailing: Icon(Icons.fastfood),
                  ),
                );
              },
            ),
    );
  }
}
