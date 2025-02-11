class MenuItem {
  final String name;
  final String imagePath;
  final double calories;
  final String cookingTechnique;
  final String cookingRecipe;

  MenuItem({
    required this.name,
    required this.imagePath,
    required this.calories,
    required this.cookingTechnique,
    required this.cookingRecipe,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['label'] ?? 'Unknown Food',
      imagePath: json['image'] ?? 'https://via.placeholder.com/80',
      calories: json['nutrients']?['ENERC_KCAL']?.toDouble() ?? 0.0,
      cookingTechnique: json['cookingTechnique'] ?? 'N/A',
      cookingRecipe: json['cookingRecipe'] ?? 'N/A',
    );
  }
}
