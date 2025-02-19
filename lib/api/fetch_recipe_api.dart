import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeApiService {
  static const String _appId = "720e210d";
  static const String _appKey = "446497202cda0b4ee6b1754ba948c3ac";
  static const String _baseUrl = "api.edamam.com";
  static const String _userId = "ginraidee";

  static Future<List<RecipeItem>?> fetchRecipes({
    required String query,
    double? maxCalories,
  }) async {
    final uri = Uri.https(_baseUrl, "/api/recipes/v2", {
      "app_id": _appId,
      "app_key": _appKey,
      "q": query,
      "type": "public", // Required for Edamam API
      if (maxCalories != null) "calories": "0-$maxCalories",
    });

    print('Request URI: $uri');

    try {
      final response = await http.get(uri);

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> hits = data['hits'] ?? [];
        print('Found ${hits.length} recipes');

        List<RecipeItem> recipes =
            hits.map((e) => RecipeItem.fromJson(e['recipe'])).toList();

        return recipes;
      } else {
        throw Exception("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  //
  static Future<RecipeItem?> fetchRecipeById(String id) async {
    final uri = Uri.https(_baseUrl, "/search", {
      "app_id": _appId,
      "app_key": _appKey,
      "q": id, // Using recipe URL or another unique identifier
    });

    try {
      final response = await http.get(
        uri,
        headers: {"Edamam-Account-User": _userId},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> hits = data['hits'] ?? [];

        if (hits.isNotEmpty) {
          return RecipeItem.fromJson(hits[0]['recipe']);
        } else {
          print('No recipe found for ID: $id');
          return null;
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

class RecipeItem {
  final String name;
  final String imageUrl;
  final double calories;
  final String source;
  final String recipeUrl;
  final List<String> ingredients;

  RecipeItem({
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.source,
    required this.recipeUrl,
    required this.ingredients,
  });

  // Convert Firestore data to RecipeItem
  factory RecipeItem.fromMap(Map<String, dynamic> map) {
    return RecipeItem(
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      calories: (map['calories'] ?? 0).toDouble(),
      source: map['source'] ?? '',
      recipeUrl: map['recipeUrl'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
    );
  }

  // Convert RecipeItem to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'calories': calories,
      'source': source,
      'recipeUrl': recipeUrl,
      'ingredients': ingredients,
    };
  }

  // Convert JSON from API to RecipeItem
  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      name: json['label'] ?? 'Unknown Recipe',
      imageUrl: json['image'] ?? 'https://via.placeholder.com/100',
      calories: json['calories']?.toDouble() ?? 0.0,
      source: json['source'] ?? 'Unknown Source',
      recipeUrl: json['url'] ?? '',
      ingredients: List<String>.from(json['ingredientLines'] ?? []),
    );
  }
}
