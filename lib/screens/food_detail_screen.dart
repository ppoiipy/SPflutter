// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_application_1/JsonModels/menu_item.dart';
// // // import 'package:flutter_application_1/api/fetch_food_api.dart';

// // // class FoodDetailScreen extends StatefulWidget {
// // //   final MenuItem menuItem;

// // //   const FoodDetailScreen({Key? key, required this.menuItem}) : super(key: key);

// // //   @override
// // //   FoodDetailScreenState createState() => FoodDetailScreenState();
// // // }

// // // class FoodDetailScreenState extends State<FoodDetailScreen> {
// // //   String _selectedDetail = 'InN';
// // //   bool _isFavorite = false;

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         leading: IconButton(
// // //           icon: Icon(Icons.arrow_back_ios),
// // //           onPressed: () {
// // //             Navigator.pop(context);
// // //           },
// // //         ),
// // //         title: Text(
// // //           widget.menuItem.name,
// // //           style: TextStyle(
// // //             fontWeight: FontWeight.w600,
// // //             fontFamily: 'Inter',
// // //             letterSpacing: 1,
// // //           ),
// // //         ),
// // //         actions: [
// // //           IconButton(
// // //             icon: Icon(
// // //               _isFavorite ? Icons.star : Icons.star_border,
// // //               size: 34,
// // //               color: _isFavorite ? Color.fromARGB(255, 255, 191, 0) : null,
// // //             ),
// // //             onPressed: () {
// // //               setState(() {
// // //                 _isFavorite = !_isFavorite;
// // //               });
// // //             },
// // //           ),
// // //         ],
// // //       ),
// // //       body: SingleChildScrollView(
// // //         padding: EdgeInsets.all(16.0),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             ClipRRect(
// // //               borderRadius: BorderRadius.circular(15),
// // //               child: Image.network(
// // //                 widget.menuItem.imagePath,
// // //                 fit: BoxFit.cover,
// // //                 width: double.infinity,
// // //                 height: 200,
// // //               ),
// // //             ),
// // //             SizedBox(height: 20),
// // //             Text(widget.menuItem.name),
// // //             SizedBox(height: 20),
// // //             Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Container(
// // //                     child: ElevatedButton(
// // //                       onPressed: () {
// // //                         setState(() {
// // //                           _selectedDetail = 'InN';
// // //                         });
// // //                       },
// // //                       style: ElevatedButton.styleFrom(
// // //                         backgroundColor: _selectedDetail == 'InN'
// // //                             ? Color(0xFF1F5F5B)
// // //                             : Colors.grey[300],
// // //                         padding: EdgeInsets.symmetric(vertical: 12),
// // //                         shape: RoundedRectangleBorder(
// // //                           borderRadius: BorderRadius.only(
// // //                               topLeft: Radius.circular(8),
// // //                               bottomLeft: Radius.circular(8)),
// // //                         ),
// // //                       ),
// // //                       child: Text(
// // //                         'Ingredients & Nutrition',
// // //                         style: TextStyle(
// // //                           fontSize: 16,
// // //                           fontWeight: FontWeight.bold,
// // //                           color: _selectedDetail == 'InN'
// // //                               ? Colors.white
// // //                               : Colors.black,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 Expanded(
// // //                   child: Container(
// // //                     child: ElevatedButton(
// // //                       onPressed: () {
// // //                         setState(() {
// // //                           _selectedDetail = 'Directions';
// // //                         });
// // //                       },
// // //                       style: ElevatedButton.styleFrom(
// // //                         backgroundColor: _selectedDetail == 'Directions'
// // //                             ? Color(0xFF1F5F5B)
// // //                             : Colors.grey[300],
// // //                         padding: EdgeInsets.symmetric(vertical: 12),
// // //                         shape: RoundedRectangleBorder(
// // //                           borderRadius: BorderRadius.only(
// // //                               topRight: Radius.circular(8),
// // //                               bottomRight: Radius.circular(8)),
// // //                         ),
// // //                       ),
// // //                       child: Text(
// // //                         'Directions',
// // //                         style: TextStyle(
// // //                           fontSize: 16,
// // //                           fontWeight: FontWeight.bold,
// // //                           color: _selectedDetail == 'Directions'
// // //                               ? Colors.white
// // //                               : Colors.black,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             SizedBox(height: 20),
// // //             if (_selectedDetail == 'InN')
// // //               Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     'Ingredients',
// // //                     style: TextStyle(
// // //                         color: Colors.grey[600],
// // //                         fontWeight: FontWeight.bold,
// // //                         fontSize: 20),
// // //                   ),
// // //                   SizedBox(height: 10),
// // //                   Text('null'),
// // //                   // Text('4 salmon fillets (5 to 6 ounces; 140 to each)'),
// // //                   // Text('Kosher salt'),
// // //                   // Text('2 tablespoons (30ml) extra-virgin olive oil'),
// // //                   // Text(
// // //                   //     'Aromatics such as fresh thyme, dill, parsley, thinly sliced shallots, and/or citrus zest (optional)'),
// // //                   // Text('2 teaspoons (10ml) begetable oil, if serving seared'),
// // //                   SizedBox(height: 10),
// // //                   Container(
// // //                     padding: EdgeInsets.symmetric(vertical: 10),
// // //                     decoration: BoxDecoration(
// // //                         border: Border.symmetric(
// // //                             horizontal: BorderSide(
// // //                       color: Colors.grey,
// // //                       width: 2,
// // //                     ))),
// // //                     child: Row(
// // //                       children: [
// // //                         Expanded(
// // //                           child: Column(children: [
// // //                             Text(
// // //                               '909',
// // //                               style: TextStyle(
// // //                                   fontWeight: FontWeight.bold, fontSize: 20),
// // //                             ),
// // //                             Text(
// // //                               'CALORIES/SERVING',
// // //                               style: TextStyle(
// // //                                   color: Colors.grey[600],
// // //                                   fontWeight: FontWeight.bold,
// // //                                   fontSize: 12),
// // //                             )
// // //                           ]),
// // //                         ),
// // //                         Expanded(
// // //                           child: Column(children: [
// // //                             Text(
// // //                               '45%',
// // //                               style: TextStyle(
// // //                                   fontWeight: FontWeight.bold, fontSize: 20),
// // //                             ),
// // //                             Text(
// // //                               'DAILY VALUE',
// // //                               style: TextStyle(
// // //                                   color: Colors.grey[600],
// // //                                   fontWeight: FontWeight.bold,
// // //                                   fontSize: 12),
// // //                             )
// // //                           ]),
// // //                         ),
// // //                         Expanded(
// // //                           child: Column(children: [
// // //                             Text(
// // //                               '4',
// // //                               style: TextStyle(
// // //                                   fontWeight: FontWeight.bold, fontSize: 20),
// // //                             ),
// // //                             Text(
// // //                               'SERVINGS',
// // //                               style: TextStyle(
// // //                                   color: Colors.grey[600],
// // //                                   fontWeight: FontWeight.bold,
// // //                                   fontSize: 12),
// // //                             )
// // //                           ]),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                   SizedBox(height: 20),
// // //                   Column(
// // //                     children: [
// // //                       _buildNutrientRow('Fat', '62g', '96%'),
// // //                       _buildNutrientRow('Saturated', '0g', '0%'),
// // //                       _buildNutrientRow('Trans', '22g', '0%'),
// // //                       _buildNutrientRow('Monounsaturated', '17g', '0%'),
// // //                       _buildNutrientRow('Polyunsaturated', '17g', '0%'),
// // //                       _buildNutrientRow('Carbs', '1g', '0%'),
// // //                       _buildNutrientRow('Carbs (net)', '0g', '0%'),
// // //                       _buildNutrientRow('Fiber', '1g', '2%'),
// // //                       _buildNutrientRow('Sugars', '0g', '0%'),
// // //                       _buildNutrientRow('Sugars, added', '0g', '0%'),
// // //                       _buildNutrientRow('Protein', '81g', '162%'),
// // //                       _buildNutrientRow('Cholesterol', '218mg', '73%'),
// // //                       _buildNutrientRow('Sodium', '952mg', '40%'),
// // //                       _buildNutrientRow('Calcium', '53mg', '5%'),
// // //                       _buildNutrientRow('Magnesium', '113mg', '27%'),
// // //                       _buildNutrientRow('Potassium', '1462mg', '31%'),
// // //                       _buildNutrientRow('Iron', '2mg', '12%'),
// // //                       _buildNutrientRow('Zinc', '2mg', '14%'),
// // //                       _buildNutrientRow('Phosphorus', '955g', '136%'),
// // //                       _buildNutrientRow('Vitamin A', '239mg', '27%'),
// // //                       _buildNutrientRow('Vitamin C', '22mg', '24%'),
// // //                       _buildNutrientRow('Thiamin (B1)', '1mg', '68%'),
// // //                       _buildNutrientRow('Riboflavin (B2)', '1mg', '49%'),
// // //                       _buildNutrientRow('Niacin (B3)', '34mg', '215%'),
// // //                     ],
// // //                   ),
// // //                   SizedBox(height: 20),
// // //                   Text(
// // //                     'Calories: ${widget.menuItem.calories} Kcal',
// // //                     style: TextStyle(
// // //                       fontSize: 18,
// // //                       fontWeight: FontWeight.bold,
// // //                     ),
// // //                   ),
// // //                   SizedBox(height: 10),
// // //                   Text(
// // //                     'Cooking Technique:',
// // //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// // //                   ),
// // //                   Text(
// // //                     widget.menuItem.cookingTechnique.isNotEmpty
// // //                         ? widget.menuItem.cookingTechnique
// // //                         : 'Not specified',
// // //                     style: TextStyle(fontSize: 14),
// // //                   ),
// // //                   SizedBox(height: 10),
// // //                   Text(
// // //                     'Recipe:',
// // //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// // //                   ),
// // //                   Text(
// // //                     widget.menuItem.cookingRecipe.isNotEmpty
// // //                         ? widget.menuItem.cookingRecipe
// // //                         : 'No recipe available',
// // //                     style: TextStyle(fontSize: 14),
// // //                   ),
// // //                 ],
// // //               ),
// // //             if (_selectedDetail == 'Directions')
// // //               Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     'Directions',
// // //                     style: TextStyle(
// // //                         color: Colors.grey[600],
// // //                         fontWeight: FontWeight.bold,
// // //                         fontSize: 20),
// // //                   ),
// // //                   SizedBox(height: 10),
// // //                   Text('1. Season salmon generously with salt on all sides.'),
// // //                   Text(
// // //                       '2. Place salmon in a single layer in a gallon-size zipper-lock bag, or in batches in quart-size bags. Add olive oil to bag or divide it between the smaller bags. Add aromatics to bags, if using. Close bags, place in refrigerator, and let salmon rest for at least 30 minutes or up to overnight.'),
// // //                   Text(
// // //                       '3. Using an immersion circulator, preheat a water bath according to the chart above and in notes section. Remove the air from the zipper-lock bags using the  water displacement method: Seal bag almost all the way, leaving about an inch open. Slowly lower bag into water bath, holding the opened end above the water level. As bag is lowered, the water pressure should force air out of it. Just  before it is totally submerged, seal bag completely. Use a rack, or clip bag to the side of cooking vessel using a binder clip, to'),
// // //                   Text(''),
// // //                 ],
// // //               ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// // // Widget _buildNutrientRow(String name, String amount, String dailyValue) {
// // //   return Padding(
// // //     padding: const EdgeInsets.symmetric(vertical: 4.0),
// // //     child: Row(
// // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //       children: [
// // //         Expanded(flex: 5, child: Text(name, style: TextStyle(fontSize: 14))),
// // //         Expanded(
// // //           flex: 0,
// // //           child: Text(amount,
// // //               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
// // //         ),
// // //         // SizedBox(width: 10),
// // //         Expanded(
// // //           flex: 1,
// // //           child: Text(
// // //             dailyValue,
// // //             style: TextStyle(
// // //                 fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
// // //             textAlign: TextAlign.end,
// // //           ),
// // //         ),
// // //       ],
// // //     ),
// // //   );
// // // }

// // 2
// // import 'package:flutter/material.dart';
// // import 'package:flutter_application_1/JsonModels/menu_item.dart';

// // class FoodDetailScreen extends StatefulWidget {
// //   final MenuItem menuItem;

// //   FoodDetailScreen({required this.menuItem});

// //   @override
// //   FoodDetailScreenState createState() => FoodDetailScreenState();
// // }

// // class FoodDetailScreenState extends State<FoodDetailScreen> {
// //   String _selectedDetail = 'InN';
// //   bool _isFavorite = false;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back_ios),
// //           onPressed: () {
// //             Navigator.pop(context);
// //           },
// //         ),
// //         title: Text(
// //           widget.menuItem.name,
// //           style: TextStyle(
// //             fontWeight: FontWeight.w600,
// //             fontFamily: 'Inter',
// //             letterSpacing: 1,
// //           ),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: Icon(
// //               _isFavorite ? Icons.star : Icons.star_border,
// //               size: 34,
// //               color: _isFavorite ? Color.fromARGB(255, 255, 191, 0) : null,
// //             ),
// //             onPressed: () {
// //               setState(() {
// //                 _isFavorite = !_isFavorite;
// //               });
// //             },
// //           ),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         padding: EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             ClipRRect(
// //               borderRadius: BorderRadius.circular(15),
// //               child: Image.asset(
// //                 widget.menuItem.imagePath,
// //                 fit: BoxFit.cover,
// //                 width: double.infinity,
// //                 height: 200,
// //               ),
// //             ),
// //             SizedBox(height: 20),
// //             Text(widget.menuItem.name),
// //             SizedBox(height: 20),
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: Container(
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         setState(() {
// //                           _selectedDetail = 'InN';
// //                         });
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: _selectedDetail == 'InN'
// //                             ? Color(0xFF1F5F5B)
// //                             : Colors.grey[300],
// //                         padding: EdgeInsets.symmetric(vertical: 12),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.only(
// //                               topLeft: Radius.circular(8),
// //                               bottomLeft: Radius.circular(8)),
// //                         ),
// //                       ),
// //                       child: Text(
// //                         'Ingredients & Nutrition',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: _selectedDetail == 'InN'
// //                               ? Colors.white
// //                               : Colors.black,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: Container(
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         setState(() {
// //                           _selectedDetail = 'Directions';
// //                         });
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: _selectedDetail == 'Directions'
// //                             ? Color(0xFF1F5F5B)
// //                             : Colors.grey[300],
// //                         padding: EdgeInsets.symmetric(vertical: 12),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.only(
// //                               topRight: Radius.circular(8),
// //                               bottomRight: Radius.circular(8)),
// //                         ),
// //                       ),
// //                       child: Text(
// //                         'Directions',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: _selectedDetail == 'Directions'
// //                               ? Colors.white
// //                               : Colors.black,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: 20),
// //             if (_selectedDetail == 'InN')
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Ingredients',
// //                     style: TextStyle(
// //                         color: Colors.grey[600],
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 20),
// //                   ),
// //                   SizedBox(height: 10),
// //                   Text('4 salmon fillets (5 to 6 ounces; 140 to each)'),
// //                   Text('Kosher salt'),
// //                   Text('2 tablespoons (30ml) extra-virgin olive oil'),
// //                   Text(
// //                       'Aromatics such as fresh thyme, dill, parsley, thinly sliced shallots, and/or citrus zest (optional)'),
// //                   Text('2 teaspoons (10ml) begetable oil, if serving seared'),
// //                   SizedBox(height: 10),
// //                   Container(
// //                     padding: EdgeInsets.symmetric(vertical: 10),
// //                     decoration: BoxDecoration(
// //                         border: Border.symmetric(
// //                             horizontal: BorderSide(
// //                       color: Colors.grey,
// //                       width: 2,
// //                     ))),
// //                     child: Row(
// //                       children: [
// //                         Expanded(
// //                           child: Column(children: [
// //                             Text(
// //                               '909',
// //                               style: TextStyle(
// //                                   fontWeight: FontWeight.bold, fontSize: 20),
// //                             ),
// //                             Text(
// //                               'CALORIES/SERVING',
// //                               style: TextStyle(
// //                                   color: Colors.grey[600],
// //                                   fontWeight: FontWeight.bold,
// //                                   fontSize: 12),
// //                             )
// //                           ]),
// //                         ),
// //                         Expanded(
// //                           child: Column(children: [
// //                             Text(
// //                               '45%',
// //                               style: TextStyle(
// //                                   fontWeight: FontWeight.bold, fontSize: 20),
// //                             ),
// //                             Text(
// //                               'DAILY VALUE',
// //                               style: TextStyle(
// //                                   color: Colors.grey[600],
// //                                   fontWeight: FontWeight.bold,
// //                                   fontSize: 12),
// //                             )
// //                           ]),
// //                         ),
// //                         Expanded(
// //                           child: Column(children: [
// //                             Text(
// //                               '4',
// //                               style: TextStyle(
// //                                   fontWeight: FontWeight.bold, fontSize: 20),
// //                             ),
// //                             Text(
// //                               'SERVINGS',
// //                               style: TextStyle(
// //                                   color: Colors.grey[600],
// //                                   fontWeight: FontWeight.bold,
// //                                   fontSize: 12),
// //                             )
// //                           ]),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: 20),
// //                   Column(
// //                     children: [
// //                       _buildNutrientRow('Fat', '62g', '96%'),
// //                       _buildNutrientRow('Saturated', '0g', '0%'),
// //                       _buildNutrientRow('Trans', '22g', '0%'),
// //                       _buildNutrientRow('Monounsaturated', '17g', '0%'),
// //                       _buildNutrientRow('Polyunsaturated', '17g', '0%'),
// //                       _buildNutrientRow('Carbs', '1g', '0%'),
// //                       _buildNutrientRow('Carbs (net)', '0g', '0%'),
// //                       _buildNutrientRow('Fiber', '1g', '2%'),
// //                       _buildNutrientRow('Sugars', '0g', '0%'),
// //                       _buildNutrientRow('Sugars, added', '0g', '0%'),
// //                       _buildNutrientRow('Protein', '81g', '162%'),
// //                       _buildNutrientRow('Cholesterol', '218mg', '73%'),
// //                       _buildNutrientRow('Sodium', '952mg', '40%'),
// //                       _buildNutrientRow('Calcium', '53mg', '5%'),
// //                       _buildNutrientRow('Magnesium', '113mg', '27%'),
// //                       _buildNutrientRow('Potassium', '1462mg', '31%'),
// //                       _buildNutrientRow('Iron', '2mg', '12%'),
// //                       _buildNutrientRow('Zinc', '2mg', '14%'),
// //                       _buildNutrientRow('Phosphorus', '955g', '136%'),
// //                       _buildNutrientRow('Vitamin A', '239mg', '27%'),
// //                       _buildNutrientRow('Vitamin C', '22mg', '24%'),
// //                       _buildNutrientRow('Thiamin (B1)', '1mg', '68%'),
// //                       _buildNutrientRow('Riboflavin (B2)', '1mg', '49%'),
// //                       _buildNutrientRow('Niacin (B3)', '34mg', '215%'),
// //                     ],
// //                   ),
// //                   SizedBox(height: 20),
// //                   Text(
// //                     'Calories: ${widget.menuItem.calories} Kcal',
// //                     style: TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   SizedBox(height: 10),
// //                   Text(
// //                     'Cooking Technique:',
// //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// //                   ),
// //                   Text(
// //                     widget.menuItem.cookingTechnique.isNotEmpty
// //                         ? widget.menuItem.cookingTechnique
// //                         : 'Not specified',
// //                     style: TextStyle(fontSize: 14),
// //                   ),
// //                   SizedBox(height: 10),
// //                   Text(
// //                     'Recipe:',
// //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// //                   ),
// //                   Text(
// //                     widget.menuItem.cookingRecipe.isNotEmpty
// //                         ? widget.menuItem.cookingRecipe
// //                         : 'No recipe available',
// //                     style: TextStyle(fontSize: 14),
// //                   ),
// //                 ],
// //               ),
// //             if (_selectedDetail == 'Directions')
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Directions',
// //                     style: TextStyle(
// //                         color: Colors.grey[600],
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 20),
// //                   ),
// //                   SizedBox(height: 10),
// //                   Text('1. Season salmon generously with salt on all sides.'),
// //                   Text(
// //                       '2. Place salmon in a single layer in a gallon-size zipper-lock bag, or in batches in quart-size bags. Add olive oil to bag or divide it between the smaller bags. Add aromatics to bags, if using. Close bags, place in refrigerator, and let salmon rest for at least 30 minutes or up to overnight.'),
// //                   Text(
// //                       '3. Using an immersion circulator, preheat a water bath according to the chart above and in notes section. Remove the air from the zipper-lock bags using the  water displacement method: Seal bag almost all the way, leaving about an inch open. Slowly lower bag into water bath, holding the opened end above the water level. As bag is lowered, the water pressure should force air out of it. Just  before it is totally submerged, seal bag completely. Use a rack, or clip bag to the side of cooking vessel using a binder clip, to'),
// //                   Text(''),
// //                 ],
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // Widget _buildNutrientRow(String name, String amount, String dailyValue) {
// //   return Padding(
// //     padding: const EdgeInsets.symmetric(vertical: 4.0),
// //     child: Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Expanded(flex: 5, child: Text(name, style: TextStyle(fontSize: 14))),
// //         Expanded(
// //           flex: 0,
// //           child: Text(amount,
// //               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
// //         ),
// //         // SizedBox(width: 10),
// //         Expanded(
// //           flex: 1,
// //           child: Text(
// //             dailyValue,
// //             style: TextStyle(
// //                 fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
// //             textAlign: TextAlign.end,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }

// // 3
// // import 'package:flutter/material.dart';
// // import 'package:flutter_application_1/JsonModels/menu_item.dart';

// // class FoodDetailScreen extends StatefulWidget {
// //   final MenuItem menuItem;

// //   FoodDetailScreen({required this.menuItem});

// //   @override
// //   FoodDetailScreenState createState() => FoodDetailScreenState();
// // }

// // class FoodDetailScreenState extends State<FoodDetailScreen> {
// //   String _selectedDetail = 'InN';
// //   bool _isFavorite = false;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back_ios),
// //           onPressed: () {
// //             Navigator.pop(context);
// //           },
// //         ),
// //         title: Text(
// //           widget.menuItem.name,
// //           style: TextStyle(
// //             fontWeight: FontWeight.w600,
// //             fontFamily: 'Inter',
// //             letterSpacing: 1,
// //           ),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: Icon(
// //               _isFavorite ? Icons.star : Icons.star_border,
// //               size: 34,
// //               color: _isFavorite ? Color.fromARGB(255, 255, 191, 0) : null,
// //             ),
// //             onPressed: () {
// //               setState(() {
// //                 _isFavorite = !_isFavorite;
// //               });
// //             },
// //           ),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         padding: EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             ClipRRect(
// //               borderRadius: BorderRadius.circular(15),
// //               child: Image.asset(
// //                 widget.menuItem.imagePath,
// //                 fit: BoxFit.cover,
// //                 width: double.infinity,
// //                 height: 200,
// //               ),
// //             ),
// //             SizedBox(height: 20),
// //             Text(widget.menuItem.name),
// //             SizedBox(height: 20),
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: Container(
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         setState(() {
// //                           _selectedDetail = 'InN';
// //                         });
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: _selectedDetail == 'InN'
// //                             ? Color(0xFF1F5F5B)
// //                             : Colors.grey[300],
// //                         padding: EdgeInsets.symmetric(vertical: 12),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.only(
// //                               topLeft: Radius.circular(8),
// //                               bottomLeft: Radius.circular(8)),
// //                         ),
// //                       ),
// //                       child: Text(
// //                         'Ingredients & Nutrition',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: _selectedDetail == 'InN'
// //                               ? Colors.white
// //                               : Colors.black,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 Expanded(
// //                   child: Container(
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         setState(() {
// //                           _selectedDetail = 'Directions';
// //                         });
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: _selectedDetail == 'Directions'
// //                             ? Color(0xFF1F5F5B)
// //                             : Colors.grey[300],
// //                         padding: EdgeInsets.symmetric(vertical: 12),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.only(
// //                               topRight: Radius.circular(8),
// //                               bottomRight: Radius.circular(8)),
// //                         ),
// //                       ),
// //                       child: Text(
// //                         'Directions',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: _selectedDetail == 'Directions'
// //                               ? Colors.white
// //                               : Colors.black,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: 20),
// //             if (_selectedDetail == 'InN')
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Ingredients',
// //                     style: TextStyle(
// //                         color: Colors.grey[600],
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 20),
// //                   ),
// //                   SizedBox(height: 10),
// //                   Text('4 salmon fillets (5 to 6 ounces; 140 to each)'),
// //                   Text('Kosher salt'),
// //                   Text('2 tablespoons (30ml) extra-virgin olive oil'),
// //                   Text(
// //                       'Aromatics such as fresh thyme, dill, parsley, thinly sliced shallots, and/or citrus zest (optional)'),
// //                   Text('2 teaspoons (10ml) begetable oil, if serving seared'),
// //                   SizedBox(height: 10),
// //                   Container(
// //                     padding: EdgeInsets.symmetric(vertical: 10),
// //                     decoration: BoxDecoration(
// //                         border: Border.symmetric(
// //                             horizontal: BorderSide(
// //                       color: Colors.grey,
// //                       width: 2,
// //                     ))),
// //                     child: Row(
// //                       children: [
// //                         Expanded(
// //                           child: Column(children: [
// //                             Text(
// //                               '909',
// //                               style: TextStyle(
// //                                   fontWeight: FontWeight.bold, fontSize: 20),
// //                             ),
// //                             Text(
// //                               'CALORIES/SERVING',
// //                               style: TextStyle(
// //                                   color: Colors.grey[600],
// //                                   fontWeight: FontWeight.bold,
// //                                   fontSize: 12),
// //                             )
// //                           ]),
// //                         ),
// //                         Expanded(
// //                           child: Column(children: [
// //                             Text(
// //                               '45%',
// //                               style: TextStyle(
// //                                   fontWeight: FontWeight.bold, fontSize: 20),
// //                             ),
// //                             Text(
// //                               'DAILY VALUE',
// //                               style: TextStyle(
// //                                   color: Colors.grey[600],
// //                                   fontWeight: FontWeight.bold,
// //                                   fontSize: 12),
// //                             )
// //                           ]),
// //                         ),
// //                         Expanded(
// //                           child: Column(children: [
// //                             Text(
// //                               '4',
// //                               style: TextStyle(
// //                                   fontWeight: FontWeight.bold, fontSize: 20),
// //                             ),
// //                             Text(
// //                               'SERVINGS',
// //                               style: TextStyle(
// //                                   color: Colors.grey[600],
// //                                   fontWeight: FontWeight.bold,
// //                                   fontSize: 12),
// //                             )
// //                           ]),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: 20),
// //                   Column(
// //                     children: [
// //                       _buildNutrientRow('Fat', '62g', '96%'),
// //                       _buildNutrientRow('Saturated', '0g', '0%'),
// //                       _buildNutrientRow('Trans', '22g', '0%'),
// //                       _buildNutrientRow('Monounsaturated', '17g', '0%'),
// //                       _buildNutrientRow('Polyunsaturated', '17g', '0%'),
// //                       _buildNutrientRow('Carbs', '1g', '0%'),
// //                       _buildNutrientRow('Carbs (net)', '0g', '0%'),
// //                       _buildNutrientRow('Fiber', '1g', '2%'),
// //                       _buildNutrientRow('Sugars', '0g', '0%'),
// //                       _buildNutrientRow('Sugars, added', '0g', '0%'),
// //                       _buildNutrientRow('Protein', '81g', '162%'),
// //                       _buildNutrientRow('Cholesterol', '218mg', '73%'),
// //                       _buildNutrientRow('Sodium', '952mg', '40%'),
// //                       _buildNutrientRow('Calcium', '53mg', '5%'),
// //                       _buildNutrientRow('Magnesium', '113mg', '27%'),
// //                       _buildNutrientRow('Potassium', '1462mg', '31%'),
// //                       _buildNutrientRow('Iron', '2mg', '12%'),
// //                       _buildNutrientRow('Zinc', '2mg', '14%'),
// //                       _buildNutrientRow('Phosphorus', '955g', '136%'),
// //                       _buildNutrientRow('Vitamin A', '239mg', '27%'),
// //                       _buildNutrientRow('Vitamin C', '22mg', '24%'),
// //                       _buildNutrientRow('Thiamin (B1)', '1mg', '68%'),
// //                       _buildNutrientRow('Riboflavin (B2)', '1mg', '49%'),
// //                       _buildNutrientRow('Niacin (B3)', '34mg', '215%'),
// //                     ],
// //                   ),
// //                   SizedBox(height: 20),
// //                   Text(
// //                     'Calories: ${widget.menuItem.calories} Kcal',
// //                     style: TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   SizedBox(height: 10),
// //                   Text(
// //                     'Cooking Technique:',
// //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// //                   ),
// //                   Text(
// //                     widget.menuItem.cookingTechnique.isNotEmpty
// //                         ? widget.menuItem.cookingTechnique
// //                         : 'Not specified',
// //                     style: TextStyle(fontSize: 14),
// //                   ),
// //                   SizedBox(height: 10),
// //                   Text(
// //                     'Recipe:',
// //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
// //                   ),
// //                   Text(
// //                     widget.menuItem.cookingRecipe.isNotEmpty
// //                         ? widget.menuItem.cookingRecipe
// //                         : 'No recipe available',
// //                     style: TextStyle(fontSize: 14),
// //                   ),
// //                 ],
// //               ),
// //             if (_selectedDetail == 'Directions')
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Directions',
// //                     style: TextStyle(
// //                         color: Colors.grey[600],
// //                         fontWeight: FontWeight.bold,
// //                         fontSize: 20),
// //                   ),
// //                   SizedBox(height: 10),
// //                   Text('1. Season salmon generously with salt on all sides.'),
// //                   Text(
// //                       '2. Place salmon in a single layer in a gallon-size zipper-lock bag, or in batches in quart-size bags. Add olive oil to bag or divide it between the smaller bags. Add aromatics to bags, if using. Close bags, place in refrigerator, and let salmon rest for at least 30 minutes or up to overnight.'),
// //                   Text(
// //                       '3. Using an immersion circulator, preheat a water bath according to the chart above and in notes section. Remove the air from the zipper-lock bags using the  water displacement method: Seal bag almost all the way, leaving about an inch open. Slowly lower bag into water bath, holding the opened end above the water level. As bag is lowered, the water pressure should force air out of it. Just  before it is totally submerged, seal bag completely. Use a rack, or clip bag to the side of cooking vessel using a binder clip, to'),
// //                   Text(''),
// //                 ],
// //               ),
// //           ],
// //         ),
// //       ),
// //       bottomNavigationBar: BottomAppBar(
// //         color: Colors.white, // Background color
// //         shape:
// //             CircularNotchedRectangle(), // Optional notch for FloatingActionButton
// //         child: SizedBox(
// //           width: 160,
// //           height: 50,
// //           child: ElevatedButton(
// //             onPressed: () {
// //               // Handle Add to Diary
// //             },
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: _selectedDetail == 'InN'
// //                   ? Color(0xFF1F5F5B)
// //                   : Colors.grey[300],
// //               // padding: EdgeInsets.symmetric(horizontal: 0),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //             ),
// //             child: Text(
// //               "Add to Diary",
// //               style: TextStyle(color: Colors.white, fontSize: 16),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // Widget _buildNutrientRow(String name, String amount, String dailyValue) {
// //   return Padding(
// //     padding: const EdgeInsets.symmetric(vertical: 4),
// //     child: Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Expanded(flex: 5, child: Text(name, style: TextStyle(fontSize: 14))),
// //         Expanded(
// //           flex: 0,
// //           child: Text(amount,
// //               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
// //         ),
// //         // SizedBox(width: 10),
// //         Expanded(
// //           flex: 1,
// //           child: Text(
// //             dailyValue,
// //             style: TextStyle(
// //                 fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
// //             textAlign: TextAlign.end,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }

// // 4
// // import 'package:flutter/material.dart';

// // class FoodDetailScreen extends StatelessWidget {
// //   final String foodName;
// //   final List<Map<String, String>> nutrients;

// //   const FoodDetailScreen({super.key, required this.foodName, required this.nutrients});

// //   Widget _buildNutrientRow(String name, String amount, String dailyValue) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 4),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Expanded(flex: 5, child: Text(name, style: const TextStyle(fontSize: 14))),
// //           Expanded(
// //             flex: 0,
// //             child: Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
// //           ),
// //           Expanded(
// //             flex: 1,
// //             child: Text(
// //               dailyValue,
// //               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
// //               textAlign: TextAlign.end,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text(foodName)),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text('Nutritional Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //             const SizedBox(height: 10),
// //             ...nutrients.map((nutrient) => _buildNutrientRow(
// //                   nutrient['name']!,
// //                   nutrient['amount']!,
// //                   nutrient['dailyValue']!,
// //                 )),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // Example Usage:
// // Navigator.push(
// //   context,
// //   MaterialPageRoute(
// //     builder: (context) => FoodDetailScreen(
// //       foodName: 'Green Curry Fried Rice',
// //       nutrients: [
// //         {'name': 'Calories', 'amount': '397kcal', 'dailyValue': ''},
// //         {'name': 'Fat', 'amount': '9.3g', 'dailyValue': ''},
// //         {'name': 'Saturated Fat', 'amount': '1.4g', 'dailyValue': ''},
// //         {'name': 'Carbohydrates', 'amount': '48.6g', 'dailyValue': ''},
// //         {'name': 'Sugars', 'amount': '1.8g', 'dailyValue': ''},
// //         {'name': 'Sodium', 'amount': '1201.6mg', 'dailyValue': ''},
// //         {'name': 'Protein', 'amount': '19.5g', 'dailyValue': ''},
// //         {'name': 'Cholesterol', 'amount': '32.9mg', 'dailyValue': ''},
// //       ],
// //     ),
// //   ),
// // );

// // 5
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const FoodDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  String _selectedDetail = 'InN';
  bool _isFavorite = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    var user = _auth.currentUser;
    if (user == null) return;

    var doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.recipe['label'])
        .get();

    if (doc.exists) {
      setState(() {
        _isFavorite = true;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    var user = _auth.currentUser;
    if (user == null) return;

    var favoriteRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.recipe['label']);

    if (_isFavorite) {
      // Remove from favorites
      await favoriteRef.delete();
    } else {
      // Add to favorites
      await favoriteRef.set(widget.recipe);
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    var recipe = widget.recipe;

    String imagePath =
        'assets/fetchMenu/' + recipe['label'].replaceAll(' ', '_') + '.jpg';

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['label']),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star : Icons.star_border,
              size: 34,
              color: _isFavorite ? Color.fromARGB(255, 255, 191, 0) : null,
            ),
            // onPressed: () {
            //   setState(() {
            //     _isFavorite = !_isFavorite;
            //   });
            // },
            onPressed: () {
              _toggleFavorite();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Image.asset(
                    'assets/images/default.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            const Text('Ingredients',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            for (var ingredient in recipe['ingredientLines'])
              Text('• $ingredient', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            const Text('Nutritional Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            if (recipe['totalNutrients'] != null)
              Table(
                columnWidths: {
                  0: FlexColumnWidth(2), // Nutrient Name
                  1: FlexColumnWidth(1), // Amount
                  2: FlexColumnWidth(1), // Daily %
                },
                border: TableBorder.symmetric(
                    inside: BorderSide(width: 0.3, color: Colors.grey[300]!)),
                children: [
                  for (var entry in recipe['totalNutrients'].entries)
                    _buildNutrientRow(
                      entry.value['label'] ?? 'Unknown',
                      '${entry.value['quantity']?.toStringAsFixed(2) ?? '0'} ${entry.value['unit'] ?? ''}',
                      recipe['totalDaily']?[entry.key] != null
                          ? '${recipe['totalDaily']![entry.key]['quantity']?.toStringAsFixed(2) ?? '0'}%'
                          : 'N/A',
                    ),
                ],
              ),

            // ...recipe.map((nutrient) =>
            //     _buildNutrientRow(nutrient['name']!, nutrient['amount']!)),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white, // Background color
        shape:
            CircularNotchedRectangle(), // Optional notch for FloatingActionButton
        child: SizedBox(
          width: 160,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Handle Add to Diary
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedDetail == 'InN'
                  ? Color(0xFF1F5F5B)
                  : Colors.grey[300],
              // padding: EdgeInsets.symmetric(horizontal: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Add to Diary",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

TableRow _buildNutrientRow(String name, String amount, String daily) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(name,
            style: TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(amount,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(daily,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.green[700])),
      ),
    ],
  );
}
