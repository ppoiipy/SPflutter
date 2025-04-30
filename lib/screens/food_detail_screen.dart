import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final DateTime? selectedDate;

  const FoodDetailScreen({super.key, required this.recipe, this.selectedDate});

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final String _selectedDetail = 'InN';
  bool _isFavorite = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _loadUserAllergies();
  }

  Set<String> _userAllergies = {};

  void _loadUserAllergies() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final userData = doc.data();
    if (userData == null) return;

    // Get the user's allergies from Firebase
    final dynamic allergiesRaw = userData['foodAllergy'];
    final Set<String> userAllergies = <String>{
      if (allergiesRaw is List)
        ...allergiesRaw.map((e) => e.toString().toLowerCase()),
      if (allergiesRaw is String) allergiesRaw.toLowerCase(),
    };

    // Assuming this is a StatefulWidget, update the state with the user's allergies
    setState(() {
      _userAllergies = userAllergies;
    });
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

  // MARK: V1
  // Future<void> _toggleLog(String mealType) async {
  //   var user = _auth.currentUser;
  //   if (user == null) return;

  //   var logRef =
  //       _firestore.collection('users').doc(user.uid).collection('food_log');

  //   DateTime dateToLog = widget.selectedDate ?? DateTime.now();
  //   Timestamp firestoreTimestamp = Timestamp.fromDate(dateToLog);
  //   Timestamp loggedDate = Timestamp.fromDate(DateTime.now());

  //   // Always add the log without checking for existing entries
  //   await logRef.add({
  //     'recipe': widget.recipe,
  //     'mealType': mealType,
  //     'date': firestoreTimestamp,
  //     'loggedDate': loggedDate,
  //   });

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("${widget.recipe['label']} added to $mealType")),
  //   );
  // }
  // MARK: V2
  Future<void> _toggleLog(String mealType) async {
    var user = _auth.currentUser;
    if (user == null) return;

    var logRef =
        _firestore.collection('users').doc(user.uid).collection('food_log');

    Timestamp firestoreTimestamp = Timestamp.fromDate(selectedDate);
    Timestamp loggedDate = Timestamp.fromDate(DateTime.now());

    await logRef.add({
      'recipe': widget.recipe,
      'mealType': mealType,
      'date': firestoreTimestamp,
      'loggedDate': loggedDate,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${widget.recipe['label']} added to $mealType on ${DateFormat('dd MMM yyyy').format(selectedDate)}",
        ),
      ),
    );
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (newSelectedDate != null && newSelectedDate != selectedDate) {
      setState(() {
        selectedDate = newSelectedDate;
      });
    }
  }

  void _changeDate(int dayOffset) async {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: dayOffset));
    });
  }

  void _showMealTypeSelection() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Text(
                    "Select Date & Meal",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F5F5B),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Date Selector Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_left,
                            color: Color(0xFF1F5F5B), size: 28),
                        onPressed: () {
                          setState(() {
                            selectedDate =
                                selectedDate.subtract(Duration(days: 1));
                          });
                          setModalState(() {});
                        },
                      ),
                      GestureDetector(
                        onTap: () async {
                          DateTime? newSelectedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (newSelectedDate != null &&
                              newSelectedDate != selectedDate) {
                            setState(() {
                              selectedDate = newSelectedDate;
                            });
                            setModalState(() {});
                          }
                          _pickDate();
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F2F1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            DateFormat('dd MMM yyyy').format(selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F5F5B),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_right,
                            color: Color(0xFF1F5F5B), size: 28),
                        onPressed: () {
                          setState(() {
                            selectedDate = selectedDate.add(Duration(days: 1));
                          });
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Meal Options
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map(
                      (meal) {
                        return GestureDetector(
                          onTap: () {
                            _toggleLog(meal);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFF1F5F5B),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Text(
                              meal,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDiaryOption(String mealType) {
    return ListTile(
      title: Text(mealType, style: TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        _addToDiary(mealType, widget.selectedDate);
      },
    );
  }

  Future<void> _addToDiary(String mealType, DateTime? selectedDate) async {
    var user = _auth.currentUser;
    if (user == null) return;

    DateTime dateToLog = selectedDate ?? DateTime.now();
    Timestamp firestoreTimestamp = Timestamp.fromDate(dateToLog);
    Timestamp loggedDate = Timestamp.fromDate(DateTime.now());

    await _firestore.collection('users').doc(user.uid).collection('diary').add({
      'mealType': mealType,
      'recipe': widget.recipe,
      'date': firestoreTimestamp, // The date user chose (or today)
      'loggedDate': loggedDate, // The actual time this meal was logged
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.recipe['label']} added to $mealType!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    var recipe = widget.recipe;

    String imagePath =
        '${'assets/fetchMenu/' + recipe['label']?.toLowerCase().replaceAll(' ', '_')}.jpg';

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['label']),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new_rounded)),
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
            Container(
              color: Colors.grey[600],
              width: MediaQuery.sizeOf(context).width,
              height: 1,
            ),
            const SizedBox(height: 10),
            for (var ingredient in recipe['ingredientLines'])
              Text('• $ingredient', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            const Text('Cautions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              color: Colors.grey[600],
              width: MediaQuery.sizeOf(context).width,
              height: 1,
            ),
            const SizedBox(height: 10),
            if (_userAllergies.isNotEmpty)
              for (var caution in recipe['cautions'])
                Text(
                  '• $caution',
                  style: TextStyle(
                    fontSize: 14,
                    color: _userAllergies.contains(caution.toLowerCase())
                        ? Colors.red
                        : Colors.black,
                    fontWeight: _userAllergies.contains(caution.toLowerCase())
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
            if (_userAllergies.isEmpty)
              for (var caution in recipe['cautions'])
                Text(
                  '• $caution',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
            const SizedBox(height: 20),
            const Text('Nutritional Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Nutrient Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Amount',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: Center(
                //     child: Text(
                //       'Daily %',
                //       style: TextStyle(fontWeight: FontWeight.bold),
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              color: Colors.grey,
              width: MediaQuery.sizeOf(context).width,
              height: 1,
            ),
            const SizedBox(height: 10),
            if (recipe['totalNutrients'] != null)
              Table(
                columnWidths: {
                  0: FlexColumnWidth(2), // Nutrient Name
                  1: FlexColumnWidth(1), // Amount
                  // 2: FlexColumnWidth(1), // Daily %
                },
                border: TableBorder.symmetric(
                    inside: BorderSide(width: 0.3, color: Colors.grey[300]!)),
                children: [
                  for (var entry in recipe['totalNutrients'].entries)
                    _buildNutrientRow(
                      entry.value['label'] ?? 'Unknown',
                      '${entry.value['quantity']?.toStringAsFixed(2) ?? '0'} ${entry.value['unit'] ?? ''}',
                      // recipe['totalDaily'] != null &&
                      //         recipe['totalDaily']?[entry.key] != null
                      //     ? '${recipe['totalDaily']?[entry.key]['quantity']?.toStringAsFixed(2) ?? '0'}%'
                      //     : 'N/A',
                    ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        child: SizedBox(
          width: 160,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              _showMealTypeSelection();
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

// TableRow _buildNutrientRow(String name, String amount, String daily) {
//   const importantNutrients = {
//     'Energy',
//     'Protein',
//     'Fat',
//     'Carbs',
//     'Sodium',
//     'Fiber',
//     'Sugars'
//   };

//   final isImportant = importantNutrients.contains(name);
//   final textColor = isImportant ? Colors.black : Colors.grey;

//   return TableRow(
//     children: [
//       Padding(
//         padding: const EdgeInsets.symmetric(vertical: 5),
//         child: Text(name,
//             style: TextStyle(
//                 fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
//       ),
//       Padding(
//         padding: const EdgeInsets.symmetric(vertical: 5),
//         child: Text(
//           amount,
//           style: TextStyle(
//               fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
//           textAlign: TextAlign.center,
//         ),
//       ),
//       Padding(
//         padding: const EdgeInsets.symmetric(vertical: 5),
//         child: Text(
//           daily,
//           style: TextStyle(
//               fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     ],
//   );
// }

TableRow _buildNutrientRow(
  String name,
  String amount,
) {
  const importantNutrients = {
    'Energy',
    'Protein',
    'Fat',
    'Total Fat',
    'Carbs',
    'Carbohydrates',
    'Sodium',
    'Fiber',
    'Dietary Fiber',
    'Sugars',
    'Sugar',
  };

  final isImportant = importantNutrients.contains(name);
  final textColor = isImportant ? Colors.black : Colors.grey;

  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(name,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          amount,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
          textAlign: TextAlign.center,
        ),
      ),
      // Padding(
      //   padding: const EdgeInsets.symmetric(vertical: 5),
      //   child: Text(
      //     daily,
      //     style: TextStyle(
      //         fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
      //     textAlign: TextAlign.center,
      //   ),
      // ),
    ],
  );
}
