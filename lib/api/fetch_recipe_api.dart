import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeApiService {
  static const String _appId = "720e210d";
  static const String _appKey = "446497202cda0b4ee6b1754ba948c3ac";
  static const String _baseUrl = "api.edamam.com";
  static const String _userId = "ginraidee"; // Your user ID

  static Future<List<RecipeItem>?> fetchRecipes({
    required String ingredient,
    double? maxCalories,
    bool isVegetarian = false,
    bool isGlutenFree = false,
    List<String>? selectedAllergies,
  }) async {
    final uri = Uri.https(_baseUrl, "/search", {
      "app_id": _appId,
      "app_key": _appKey,
      "q": ingredient,
      if (maxCalories != null) "calories": "0-$maxCalories",
    });

    print('Request URI: $uri'); // Log the request URI

    try {
      final response = await http.get(
        uri,
        headers: {
          "Edamam-Account-User": _userId, // Add the user ID here in the headers
        },
      );

      print('Response body: ${response.body}'); // Log the response body

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> hits = data['hits'] ?? [];

        print('Found ${hits.length} recipes'); // Log the number of recipes

        List<RecipeItem> recipes =
            hits.map((e) => RecipeItem.fromJson(e['recipe'])).toList();

        // Now filter similar recipes based on the ingredients
        return filterSimilarRecipes(recipes, ingredient);
      } else {
        throw Exception("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  // Content-based filtering: Recommend recipes with similar ingredients
  static List<RecipeItem> filterSimilarRecipes(
      List<RecipeItem> recipes, String currentIngredient) {
    List<RecipeItem> recommendedRecipes = [];

    // Loop through the recipes and compare their ingredients with the current ingredient
    for (var recipe in recipes) {
      // Check if the recipe contains the current ingredient (simple keyword match)
      if (recipe.ingredients.any((ingredient) =>
          ingredient.toLowerCase().contains(currentIngredient.toLowerCase()))) {
        recommendedRecipes.add(recipe);
      }
    }

    print('Recommended ${recommendedRecipes.length} similar recipes');
    return recommendedRecipes;
  }
}

class RecipeItem {
  final String name;
  final String imageUrl;
  final double calories;
  final String source;
  final String recipeUrl;
  final List<String> ingredients;
  final String instructions;

  RecipeItem({
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.source,
    required this.recipeUrl,
    required this.ingredients,
    required this.instructions,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    // Make sure to access 'ingredients' properly
    List<String> ingredients = List<String>.from(json['ingredientLines'] ?? []);

    String instructions = json['instructions'] ?? 'No instructions available';

    return RecipeItem(
      name: json['label'] ?? 'Unknown Recipe',
      imageUrl: json['image'] ?? 'https://via.placeholder.com/100',
      calories: json['calories']?.toDouble() ?? 0.0,
      source: json['source'] ?? 'Unknown Source',
      recipeUrl: json['url'] ?? '',
      ingredients: ingredients,
      instructions: instructions,
    );
  }
}
