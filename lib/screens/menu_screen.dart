// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'fetch_food_data.dart';
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:flutter_application_1/screens/recipe_detail_screen.dart';

// // class MenuScreen extends StatefulWidget {
// //   @override
// //   _MenuScreenState createState() => _MenuScreenState();
// // }

// // class _MenuScreenState extends State<MenuScreen> {
// //   List foodItems = [];
// //   bool isLoading = false;
// //   final TextEditingController searchController = TextEditingController();

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchFoodDataFromApi("salad"); // Fetch default data on screen load
// //   }

// //   Future<void> fetchFoodDataFromApi(String query) async {
// //     setState(() {
// //       isLoading = true;
// //     });

// //     // Call the function that fetches food data
// //     List<dynamic> fetchedFoodItems = await fetchFoodData(query);

// //     setState(() {
// //       foodItems = fetchedFoodItems;
// //       isLoading = false;
// //     });

// //     print("Fetched ${foodItems.length} items.");
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Food Search")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           children: [
// //             TextField(
// //               controller: searchController,
// //               decoration: InputDecoration(
// //                 hintText: 'Enter ingredient', // Similar to homepage
// //                 enabledBorder: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(15),
// //                   borderSide: BorderSide(color: Colors.transparent),
// //                 ),
// //                 filled: true,
// //                 fillColor:
// //                     Colors.grey[250], // Same background color as homepage
// //                 prefixIcon: IconButton(
// //                   icon: Icon(Icons.search),
// //                   onPressed: () {
// //                     fetchFoodDataFromApi(searchController.text.trim());
// //                   },
// //                 ),
// //                 hintStyle: TextStyle(
// //                     color: Colors.grey[700]), // Match the homepage text style
// //               ),
// //             ),
// //             SizedBox(height: 20),
// //             isLoading
// //                 ? CircularProgressIndicator()
// //                 : Expanded(
// //                     child: foodItems.isEmpty
// //                         ? Center(child: Text("No food found"))
// //                         : ListView.builder(
// //                             itemCount: foodItems.length,
// //                             itemBuilder: (context, index) {
// //                               var food = foodItems[index]['food'];
// //                               return ListTile(
// //                                 leading: CachedNetworkImage(
// //                                   imageUrl: food['image'] ?? '',
// //                                   width: 50,
// //                                   height: 50,
// //                                   fit: BoxFit.cover,
// //                                   placeholder: (context, url) =>
// //                                       CircularProgressIndicator(), // Shows a loading spinner
// //                                   errorWidget: (context, url, error) =>
// //                                       Image.asset(
// //                                     'assets/images/default.png',
// //                                     width: 50,
// //                                     height: 50,
// //                                     fit: BoxFit.cover,
// //                                   ),
// //                                 ),
// //                                 title: Text(food['label'] ?? "Unknown"),
// //                                 subtitle: Text(
// //                                     "Calories: ${food['nutrients']['ENERC_KCAL'] ?? 'N/A'} kcal"),
// //                                 onTap: () {
// //                                   Navigator.push(
// //                                     context,
// //                                     MaterialPageRoute(
// //                                       builder: (context) => RecipeDetailScreen(
// //                                         recipe: food,
// //                                       ),
// //                                     ),
// //                                   );
// //                                 },
// //                               );
// //                             },
// //                           ),
// //                   ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // 2
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/SQLite/sqlite.dart';
// import 'package:flutter_application_1/JsonModels/menu_item.dart';
// import 'package:flutter_application_1/screens/food_detail_screen.dart';

// class MenuScreen extends StatefulWidget {
//   const MenuScreen({super.key});

//   @override
//   MenuScreenState createState() => MenuScreenState();
// }

// class MenuScreenState extends State<MenuScreen> {
//   final List<MenuItem> menuItems = [
//     MenuItem(
//       name: 'Sous Vide City Ham With Balsamic',
//       imagePath: 'assets/images/menu/sousvide.png',
//       calories: 140,
//       cookingTechnique: '',
//       cookingRecipe: '',
//     ),
//     MenuItem(
//       name: 'Grilled Chicken Salad',
//       imagePath: 'assets/images/default.png',
//       calories: 250,
//       cookingTechnique: '',
//       cookingRecipe: '',
//     ),
//     MenuItem(
//       name: 'Vegetable Stir Fry',
//       imagePath: 'assets/images/default.png',
//       calories: 200,
//       cookingTechnique: '',
//       cookingRecipe: '',
//     ),
//     MenuItem(
//       name: 'Pasta Primavera',
//       imagePath: 'assets/images/default.png',
//       calories: 300,
//       cookingTechnique: '',
//       cookingRecipe: '',
//     ),
//     MenuItem(
//       name: 'Beef Tacos',
//       imagePath: 'assets/images/default.png',
//       calories: 350,
//       cookingTechnique: '',
//       cookingRecipe: '',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(children: [
//           SizedBox(height: 30),
//           Container(
//             child: AppBar(
//               centerTitle: true,
//               title: Text(
//                 'GinRaiDee',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w500,
//                   fontFamily: 'Inter',
//                   letterSpacing: 1,
//                 ),
//               ),
//             ),
//           ),

//           // Search Field
//           Column(
//             children: [
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Transform.translate(
//                   offset: Offset(20, -5),
//                   child: Text(
//                     'Search',
//                     style: TextStyleBold.boldTextStyle(),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Material(
//                   borderRadius: BorderRadius.circular(15),
//                   elevation: 4,
//                   shadowColor: Colors.black,
//                   child: TextFormField(
//                     decoration: InputDecoration(
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(15),
//                         borderSide: BorderSide(color: Colors.transparent),
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[250],
//                       prefixIcon: Icon(Icons.search),
//                       suffixIcon: GestureDetector(
//                         onTap: () {
//                           _showCalorieBottomSheet(context);
//                         },
//                         child: Icon(Icons.tune),
//                       ),
//                       hintText: 'Auto-Gen food name',
//                       hintStyle: TextStyle(
//                           color: const Color.fromARGB(255, 72, 72, 72)),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           // Popular Categories
//           SizedBox(height: 10),
//           Column(
//             children: [
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Transform.translate(
//                   offset: Offset(20, 0),
//                   child: Text(
//                     'Popular Categories',
//                     style: TextStyleBold.boldTextStyle(),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),

//               // Scroll Lists
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     Icons.tune,
//                     Icons.category,
//                     Icons.science,
//                     Icons.kitchen,
//                     Icons.warning,
//                     Icons.fastfood
//                   ].map((icon) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 5),
//                       child: Column(
//                         children: [
//                           Container(
//                             width: 50,
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[300],
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Center(
//                               child: Icon(icon, size: 30, color: Colors.black),
//                             ),
//                           ),
//                           Text(
//                             icon == Icons.edit
//                                 ? 'Edit'
//                                 : icon == Icons.category
//                                     ? 'Category'
//                                     : icon == Icons.science
//                                         ? 'Technique'
//                                         : icon == Icons.kitchen
//                                             ? 'Ingredients'
//                                             : icon == Icons.warning
//                                                 ? 'Allergy'
//                                                 : 'Calories',
//                             style: TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),

//           // Display the menu items
//           for (var item in menuItems)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FoodDetailScreen(menuItem: item),
//                     ),
//                   );
//                 },
//                 child: SizedBox(
//                   width: MediaQuery.sizeOf(context).width,
//                   height: 80,
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: 80,
//                         height: 80,
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(15),
//                           child: Image.asset(
//                             item.imagePath,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 5),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item.name,
//                             style: TextStyle(fontWeight: FontWeight.w900),
//                           ),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.local_fire_department_outlined,
//                                 color: Colors.red,
//                                 size: 17,
//                               ),
//                               Text(
//                                 '${item.calories} Kcal',
//                                 style: TextStyle(fontSize: 12),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Image.asset(
//                                 'assets/images/skillet.png',
//                                 color: Colors.yellow,
//                                 width: 17,
//                               ),
//                               Text(
//                                 '${item.cookingTechnique}',
//                                 style: TextStyle(fontSize: 14),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.receipt_long_outlined,
//                                 color: Colors.blue,
//                                 size: 17,
//                               ),
//                               Text(
//                                 '${item.cookingRecipe}',
//                                 style: TextStyle(fontSize: 14),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ]),
//       ),
//     );
//   }

//   void _showCalorieBottomSheet(BuildContext context) {
//     double _selectedCalories = 100;
//     List<String> ingredients = ['Broccoli', 'Broccoli', 'Broccoli', 'Butter'];
//     List<String> cookingTechniques = [
//       'Boiling',
//       'Frying',
//       'Baking',
//       'Roasting',
//       'Grilling',
//       'Steaming',
//       'Poaching',
//       'Broiling',
//       'ETC'
//     ];
//     Set<String> selectedCookingTechniques = {};
//     List<String> foodAllergy = [
//       'Egg',
//       'Milk',
//       'Fish',
//       'Crustacean Shellfish',
//       'Tree Nuts',
//       'Sesame',
//       'Wheat',
//       'Soybeans'
//     ];
//     Set<String> selectedFoodAllergy = {};
//     List<String> foodCategory = [
//       'Italian',
//       'Japanese',
//       'Chinese',
//       'Korean',
//       'Thai'
//     ];
//     Set<String> selectedFoodCategory = {};

//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       isScrollControlled: true,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               width: MediaQuery.sizeOf(context).width,
//               padding: const EdgeInsets.all(20),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Filter',
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Material(
//                       borderRadius: BorderRadius.circular(15),
//                       elevation: 4,
//                       shadowColor: Colors.black,
//                       child: TextFormField(
//                         decoration: InputDecoration(
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(15),
//                             borderSide: BorderSide(color: Colors.transparent),
//                           ),
//                           filled: true,
//                           fillColor: Colors.grey[250],
//                           prefixIcon: Icon(Icons.search),
//                           hintText: 'Ingredient',
//                           hintStyle: TextStyle(
//                               color: const Color.fromARGB(255, 72, 72, 72)),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 0,
//                       children: List.generate(
//                         ingredients.length,
//                         (index) => Chip(
//                           label: Text(ingredients[index]),
//                           backgroundColor: Color(0xFF39C184).withOpacity(0.5),
//                           shape: RoundedRectangleBorder(
//                               side: BorderSide(
//                                   color: Color(0xFF39C184).withOpacity(0.5),
//                                   width: 1),
//                               borderRadius: BorderRadius.circular(7)),
//                           deleteIcon: Icon(Icons.close, size: 18),
//                           onDeleted: () {
//                             setState(() {
//                               ingredients.removeAt(index);
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),

//                     // Calories
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Calories',
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Calories: ${_selectedCalories.toStringAsFixed(0)} Kcal',
//                         style: TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     Slider(
//                       value: _selectedCalories,
//                       min: 0,
//                       max: 1000,
//                       divisions: 100,
//                       label: _selectedCalories.toStringAsFixed(0),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedCalories = value;
//                         });
//                       },
//                       thumbColor: Color(0xFF1f5f5b),
//                       activeColor: Color(0xFF1f5f5b),
//                     ),
//                     SizedBox(height: 10),

//                     // Cooking Techniques
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Cooking Techniques',
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Wrap(
//                         spacing: 8,
//                         runSpacing: 0,
//                         children: List.generate(
//                           cookingTechniques.length,
//                           (index) {
//                             String technique = cookingTechniques[index];
//                             bool isSelected =
//                                 selectedCookingTechniques.contains(technique);
//                             return ChoiceChip(
//                               label: Text(technique),
//                               selected: isSelected,
//                               selectedColor: Color(0xFF39C184).withOpacity(0.5),
//                               side: BorderSide(
//                                 color: isSelected
//                                     ? Color(0xFF39C184).withOpacity(0.5)
//                                     : Colors.grey.withOpacity(0.4),
//                                 width: 1,
//                               ),
//                               onSelected: (selected) {
//                                 setState(() {
//                                   if (selected) {
//                                     selectedCookingTechniques.add(technique);
//                                   } else {
//                                     selectedCookingTechniques.remove(technique);
//                                   }
//                                 });
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),

//                     // Allergy
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Food Allergy',
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Wrap(
//                         spacing: 8,
//                         runSpacing: 0,
//                         children: List.generate(
//                           foodAllergy.length,
//                           (index) {
//                             String allergy = foodAllergy[index];
//                             bool isSelected =
//                                 selectedFoodAllergy.contains(allergy);

//                             return ChoiceChip(
//                               label: Text(allergy),
//                               selected: isSelected,
//                               selectedColor: Color(0xFF39C184).withOpacity(0.5),
//                               side: BorderSide(
//                                 color: isSelected
//                                     ? Color(0xFF39C184).withOpacity(0.5)
//                                     : Colors.grey.withOpacity(0.4),
//                                 width: 1,
//                               ),
//                               onSelected: (selected) {
//                                 setState(() {
//                                   if (selected) {
//                                     selectedFoodAllergy.add(allergy);
//                                   } else {
//                                     selectedFoodAllergy.remove(allergy);
//                                   }
//                                 });
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10),

//                     // Category
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Category',
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Wrap(
//                         spacing: 8,
//                         runSpacing: 0,
//                         children: List.generate(
//                           foodCategory.length,
//                           (index) {
//                             String category = foodCategory[index];
//                             bool isSelected =
//                                 selectedFoodCategory.contains(category);

//                             return ChoiceChip(
//                               label: Text(category),
//                               selected: isSelected,
//                               selectedColor: Color(0xFF39C184).withOpacity(0.5),
//                               side: BorderSide(
//                                 color: isSelected
//                                     ? Color(0xFF39C184).withOpacity(0.5)
//                                     : Colors.grey.withOpacity(0.4),
//                                 width: 1,
//                               ),
//                               onSelected: (selected) {
//                                 setState(() {
//                                   if (selected) {
//                                     selectedFoodCategory.add(category);
//                                   } else {
//                                     selectedFoodCategory.remove(category);
//                                   }
//                                 });
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     // Apply Button
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: Text(
//                             'Reset',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.grey[300],
//                               minimumSize: Size(120, 40),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(7))),
//                         ),
//                         ElevatedButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: Text(
//                             'Apply',
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Color(0xFF3fcc6e),
//                               minimumSize: Size(120, 40),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(7))),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class TextStyleBold {
//   static TextStyle boldTextStyle() {
//     return TextStyle(fontWeight: FontWeight.w800, fontSize: 16);
//   }
// }

// 3
// import 'package:flutter/material.dart';
// import 'food_detail_screen.dart'; // Import detail screen

// class Food {
//   final String name;
//   final String ingredients;
//   final String nutrition;

//   Food(
//       {required this.name, required this.ingredients, required this.nutrition});
// }

// class MenuScreen extends StatelessWidget {
//   List<Food> foodList = [
//     Food(
//       name: "Green Curry Fried Rice",
//       ingredients:
//           "4 cups cooked brown rice, 8 oz sliced chicken breast, 1 red bell pepper, "
//           "1 cup basil leaves, 3.5 oz eggplant, 8 kaffir lime leaves, 2 tbsp green curry paste, "
//           "2 tbsp olive oil, 2 tbsp fish sauce, ½ tsp Truvia, ½ cup water",
//       nutrition:
//           "Calories: 397 | Fat: 9.3g | Protein: 19.5g | Carbohydrates: 48.6g | Sodium: 1201.6mg",
//     ),
//     Food(
//       name: "Massaman Curry",
//       ingredients:
//           "14 oz sliced chicken breast, 1 lb diced potatoes, 2 large avocados, "
//           "3.5 oz massaman curry paste, 27 fl.oz. light coconut milk, 2 tbsp olive oil, "
//           "coriander for garnish",
//       nutrition:
//           "Calories: 779 | Fat: 45.4g | Protein: 39.1g | Carbohydrates: 51.1g | Sodium: 1845.6mg",
//     ),
//     Food(
//       name: "Beef Panang Curry",
//       ingredients:
//           "1 lb thinly sliced beef, 13.5 oz light coconut milk, 2 tbsp panang curry paste, "
//           "2 tbsp olive oil, 4-5 thinly sliced kaffir lime leaves",
//       nutrition:
//           "Calories: 339 | Fat: 20.4g | Protein: 32.3g | Carbohydrates: 4.1g | Sodium: 462.0mg",
//     ),
//     Food(
//       name: "Stir-fried Kale and Chicken Breast",
//       ingredients:
//           "1 lb chicken breast, 32 oz fresh kale, 2 tbsp canola oil, 1 tbsp oyster sauce, "
//           "2 tbsp soy sauce, 1 tsp stevia, 3 tbsp lime juice, 2 garlic cloves",
//       nutrition:
//           "Calories: 315 | Fat: 12g | Protein: 35g | Carbohydrates: 22g | Sodium: 844mg",
//     ),
//     Food(
//       name: "Black Pepper Pork Stir-Fry",
//       ingredients:
//           "2 tbsp canola oil, 1 lb pork chops sliced, 1 cup green onions chopped, "
//           "½ cup ginger, 2 Thai peppers minced, 1 cup jalapeño, 1 cup red onion, 1 cup bell pepper, "
//           "1 cup Thai basil leaves, 1 cup mushroom chopped, ½ cup cilantro, 1 tbsp oyster sauce, "
//           "2 tbsp soy sauce, 1 tsp stevia, 1 tbsp black pepper, 1 tbsp dry Thai pepper",
//       nutrition:
//           "Calories: 308 | Fat: 15g | Protein: 28g | Carbohydrates: 15g | Sodium: 692mg",
//     ),
//     Food(
//       name: "Cantaloupe with Sweet Coconut Milk",
//       ingredients:
//           "1 cantaloupe (2 lbs), 13.5 fl.oz. lite coconut milk, ⅔ cup Truvia brown sugar, "
//           "½ tsp salt, crushed ice",
//       nutrition:
//           "Calories: 114 | Fat: 2.8g | Protein: 1.4g | Carbohydrates: 27.0g | Sodium: 172.9mg",
//     ),
//     Food(
//       name: "Tomato Chicken Soup",
//       ingredients:
//           "1 chicken breast, 1 tsp ground pepper, 1 large potato, 1 onion, "
//           "8 cherry tomatoes halved, 4 stalks celery, 1 tbsp iodized soy sauce, 4 cups water",
//       nutrition:
//           "Calories: 133 | Fat: 4.0g | Protein: 11.4g | Carbohydrates: 13.0g | Sodium: 354.2mg",
//     ),
//     Food(
//       name: "Clear Soup with Chinese Cabbage, Tofu, and Minced Pork",
//       ingredients:
//           "1 head Napa cabbage, 4 stalks Chinese celery, 100g lean pork, 1 tube egg tofu, "
//           "1 tbsp iodized light soy sauce, 1 tbsp garlic, 1 tsp ground white pepper",
//       nutrition:
//           "Calories: 89 | Fat: 4.9g | Protein: 7.3g | Carbohydrates: 3.9g | Sodium: 465.9mg",
//     ),
//     Food(
//       name: "Spicy Catfish Salad (Larb Pla Duk)",
//       ingredients:
//           "2 ladles grilled catfish meat, 2 tbsp sliced shallots, 1 tbsp roasted rice, "
//           "2 tsp iodized light soy sauce, 1 tbsp lime juice, ½-1 tsp ground bird's eye chili, "
//           "1 tbsp dill leaves, 1 tsp chopped green onions, 1 ladle yardlong beans",
//       nutrition:
//           "Calories: 152 | Fat: 8.3g | Protein: 12.7g | Carbohydrates: 5.8g | Sodium: 31mg",
//     ),
//     Food(
//       name: "Stir-Fried Noodles with Chicken (Kuay Teow Kua Gai)",
//       ingredients:
//           "3 ladles wide rice noodles, 3 tbsp chicken meat, 1 egg, 2 medium tomatoes, "
//           "1 small head garlic, 2 tsp soybean oil, 1 tsp iodized light soy sauce, lettuce (optional)",
//       nutrition:
//           "Calories: 370 | Fat: 19.7g | Protein: 17.4g | Carbohydrates: 31.0g | Sodium: 241.9mg",
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Food Menu")),
//       body: ListView.builder(
//         itemCount: foodList.length,
//         itemBuilder: (context, index) {
//           final food = foodList[index];

//           return Card(
//             margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             child: ListTile(
//               title: Text(food.name),
//               subtitle: Text(food.nutrition),
//               trailing: Icon(Icons.arrow_forward_ios),
//               onTap: () {
//                 // Navigate to detail screen with food data
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => FoodDetailScreen(food: food),
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

//4
// import 'package:flutter/material.dart';
// import 'food_detail_screen.dart';
// import 'package:flutter/services.dart' show rootBundle;

// class MenuScreen extends StatefulWidget {
//   MenuScreen({super.key});

//   @override
//   _MenuScreenState createState() => _MenuScreenState();
// }

// class _MenuScreenState extends State<MenuScreen> {
//   Map<String, dynamic>? recipeData;

//   TextEditingController searchController = TextEditingController();
//   final List<Map<String, dynamic>> foods = [
//     {
//       'name': 'Green Curry Fried Rice',
//       'ingredients':
//           '4 cups cooked brown rice, 8 oz chicken breast, 1 red bell pepper, '
//               '1 cup basil leaves, 3.5 oz eggplant, 8 kaffir lime leaves, 2 tbsp green curry paste, '
//               '2 tbsp olive oil, 2 tbsp fish sauce, ½ tsp Truvia, ½ cup water.',
//       'nutrients': [
//         {'name': 'Calories', 'amount': '397 kcal'},
//         {'name': 'Fat', 'amount': '9.3g'},
//         {'name': 'Saturated Fat', 'amount': '1.4g'},
//         {'name': 'Polyunsaturated Fat', 'amount': '7.3g'},
//         {'name': 'Trans Fat', 'amount': '0.1g'},
//         {'name': 'Carbohydrates', 'amount': '48.6g'},
//         {'name': 'Sugars', 'amount': '1.8g'},
//         {'name': 'Sodium', 'amount': '1201.6mg'},
//         {'name': 'Fiber', 'amount': '4.5g'},
//         {'name': 'Protein', 'amount': '19.5g'},
//         {'name': 'Cholesterol', 'amount': '32.9mg'},
//       ],
//       'image': 'assets/images/menuThai/greenCurryFriedRice.jpg',
//     },
//     {
//       'name': 'Massaman Curry',
//       'ingredients':
//           '14 oz chicken breast, 1 lb potatoes, 2 avocados, 3.5 oz massaman curry paste, '
//               '27 fl.oz. light coconut milk, 2 tbsp olive oil, coriander (for garnish).',
//       'nutrients': [
//         {'name': 'Calories', 'amount': '779 kcal'},
//         {'name': 'Fat', 'amount': '45.4g'},
//         {'name': 'Saturated Fat', 'amount': '17.8g'},
//         {'name': 'Polyunsaturated Fat', 'amount': '8.3g'},
//         {'name': 'Trans Fat', 'amount': '0.1g'},
//         {'name': 'Carbohydrates', 'amount': '51.1g'},
//         {'name': 'Sugars', 'amount': '5.2g'},
//         {'name': 'Sodium', 'amount': '1845.6mg'},
//         {'name': 'Fiber', 'amount': '11.1g'},
//         {'name': 'Protein', 'amount': '39.1g'},
//         {'name': 'Cholesterol', 'amount': '76.7mg'},
//       ],
//       'image': 'assets/images/menuThai/massamanCurry.jpg',
//     },
//     {
//       'name': 'Beef Panang Curry',
//       'ingredients': '1 lb thinly sliced beef, 1 can (13.5 oz) light coconut milk, '
//           '2 tbsp panang curry paste, 2 tbsp olive oil, 4-5 kaffir lime leaves.',
//       'nutrients': [
//         {'name': 'Calories', 'amount': '339 kcal'},
//         {'name': 'Fat', 'amount': '20.4g'},
//         {'name': 'Saturated Fat', 'amount': '8.9g'},
//         {'name': 'Polyunsaturated Fat', 'amount': '9.7g'},
//         {'name': 'Trans Fat', 'amount': '0.3g'},
//         {'name': 'Carbohydrates', 'amount': '4.1g'},
//         {'name': 'Sugars', 'amount': '1.2g'},
//         {'name': 'Sodium', 'amount': '462.0mg'},
//         {'name': 'Fiber', 'amount': '0.0g'},
//         {'name': 'Protein', 'amount': '32.3g'},
//         {'name': 'Cholesterol', 'amount': '86.6mg'},
//       ],
//       'image': 'assets/images/menuThai/beefPanangCurry.jpg',
//     },
//     {
//       'name': 'Stir-fried Kale and Chicken Breast',
//       'ingredients': '1 lb chicken breast, 32 oz fresh kale, 2 tbsp canola oil, '
//           '1 tbsp oyster sauce, 2 tbsp soy sauce, 1 tsp stevia, 3 tbsp lime juice, 2 garlic cloves.',
//       'nutrients': [
//         {'name': 'Calories', 'amount': '315 kcal'},
//         {'name': 'Carbohydrates', 'amount': '22g'},
//         {'name': 'Protein', 'amount': '35g'},
//         {'name': 'Fat', 'amount': '12g'},
//         {'name': 'Saturated Fat', 'amount': '1g'},
//         {'name': 'Polyunsaturated Fat', 'amount': '3g'},
//         {'name': 'Cholesterol', 'amount': '73mg'},
//         {'name': 'Sodium', 'amount': '844mg'},
//         {'name': 'Potassium', 'amount': '1574mg'},
//         {'name': 'Fiber', 'amount': '1g'},
//         {'name': 'Sugar', 'amount': '1g'},
//         {'name': 'Vitamin A', 'amount': '22697 IU'},
//         {'name': 'Vitamin C', 'amount': '277 mg'},
//         {'name': 'Calcium', 'amount': '353 mg'},
//         {'name': 'Iron', 'amount': '4 mg'},
//       ],
//       'image': 'assets/images/menuThai/stirFriedKaleAndChickenBreast.jpg',
//     },
//     {
//       'name': 'Black Pepper Pork Stir-Fry',
//       'ingredients': '2 tbsp canola oil, 1 lb pork chops (sliced), 1 cup green onions (chopped), '
//           '½ cup ginger (cut into matchsticks), 2 Thai peppers (minced), 1 cup jalapeño (ends cut off), '
//           '1 cup red onion (chopped), 1 cup bell pepper (sliced), 1 cup Thai basil leaves, 1 cup mushrooms (chopped), '
//           '½ cup cilantro (optional for garnish), 1 tbsp oyster sauce (optional), 2 tbsp soy sauce, 1 tsp stevia, '
//           '1 tbsp black pepper, 1 tbsp dry Thai pepper.',
//       'nutrients': [
//         {'name': 'Calories', 'amount': '308 kcal'},
//         {'name': 'Carbohydrates', 'amount': '15g'},
//         {'name': 'Protein', 'amount': '28g'},
//         {'name': 'Fat', 'amount': '15g'},
//         {'name': 'Saturated Fat', 'amount': '3g'},
//         {'name': 'Trans Fat', 'amount': '1g'},
//         {'name': 'Cholesterol', 'amount': '76mg'},
//         {'name': 'Sodium', 'amount': '692mg'},
//         {'name': 'Potassium', 'amount': '886mg'},
//         {'name': 'Fiber', 'amount': '4g'},
//         {'name': 'Sugar', 'amount': '6g'},
//         {'name': 'Vitamin A', 'amount': '2141 IU'},
//         {'name': 'Vitamin C', 'amount': '88mg'},
//         {'name': 'Calcium', 'amount': '65mg'},
//         {'name': 'Iron', 'amount': '2mg'},
//       ],
//       'image': 'assets/images/menuThai/blackPepperPorkStirFry.jpg',
//     },
//     {
//       'name': 'Cantaloupe with Sweet Coconut Milk',
//       'ingredients':
//           '1 cantaloupe (about 2 lbs), 1 can lite coconut milk (13.5 fl.oz.), '
//               '⅔ cup Truvia brown sugar or Truvia baking blend, ½ tsp salt, crushed ice.',
//       'nutrients': [
//         {'name': 'Calories', 'amount': '114 kcal'},
//         {'name': 'Fat', 'amount': '2.8g'},
//         {'name': 'Saturated Fat', 'amount': '2.5g'},
//         {'name': 'Unsaturated Fat', 'amount': '0.0g'},
//         {'name': 'Trans Fat', 'amount': '0.0g'},
//         {'name': 'Carbohydrates', 'amount': '27.0g'},
//         {'name': 'Sugar', 'amount': '17.1g'},
//         {'name': 'Sodium', 'amount': '172.9mg'},
//         {'name': 'Fiber', 'amount': '0.8g'},
//         {'name': 'Protein', 'amount': '1.4g'},
//         {'name': 'Cholesterol', 'amount': '0.0mg'},
//       ],
//       'image': 'assets/images/menuThai/cantaloupeWithSweetCoconutMilk.jpg',
//     },
//     {
//       'name': 'Tomato Chicken Soup',
//       'ingredients':
//           '1 chicken breast, 1 tsp ground pepper, 1 large potato, 1 onion, '
//               '8 halved cherry tomatoes, 4 stalks of celery, 1 tbsp iodized soy sauce, 4 cups water.',
//       'nutrients': [
//         {'name': 'Calories', 'amount': '133 kcal'},
//         {'name': 'Carbohydrates', 'amount': '13.0g'},
//         {'name': 'Protein', 'amount': '11.4g'},
//         {'name': 'Fat', 'amount': '4.0g'},
//         {'name': 'Calcium', 'amount': '41.3mg'},
//         {'name': 'Potassium', 'amount': '769.8mg'},
//         {'name': 'Sodium', 'amount': '354.2mg'},
//         {'name': 'Fiber', 'amount': '4.4g'},
//       ],
//       'image': 'assets/images/menuThai/tomatoChickenSoup.png',
//     },
//     {
//       'name': 'Clear Soup with Chinese Cabbage, Tofu, and Minced Pork',
//       'ingredients':
//           '2 cups chicken stock, 2 cups water, 2 tbsp soy sauce, 3 tbsp fish sauce, '
//               '200g minced pork, 300g Chinese cabbage, 2 tbsp olive oil, 2 tbsp coriander leaves.',
//       'nutrients': [
//         {'name': 'Calories', 'amount': '169 kcal'},
//         {'name': 'Carbohydrates', 'amount': '9.1g'},
//         {'name': 'Protein', 'amount': '16.0g'},
//         {'name': 'Fat', 'amount': '9.5g'},
//         {'name': 'Sodium', 'amount': '783mg'},
//         {'name': 'Fiber', 'amount': '1.4g'},
//         {'name': 'Vitamin A', 'amount': '420 IU'},
//         {'name': 'Vitamin C', 'amount': '14 mg'},
//         {'name': 'Calcium', 'amount': '118 mg'},
//         {'name': 'Iron', 'amount': '2 mg'},
//       ],
//       'image':
//           'assets/images/menuThai/clearSoupWithChineseCabbageTofuAndMincedPork.png',
//     },
//     {
//       'name': 'Spicy Catfish Salad (Larb Pla Duk)',
//       'ingredients':
//           '2 lbs catfish, 1 tbsp olive oil, 1 bunch cilantro, 1 tbsp fish sauce, '
//               '2 tbsp lime juice, ½ tbsp chili powder, ½ tbsp crushed garlic, ½ tbsp ground pepper.',
//       'nutrients': [
//         {'name': 'Calories', 'amount': '290 kcal'},
//         {'name': 'Fat', 'amount': '15.0g'},
//         {'name': 'Saturated Fat', 'amount': '2.4g'},
//         {'name': 'Polyunsaturated Fat', 'amount': '4.8g'},
//         {'name': 'Trans Fat', 'amount': '0g'},
//         {'name': 'Carbohydrates', 'amount': '0.7g'},
//         {'name': 'Protein', 'amount': '45.3g'},
//         {'name': 'Sodium', 'amount': '536.7mg'},
//         {'name': 'Fiber', 'amount': '1.3g'},
//       ],
//       'image': 'assets/images/menuThai/spicyCatfishSalad(LarbPlaDuk).png',
//     },
//     {
//       'name': 'Stir-fried Noodles with Chicken (Kuay Teow Kua Gai)',
//       'ingredients':
//           '10 oz rice noodles, 1 lb chicken, 3 tbsp soy sauce, 1 tbsp sugar, '
//               '1 tbsp oyster sauce, 1 tbsp fish sauce, 2 cups spinach, 1 cup shredded carrots, '
//               '2 tbsp olive oil, 1 tbsp garlic, 1 tsp black pepper.',
//       'nutrients': [
//         {'name': 'Calories', 'amount': '411 kcal'},
//         {'name': 'Fat', 'amount': '18.0g'},
//         {'name': 'Saturated Fat', 'amount': '3.5g'},
//         {'name': 'Polyunsaturated Fat', 'amount': '2.7g'},
//         {'name': 'Trans Fat', 'amount': '0g'},
//         {'name': 'Carbohydrates', 'amount': '36.0g'},
//         {'name': 'Sugars', 'amount': '6.7g'},
//         {'name': 'Protein', 'amount': '32.0g'},
//         {'name': 'Sodium', 'amount': '945mg'},
//         {'name': 'Fiber', 'amount': '4.5g'},
//         {'name': 'Cholesterol', 'amount': '68mg'},
//       ],
//       'image':
//           'assets/images/menuThai/stirFriedNoodlesWithChicken(KuayTeowKuaGai).png',
//     },
//   ];

//   List<Map<String, dynamic>> filteredFoods = [];

//   Future<void> loadRecipe() async {
//     String jsonString =
//         await rootBundle.loadString('assets/recipe_output.json');
//     setState(() {
//       recipeData = jsonDecode(jsonString);
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     filteredFoods = foods;
//     loadRecipe();
//   }

//   void searchFoods(String query) {
//     final results = foods.where((food) {
//       final foodName = food['name'].toLowerCase();
//       return foodName.contains(query.toLowerCase());
//     }).toList();

//     setState(() {
//       filteredFoods = results;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Menu')),
//       body: Column(
//         children: [
//           // Search TextField
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: searchController,
//               onChanged: (value) {
//                 searchFoods(value.trim());
//               },
//               decoration: InputDecoration(
//                 hintText: 'Search for a dish',
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide(color: Colors.transparent),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[250],
//                 prefixIcon: IconButton(
//                   icon: Icon(Icons.search),
//                   onPressed: () {
//                     searchFoods(searchController.text.trim());
//                   },
//                 ),
//                 hintStyle: TextStyle(color: Colors.grey[700]),
//               ),
//             ),
//           ),

//           // Horizontal row icons
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 Icons.tune,
//                 Icons.category,
//                 Icons.science,
//                 Icons.kitchen,
//                 Icons.warning,
//                 Icons.fastfood
//               ].map((icon) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 5),
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Center(
//                           child: Icon(icon, size: 30, color: Colors.black),
//                         ),
//                       ),
//                       Text(
//                         icon == Icons.tune
//                             ? 'Edit'
//                             : icon == Icons.category
//                                 ? 'Category'
//                                 : icon == Icons.science
//                                     ? 'Technique'
//                                     : icon == Icons.kitchen
//                                         ? 'Ingredients'
//                                         : icon == Icons.warning
//                                             ? 'Allergy'
//                                             : 'Calories',
//                         style: TextStyle(fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // Food List
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredFoods.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(filteredFoods[index]['name']),
//                   subtitle: Row(
//                     children: [
//                       Icon(
//                         Icons.local_fire_department_outlined,
//                         color: Colors.red,
//                         size: 17,
//                       ),
//                       Text(
//                         "Calories: ${filteredFoods[index]['nutrients'][0]['amount'] ?? 'N/A'}",
//                       ),
//                     ],
//                   ),
//                   leading: SizedBox(
//                     width: 80,
//                     height: 80,
//                     child: Image.asset(
//                       filteredFoods[index]['image'],
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   trailing: const Icon(Icons.arrow_forward),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => FoodDetailScreen(
//                           foodName: foods[index]['name'],
//                           ingredients: foods[index]['ingredients'],
//                           nutrients: List<Map<String, String>>.from(
//                               foods[index]['nutrients']),
//                           image: foods[index]['image'],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// 5
import 'dart:convert';
import 'package:flutter/services.dart'; // Import this to use rootBundle
import 'package:flutter/material.dart';
import 'food_detail_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> recipes = [];
  List<dynamic> filteredRecipes = [];
  TextEditingController searchController = TextEditingController();
  String selectedCuisineType = "All"; // Default value for cuisine type

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  // Load data from JSON file in assets/fetchMenu
  void loadJsonData() async {
    String jsonData =
        await rootBundle.loadString('assets/fetchMenu/recipe_output.json');
    Map<String, dynamic> jsonMap = json.decode(jsonData);
    recipes = jsonMap['hits'].map((hit) => hit['recipe']).toList();
    setState(() {
      filteredRecipes = List.from(recipes);
    });
  }

  // Filter recipes based on search query and cuisineType
  void filterRecipes(String query, String cuisineType) {
    setState(() {
      filteredRecipes = recipes
          .where((recipe) =>
              recipe['label'].toLowerCase().contains(query.toLowerCase()) &&
              (cuisineType == "All" ||
                  recipe['cuisineType']
                      .toString()
                      .toLowerCase()
                      .contains(cuisineType.toLowerCase()) ||
                  recipe['label']
                      .toString()
                      .toLowerCase()
                      .contains(cuisineType.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Recipe Search',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Field
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: Offset(20, -5),
                  child: Text(
                    'Search',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Material(
                  borderRadius: BorderRadius.circular(15),
                  elevation: 4,
                  shadowColor: Colors.black,
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      filled: true,
                      fillColor: Colors.grey[250],
                      prefixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          filterRecipes(
                              searchController.text, selectedCuisineType);
                        },
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _showCalorieBottomSheet(context);
                        },
                        child: Icon(Icons.tune),
                      ),
                      hintText: 'Auto-Gen food name',
                      hintStyle: TextStyle(
                          color: const Color.fromARGB(255, 72, 72, 72)),
                    ),
                    // onChanged: (query) {
                    //   filterRecipes(query, selectedCuisineType);
                    // },
                    onFieldSubmitted: (query) {
                      filterRecipes(query, selectedCuisineType);
                    },
                  ),
                ),
              ),
            ],
          ),

          // Cuisine Type Filter Dropdown
          // Padding(
          //   padding: EdgeInsets.all(10),
          //   child: DropdownButton<String>(
          //     value: selectedCuisineType,
          //     onChanged: (String? newValue) {
          //       setState(() {
          //         selectedCuisineType = newValue!;
          //       });
          //       filterRecipes(searchController.text, selectedCuisineType);
          //     },
          //     items: <String>[
          //       'All',
          //       'Italian',
          //       'Chinese',
          //       'Indian',
          //       'Mexican',
          //       'American',
          //       'Japanese',
          //       'Asian',
          //       'Thai'
          //     ].map<DropdownMenuItem<String>>((String value) {
          //       return DropdownMenuItem<String>(
          //         value: value,
          //         child: Text(value),
          //       );
          //     }).toList(),
          //   ),
          // ),

          // Scroll List
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Icons.tune,
                  Icons.category,
                  Icons.science,
                  Icons.kitchen,
                  Icons.warning,
                  Icons.fastfood
                ].map((icon) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(icon, size: 30, color: Colors.black),
                          ),
                        ),
                        Text(
                          icon == Icons.tune
                              ? 'Edit'
                              : icon == Icons.category
                                  ? 'Category'
                                  : icon == Icons.science
                                      ? 'Technique'
                                      : icon == Icons.kitchen
                                          ? 'Ingredients'
                                          : icon == Icons.warning
                                              ? 'Allergy'
                                              : 'Calories',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          SizedBox(height: 10),

          // Recipe List
          Expanded(
            child: ListView.builder(
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                var recipe = filteredRecipes[index];
                String imagePath = 'assets/fetchMenu/' +
                    recipe['label'].replaceAll(' ', '_') +
                    '.jpg';

                return ListTile(
                  leading: Image.asset(
                    imagePath,
                    width: 50,
                    height: 50,
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
                  title: Text(recipe['label']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department_outlined,
                            color: Colors.red,
                          ),
                          Text(
                              "${recipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt().toString()} ${recipe['totalNutrients']['ENERC_KCAL']['unit']}"),
                        ],
                      ),
                      Text(recipe['source'])
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _showCalorieBottomSheet(BuildContext context) {
  double _selectedCalories = 100;
  List<String> ingredients = ['Broccoli', 'Broccoli', 'Broccoli', 'Butter'];
  List<String> cookingTechniques = [
    'Boiling',
    'Frying',
    'Baking',
    'Roasting',
    'Grilling',
    'Steaming',
    'Poaching',
    'Broiling',
    'ETC'
  ];
  Set<String> selectedCookingTechniques = {};
  List<String> foodAllergy = [
    'Egg',
    'Milk',
    'Fish',
    'Crustacean Shellfish',
    'Tree Nuts',
    'Sesame',
    'Wheat',
    'Soybeans'
  ];
  Set<String> selectedFoodAllergy = {};
  List<String> foodCategory = [
    'Italian',
    'Japanese',
    'Chinese',
    'Korean',
    'Thai'
  ];
  Set<String> selectedFoodCategory = {};

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            width: MediaQuery.sizeOf(context).width,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Filter',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Material(
                    borderRadius: BorderRadius.circular(15),
                    elevation: 4,
                    shadowColor: Colors.black,
                    child: TextFormField(
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        filled: true,
                        fillColor: Colors.grey[250],
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Ingredient',
                        hintStyle: TextStyle(
                            color: const Color.fromARGB(255, 72, 72, 72)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: List.generate(
                      ingredients.length,
                      (index) => Chip(
                        label: Text(ingredients[index]),
                        backgroundColor: Color(0xFF39C184).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Color(0xFF39C184).withOpacity(0.5),
                                width: 1),
                            borderRadius: BorderRadius.circular(7)),
                        deleteIcon: Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            ingredients.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Calories
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Calories',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Calories: ${_selectedCalories.toStringAsFixed(0)} Kcal',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Slider(
                    value: _selectedCalories,
                    min: 0,
                    max: 1000,
                    divisions: 100,
                    label: _selectedCalories.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        _selectedCalories = value;
                      });
                    },
                    thumbColor: Color(0xFF1f5f5b),
                    activeColor: Color(0xFF1f5f5b),
                  ),
                  SizedBox(height: 10),

                  // Cooking Techniques
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Cooking Techniques',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 0,
                      children: List.generate(
                        cookingTechniques.length,
                        (index) {
                          String technique = cookingTechniques[index];
                          bool isSelected =
                              selectedCookingTechniques.contains(technique);
                          return ChoiceChip(
                            label: Text(technique),
                            selected: isSelected,
                            selectedColor: Color(0xFF39C184).withOpacity(0.5),
                            side: BorderSide(
                              color: isSelected
                                  ? Color(0xFF39C184).withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.4),
                              width: 1,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedCookingTechniques.add(technique);
                                } else {
                                  selectedCookingTechniques.remove(technique);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Allergy
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Food Allergy',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 0,
                      children: List.generate(
                        foodAllergy.length,
                        (index) {
                          String allergy = foodAllergy[index];
                          bool isSelected =
                              selectedFoodAllergy.contains(allergy);

                          return ChoiceChip(
                            label: Text(allergy),
                            selected: isSelected,
                            selectedColor: Color(0xFF39C184).withOpacity(0.5),
                            side: BorderSide(
                              color: isSelected
                                  ? Color(0xFF39C184).withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.4),
                              width: 1,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedFoodAllergy.add(allergy);
                                } else {
                                  selectedFoodAllergy.remove(allergy);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Category
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Category',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 0,
                      children: List.generate(
                        foodCategory.length,
                        (index) {
                          String category = foodCategory[index];
                          bool isSelected =
                              selectedFoodCategory.contains(category);

                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor: Color(0xFF39C184).withOpacity(0.5),
                            side: BorderSide(
                              color: isSelected
                                  ? Color(0xFF39C184).withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.4),
                              width: 1,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedFoodCategory.add(category);
                                } else {
                                  selectedFoodCategory.remove(category);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Apply Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            minimumSize: Size(120, 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7))),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Apply',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3fcc6e),
                            minimumSize: Size(120, 40),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7))),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
