import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodApiService {
  static const String _appId = "015391e2";
  static const String _appKey = "d66952b9b6f938a4145acbf23680e600";
  static const String _baseUrl = "api.edamam.com";

  static Future<List<FoodItem>?> fetchFoodData({
    required String ingredient,
    double? minCalories,
    double? maxCalories,
    List<String>? cookingTechniques,
  }) async {
    final uri = Uri.https(_baseUrl, "/api/food-database/v2/parser", {
      "app_id": _appId,
      "app_key": _appKey,
      "ingr": ingredient,
    });

    try {
      final response = await http.get(uri);

      // Log API Response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> parsedFoods = data['hints'] ?? [];

        if (parsedFoods.isNotEmpty) {
          print('Found ${parsedFoods.length} items');

          // Convert JSON to FoodItem List
          List<FoodItem> foodItems =
              parsedFoods.map((e) => FoodItem.fromJson(e['food'])).toList();

          // **Apply Filters Client-Side**
          return foodItems.where((item) {
            bool calorieMatch =
                (minCalories == null || item.calories >= minCalories) &&
                    (maxCalories == null || item.calories <= maxCalories);

            bool techniqueMatch = cookingTechniques == null ||
                cookingTechniques.isEmpty ||
                cookingTechniques.contains(item.cookingTechnique);

            return calorieMatch && techniqueMatch;
          }).toList();
        } else {
          print('No food items found');
          return [];
        }
      } else {
        throw Exception("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}

class FoodItem {
  final String name;
  final String imageUrl;
  final double calories;
  final String cookingTechnique;
  final String cookingRecipe;

  FoodItem({
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.cookingTechnique,
    required this.cookingRecipe,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['label'] ?? 'Unknown Food', // Default value if 'label' is null
      imageUrl: json['image'] ??
          'https://via.placeholder.com/80', // Default image if 'image' is null
      calories: json['nutrients']?['ENERC_KCAL']?.toDouble() ??
          0.0, // Default to 0.0 if missing
      cookingTechnique: json['cookingTechnique'] ??
          'N/A', // Default value if 'cookingTechnique' is null
      cookingRecipe: json['cookingRecipe'] ??
          'N/A', // Default value if 'cookingRecipe' is null
    );
  }
}
