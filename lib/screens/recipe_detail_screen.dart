import 'package:flutter/material.dart';
import 'package:flutter_application_1/api/fetch_recipe_api.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeItem recipe;

  RecipeDetailScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the recipe image
              Image.network(recipe.imageUrl),
              const SizedBox(height: 16),

              // Recipe name
              Text(
                recipe.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Recipe calories
              Text("Calories: ${recipe.calories.toStringAsFixed(1)} kcal"),
              const SizedBox(height: 8),

              // Recipe source
              Text("Source: ${recipe.source}"),
              const SizedBox(height: 16),

              // Ingredients section
              Text(
                "Ingredients:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // List ingredients
              for (var ingredient in recipe.ingredients) Text("- $ingredient"),

              const SizedBox(height: 16),

              // Button to launch the full recipe (including instructions)
              ElevatedButton(
                onPressed: () {
                  // Launch URL to the recipe's website (which should include instructions)
                  if (recipe.recipeUrl.isNotEmpty) {
                    _launchURL(recipe.recipeUrl);
                  } else {
                    // Handle the case where no URL is available
                    print('No URL available');
                  }
                },
                child: Text("View Full Recipe"),
              ),
              Text('Source: ${recipe.recipeUrl}'),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to launch URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }
}
