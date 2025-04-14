import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, int>> fetchUserData(String userId) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final clickSnapshot = await userRef.collection('clickHistory').get();
  final favoriteSnapshot = await userRef.collection('favoriteFoods').get();
  final foodLogSnapshot = await userRef.collection('foodLog').get();

  final Map<String, int> recipeData = {};

  for (var doc in clickSnapshot.docs) {
    recipeData[doc['label']] = (recipeData[doc['label']] ?? 0) + 1;
  }
  for (var doc in favoriteSnapshot.docs) {
    recipeData[doc['label']] = (recipeData[doc['label']] ?? 0) + 2;
  }
  for (var doc in foodLogSnapshot.docs) {
    recipeData[doc['label']] = (recipeData[doc['label']] ?? 0) + 3;
  }

  return recipeData;
}

Future<Map<String, Map<String, int>>> fetchAllUserData() async {
  final usersSnapshot =
      await FirebaseFirestore.instance.collection('users').get();
  final Map<String, Map<String, int>> allUserData = {};

  for (var userDoc in usersSnapshot.docs) {
    final userId = userDoc.id;
    final data = await fetchUserData(userId);
    allUserData[userId] = data;
  }

  return allUserData;
}

double cosineSimilarity(Map<String, int> a, Map<String, int> b) {
  final commonKeys = a.keys.toSet().intersection(b.keys.toSet());

  if (commonKeys.isEmpty) return 0.0;

  final dotProduct =
      commonKeys.fold<double>(0.0, (sum, key) => sum + (a[key]! * b[key]!));
  final magnitudeA =
      sqrt(a.values.fold<double>(0.0, (sum, value) => sum + pow(value, 2)));
  final magnitudeB =
      sqrt(b.values.fold<double>(0.0, (sum, value) => sum + pow(value, 2)));

  if (magnitudeA == 0 || magnitudeB == 0) return 0.0;

  return dotProduct / (magnitudeA * magnitudeB);
}

Future<Map<String, dynamic>> loadRecipeData() async {
  final jsonData =
      await rootBundle.loadString('assets/fetchMenu/recipe_output.json');
  final Map<String, dynamic> jsonMap = json.decode(jsonData);
  final List<dynamic> hits = jsonMap['hits'];

  final Map<String, dynamic> recipeMap = {};
  for (var hit in hits) {
    final recipe = hit['recipe'];
    recipeMap[recipe['label']] = recipe;
  }

  return recipeMap;
}

Future<List<String>> getRecommendedRecipes(String currentUserId) async {
  final allUserData = await fetchAllUserData();
  final currentUserData = allUserData[currentUserId] ?? {};
  allUserData.remove(currentUserId);

  final Map<String, double> userSimilarities = {};
  for (var entry in allUserData.entries) {
    final similarity = cosineSimilarity(currentUserData, entry.value);
    if (similarity >= 0.5) {
      userSimilarities[entry.key] = similarity;
    }
  }

  final Map<String, double> recipeScores = {};
  for (var entry in userSimilarities.entries) {
    final otherUserData = allUserData[entry.key]!;
    for (var recipe in otherUserData.entries) {
      recipeScores[recipe.key] =
          (recipeScores[recipe.key] ?? 0) + recipe.value * entry.value;
    }
  }

  final recipeMap = await loadRecipeData();
  final currentUserDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .get();
  final userPrefs = List<String>.from(currentUserDoc['foodIngredient'] ?? []);

  recipeMap.forEach((label, recipe) {
    // Add small score to unseen recipes
    recipeScores[label] = (recipeScores[label] ?? 0.1);

    final ingredients = List<String>.from(recipe['ingredientLines'] ?? []);
    final hasPreferred = ingredients.any((ingredient) => userPrefs
        .any((pref) => ingredient.toLowerCase().contains(pref.toLowerCase())));

    if (hasPreferred) {
      recipeScores[label] = (recipeScores[label] ?? 0) + 10;
    }
  });

  final sorted = recipeScores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.map((entry) => entry.key).toList();
}

class RecommendationScreen extends StatefulWidget {
  final String userId;
  const RecommendationScreen({required this.userId, super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  List<String> recommendedLabels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    final results = await getRecommendedRecipes(widget.userId);
    setState(() {
      recommendedLabels = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recommended Recipes")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: recommendedLabels.length,
              itemBuilder: (context, index) {
                final label = recommendedLabels[index];
                return ListTile(
                  title: Text(label),
                  onTap: () {
                    // Navigate to Recipe Detail
                  },
                );
              },
            ),
    );
  }
}
