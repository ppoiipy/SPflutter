import 'dart:convert';
import 'package:http/http.dart' as http;

// Function to fetch food data
Future<List<dynamic>> fetchFoodData(String query) async {
  final String appId = "015391e2"; // Food API APP ID
  final String appKey = "d66952b9b6f938a4145acbf23680e600"; // Food API Key
  final String url =
      "https://api.edamam.com/api/food-database/v2/parser?ingr=$query&app_id=$appId&app_key=$appKey";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['hints'] ?? [];
    } else {
      print("Error: ${response.statusCode}, ${response.body}");
      return [];
    }
  } catch (e) {
    print("Exception: $e");
    return [];
  }
}

Future<List<dynamic>> fetchRecipes(String query) async {
  final String appId = "720e210d";
  final String appKey = "446497202cda0b4ee6b1754ba948c3ac";
  final String url =
      "https://api.edamam.com/api/recipes/v2?type=public&q=$query&app_id=$appId&app_key=$appKey";

  print("Requesting URL: $url"); // Debugging

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData['hits'] ?? [];
    } else {
      print("Error: ${response.statusCode}, ${response.body}");
      return [];
    }
  } catch (e) {
    print("Exception: $e");
    return [];
  }
}

// Function to handle both food and recipe searches
Future<List<dynamic>> fetchData(String query, {bool isRecipe = false}) async {
  if (query.isEmpty) return []; // Prevent empty queries

  if (isRecipe) {
    return await fetchRecipes(query); // Fetch recipes
  } else {
    return await fetchFoodData(query); // Fetch food data
  }
}
