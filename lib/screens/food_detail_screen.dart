import 'package:flutter/material.dart';
import 'package:flutter_application_1/JsonModels/menu_item.dart';
import 'package:flutter_application_1/api/fetch_food_api.dart';

class FoodDetailScreen extends StatefulWidget {
  final MenuItem menuItem;

  const FoodDetailScreen({Key? key, required this.menuItem}) : super(key: key);

  @override
  FoodDetailScreenState createState() => FoodDetailScreenState();
}

class FoodDetailScreenState extends State<FoodDetailScreen> {
  String _selectedDetail = 'InN';
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.menuItem.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              size: 34,
              color: _isFavorite ? Color.fromARGB(255, 255, 191, 0) : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                widget.menuItem.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
            SizedBox(height: 20),
            Text(widget.menuItem.name),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDetail = 'InN';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedDetail == 'InN'
                            ? Color(0xFF1F5F5B)
                            : Colors.grey[300],
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8)),
                        ),
                      ),
                      child: Text(
                        'Ingredients & Nutrition',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _selectedDetail == 'InN'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDetail = 'Directions';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedDetail == 'Directions'
                            ? Color(0xFF1F5F5B)
                            : Colors.grey[300],
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8)),
                        ),
                      ),
                      child: Text(
                        'Directions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _selectedDetail == 'Directions'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_selectedDetail == 'InN')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredients',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text('null'),
                  // Text('4 salmon fillets (5 to 6 ounces; 140 to each)'),
                  // Text('Kosher salt'),
                  // Text('2 tablespoons (30ml) extra-virgin olive oil'),
                  // Text(
                  //     'Aromatics such as fresh thyme, dill, parsley, thinly sliced shallots, and/or citrus zest (optional)'),
                  // Text('2 teaspoons (10ml) begetable oil, if serving seared'),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            horizontal: BorderSide(
                      color: Colors.grey,
                      width: 2,
                    ))),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(children: [
                            Text(
                              '909',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              'CALORIES/SERVING',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            )
                          ]),
                        ),
                        Expanded(
                          child: Column(children: [
                            Text(
                              '45%',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              'DAILY VALUE',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            )
                          ]),
                        ),
                        Expanded(
                          child: Column(children: [
                            Text(
                              '4',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              'SERVINGS',
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            )
                          ]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      _buildNutrientRow('Fat', '62g', '96%'),
                      _buildNutrientRow('Saturated', '0g', '0%'),
                      _buildNutrientRow('Trans', '22g', '0%'),
                      _buildNutrientRow('Monounsaturated', '17g', '0%'),
                      _buildNutrientRow('Polyunsaturated', '17g', '0%'),
                      _buildNutrientRow('Carbs', '1g', '0%'),
                      _buildNutrientRow('Carbs (net)', '0g', '0%'),
                      _buildNutrientRow('Fiber', '1g', '2%'),
                      _buildNutrientRow('Sugars', '0g', '0%'),
                      _buildNutrientRow('Sugars, added', '0g', '0%'),
                      _buildNutrientRow('Protein', '81g', '162%'),
                      _buildNutrientRow('Cholesterol', '218mg', '73%'),
                      _buildNutrientRow('Sodium', '952mg', '40%'),
                      _buildNutrientRow('Calcium', '53mg', '5%'),
                      _buildNutrientRow('Magnesium', '113mg', '27%'),
                      _buildNutrientRow('Potassium', '1462mg', '31%'),
                      _buildNutrientRow('Iron', '2mg', '12%'),
                      _buildNutrientRow('Zinc', '2mg', '14%'),
                      _buildNutrientRow('Phosphorus', '955g', '136%'),
                      _buildNutrientRow('Vitamin A', '239mg', '27%'),
                      _buildNutrientRow('Vitamin C', '22mg', '24%'),
                      _buildNutrientRow('Thiamin (B1)', '1mg', '68%'),
                      _buildNutrientRow('Riboflavin (B2)', '1mg', '49%'),
                      _buildNutrientRow('Niacin (B3)', '34mg', '215%'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Calories: ${widget.menuItem.calories} Kcal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Cooking Technique:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.menuItem.cookingTechnique.isNotEmpty
                        ? widget.menuItem.cookingTechnique
                        : 'Not specified',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Recipe:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    widget.menuItem.cookingRecipe.isNotEmpty
                        ? widget.menuItem.cookingRecipe
                        : 'No recipe available',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            if (_selectedDetail == 'Directions')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Directions',
                    style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Text('1. Season salmon generously with salt on all sides.'),
                  Text(
                      '2. Place salmon in a single layer in a gallon-size zipper-lock bag, or in batches in quart-size bags. Add olive oil to bag or divide it between the smaller bags. Add aromatics to bags, if using. Close bags, place in refrigerator, and let salmon rest for at least 30 minutes or up to overnight.'),
                  Text(
                      '3. Using an immersion circulator, preheat a water bath according to the chart above and in notes section. Remove the air from the zipper-lock bags using the  water displacement method: Seal bag almost all the way, leaving about an inch open. Slowly lower bag into water bath, holding the opened end above the water level. As bag is lowered, the water pressure should force air out of it. Just  before it is totally submerged, seal bag completely. Use a rack, or clip bag to the side of cooking vessel using a binder clip, to'),
                  Text(''),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

Widget _buildNutrientRow(String name, String amount, String dailyValue) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(flex: 5, child: Text(name, style: TextStyle(fontSize: 14))),
        Expanded(
          flex: 0,
          child: Text(amount,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        // SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: Text(
            dailyValue,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}
