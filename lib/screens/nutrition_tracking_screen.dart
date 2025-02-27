import 'package:flutter/material.dart';

class NutritionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition Tracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today’s Nutrition Intake',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildNutritionCard('Calories', 1500, 2000,
                      Icons.local_fire_department, Colors.orange),
                  _buildNutritionCard(
                      'Protein', 120, 100, Icons.fitness_center, Colors.blue),
                  _buildNutritionCard(
                      'Carbs', 200, 250, Icons.fastfood, Colors.green),
                  _buildNutritionCard(
                      'Fats', 50, 70, Icons.opacity, Colors.red),
                  _buildNutritionCard('Fiber', 30, 40, Icons.eco, Colors.brown),
                  _buildNutritionCardWithImage('Sodium', 1200, 2300,
                      'assets/images/salt.png', Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(
      String title, int value, int maxValue, IconData icon, Color color) {
    bool isExceeding = value > maxValue;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Max: $maxValue',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            if (isExceeding)
              Text(
                '⚠ Exceeding!',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCardWithImage(
      String title, int value, int maxValue, String imagePath, Color color) {
    bool isExceeding = value > maxValue;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Image.asset(imagePath, width: 32, height: 32),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Max: $maxValue',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            if (isExceeding)
              Text(
                '⚠ Exceeding!',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
