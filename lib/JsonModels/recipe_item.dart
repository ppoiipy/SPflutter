class RecipeItem {
  final String name;
  final String imageUrl;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final String source;
  final String recipeUrl;
  final List<String> ingredients;

  RecipeItem({
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.source,
    required this.recipeUrl,
    required this.ingredients,
  });

  // Factory method to create a RecipeItem from JSON
  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      name: json['label'] ?? 'No Name',
      imageUrl: json['image'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['totalNutrients']['PROCNT']?['quantity'] ?? 0).toDouble(),
      fat: (json['totalNutrients']['FAT']?['quantity'] ?? 0).toDouble(),
      carbs: (json['totalNutrients']['CHOCDF']?['quantity'] ?? 0).toDouble(),
      source: json['source'] ?? 'Unknown Source',
      recipeUrl: json['url'] ?? '',
      ingredients:
          List<String>.from(json['ingredients']?.map((x) => x['text']) ?? []),
    );
  }
}
