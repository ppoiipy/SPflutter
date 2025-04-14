import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ginraidee/screens/food_detail_screen.dart';
import 'package:intl/intl.dart';

import 'package:ginraidee/screens/calculate_screen.dart';
import 'package:ginraidee/screens/favorite_screen.dart';
import 'package:ginraidee/screens/homepage.dart';
import 'package:ginraidee/screens/history_screen.dart';
import 'package:ginraidee/screens/profile_screen.dart';

class NutritionScreen extends StatefulWidget {
  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int _currentIndex = 0;
  String selectedTab = 'Summary';
  User? user = FirebaseAuth.instance.currentUser;

  List<Map<String, dynamic>> foodLogData = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadFoodLog();
    _loadUserData();
    _loadFoodLogData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
          _selectedActivityLevel =
              userData?["activityLevel"] ?? "Moderately active (3-5 days/week)";
          _weightController.text = userData?["weight"].toString() ?? '';
          _heightController.text = userData?["height"].toString() ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  String formatNumber(int number) {
    return NumberFormat("#,###").format(number);
  }

  /// Fetch food logs and store them in foodLogData
  Future<void> _loadFoodLogData() async {
    if (user == null) return;

    try {
      QuerySnapshot foodLogSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('food_log')
          .get();

      if (foodLogSnapshot.docs.isNotEmpty) {
        setState(() {
          foodLogData = foodLogSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      } else {
        setState(() {
          foodLogData = [];
        });
      }
    } catch (e) {
      print('Error fetching food log data: $e');
    }
  }

  List<Map<String, dynamic>> _loggedMeals = [];

  /// Format numbers to remove extra decimal places
  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    if (value is num) return value.toStringAsFixed(2);
    return value.toString();
  }

  /// Filter food logs based on the selected date
  List<Map<String, dynamic>> _getFilteredLogs() {
    return foodLogData.where((food) {
      Timestamp? timestamp = food['date'];
      if (timestamp == null) return false;

      DateTime logDate = timestamp.toDate();
      return logDate.year == selectedDate.year &&
          logDate.month == selectedDate.month &&
          logDate.day == selectedDate.day;
    }).toList();
  }

  /// Calculate total nutrients for the selected date
  Map<String, double> _calculateTotalNutrients(
      List<Map<String, dynamic>> logs) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalSugar = 0;
    double totalCarbs = 0;

    for (var food in logs) {
      var recipe = food['recipe'] ?? {};
      var nutrients = recipe['totalNutrients'] ?? {};

      totalCalories += (nutrients['ENERC_KCAL']?['quantity'] ?? 0).toDouble();
      totalProtein += (nutrients['PROCNT']?['quantity'] ?? 0).toDouble();
      totalFat += (nutrients['FAT']?['quantity'] ?? 0).toDouble();
      totalFiber += (nutrients['FIBTG']?['quantity'] ?? 0).toDouble();
      totalSugar += (nutrients['SUGAR']?['quantity'] ?? 0).toDouble();
      totalCarbs += (nutrients['CHOCDF']?['quantity'] ?? 0).toDouble();
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'fat': totalFat,
      'fiber': totalFiber,
      'sugar': totalSugar,
      'carbs': totalCarbs,
    };
  }

  void _changeDate(int delta) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: delta));
    });
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Map<String, dynamic>? userData;

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final List<String> activityLevels = [
    "Sedentary (little to no exercise)",
    "Lightly active (1-3 days/week)",
    "Moderately active (3-5 days/week)",
    "Very active (6-7 days/week)",
    "Super active (very hard exercise, physical job)"
  ];

  String _selectedActivityLevel = "Moderately active (3-5 days/week)";

  int _calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--; // Adjust age if the birthday hasn't occurred yet this year
    }
    return age;
  }

  double? _calculateTDEE() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final dobString = userData?["dob"] ?? '';
    final gender = userData?["gender"] ?? "Male";

    if (weight == null || height == null || dobString.isEmpty) {
      return null;
    }

    // Convert dob string to DateTime with error handling
    DateTime dob;
    try {
      dob = DateTime.parse(dobString);
    } catch (e) {
      return null; // Return null if DOB is invalid
    }

    int age = _calculateAge(dob);

    // Calculate BMR using the Mifflin-St Jeor Equation
    double bmr;
    if (gender == "Male") {
      bmr = (9.99 * weight) + (6.25 * height) - (4.92 * age) + 5;
    } else {
      bmr = (9.99 * weight) + (6.25 * height) - (4.92 * age) - 161;
    }

    // Assign activity factor based on the activity level
    double activityFactor;
    switch (_selectedActivityLevel) {
      case "Sedentary (little to no exercise)":
        activityFactor = 1.2;
        break;
      case "Lightly active (1-3 days/week)":
        activityFactor = 1.375;
        break;
      case "Moderately active (3-5 days/week)":
        activityFactor = 1.55;
        break;
      case "Very active (6-7 days/week)":
        activityFactor = 1.725;
        break;
      case "Super active (very hard exercise, physical job)":
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.55; // Default to "Moderately active"
    }

    return bmr * activityFactor;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredLogs = _getFilteredLogs();
    Map<String, double> totalNutrients = _calculateTotalNutrients(filteredLogs);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nutrition Tracking',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, size: 32),
                    onPressed: () => _changeDate(-1),
                  ),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Text(
                      DateFormat('dd MMM yyyy').format(selectedDate),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, size: 32),
                    onPressed: () => _changeDate(1),
                  ),
                ],
              ),
              Positioned(
                right: 30,
                child: IconButton(
                  icon: Icon(Icons.calendar_month),
                  onPressed: _pickDate,
                ),
              ),
            ],
          ),
          selectedTab == 'Summary'
              ? Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 1),
                      _buildNutritionCard(
                        'Calories',
                        totalNutrients['calories']?.toInt() ?? 0,
                        _calculateTDEE()?.toInt() ?? 2000,
                        Icons.local_fire_department,
                        Colors.orange,
                        'kcal',
                      ),
                      _buildNutritionCard(
                        'Protein',
                        totalNutrients['protein']?.toInt() ?? 0,
                        100,
                        Icons.fitness_center,
                        Colors.blue,
                        'g',
                      ),
                      _buildNutritionCard(
                        'Carbs',
                        totalNutrients['carbs']?.toInt() ?? 0,
                        250,
                        Icons.fastfood,
                        Colors.green,
                        'g',
                      ),
                      _buildNutritionCard(
                        'Fats',
                        totalNutrients['fat']?.toInt() ?? 0,
                        70,
                        Icons.opacity,
                        Colors.red,
                        'g',
                      ),
                      _buildNutritionCard(
                        'Fiber',
                        totalNutrients['fiber']?.toInt() ?? 0,
                        40,
                        Icons.eco,
                        Colors.brown,
                        'g',
                      ),
                      _buildNutritionCard(
                        'Sugar',
                        totalNutrients['sugar']?.toInt() ?? 0,
                        30,
                        Icons.icecream,
                        Colors.pink,
                        'g',
                      ),
                      _buildNutritionCardWithImage(
                        'Sodium',
                        totalNutrients['sodium']?.toInt() ?? 0,
                        2000,
                        'assets/images/salt.png',
                        Colors.purple,
                        'mg',
                      ),
                    ],
                  ),
                )
              : _buildMealPlans()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: (index) {
          List<Widget> screens = [
            Homepage(),
            HistoryScreen(),
            FavoriteScreen(),
            CalculateScreen(),
            ProfileScreen(),
          ];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => screens[index]),
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.history,
            ),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_outlined),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            label: 'Calculate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(String title, int value, int maxValue,
      IconData icon, Color color, String unit) {
    bool isExceeding = value > maxValue;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.15),
        margin: EdgeInsets.symmetric(vertical: 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(15),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: color.withOpacity(0.2)),
              child: Icon(icon, color: color, size: 40),
            ),
            title: Text(
              title,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            subtitle: Text(
              'Max: ${formatNumber(maxValue)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${formatNumber(value)} $unit',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color),
                ),
                if (isExceeding)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '⚠ Exceeding!',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionCardWithImage(String title, int value, int maxValue,
      String imagePath, Color color, String unit) {
    bool isExceeding = value > maxValue;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.15),
        margin: EdgeInsets.symmetric(vertical: 0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(20),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: color.withOpacity(0.2)),
              child:
                  Image.asset(imagePath, color: color, width: 40, height: 40),
            ),
            title: Text(
              title,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            subtitle: Text(
              'Max: ${formatNumber(maxValue)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${formatNumber(value)} $unit',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color),
                ),
                if (isExceeding)
                  Text(
                    '⚠ Exceeding!',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealPlans() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildMealCategory('Breakfast'),
            _buildMealCategory('Lunch'),
            _buildMealCategory('Dinner'),
            _buildMealCategory('Snack'),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCategory(String category) {
    // Filter meals by selected date and category
    List<Map<String, dynamic>> meals =
        _loggedMeals.where((meal) => meal['mealType'] == category).toList();

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          meals.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("No meals logged"),
                )
              : Column(
                  children: meals.map((meal) {
                    var recipe = meal['recipe'];
                    return ListTile(
                      leading: Image.asset(
                        'assets/fetchMenu/' +
                            recipe['label'].replaceAll(' ', '_') +
                            '.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/default.png', // Fallback image
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      title: Text(recipe['label'] ?? 'Unknown Recipe'),
                      subtitle: Text(
                          "${formatNumber(recipe['totalNutrients']['ENERC_KCAL']['quantity'].toInt())} kcal"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeMeal(meal),
                      ),
                      onTap: () {
                        logRecipeClick(recipe['label'], recipe['shareAs']);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetailScreen(
                              recipe: recipe,
                              selectedDate: selectedDate,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _loadFoodLog() async {
    var user = _auth.currentUser;
    if (user == null) return;

    // Format the date range based on the selected date (start of day to end of day)
    DateTime startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    DateTime endOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day + 1);

    // Convert to Firestore-compatible DateTime objects
    var startTimestamp = Timestamp.fromDate(startOfDay);
    var endTimestamp = Timestamp.fromDate(endOfDay);

    var snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('food_log')
        .where('date', isGreaterThanOrEqualTo: startTimestamp)
        .where('date', isLessThan: endTimestamp)
        .get();

    setState(() {
      _loggedMeals = snapshot.docs.map((doc) => doc.data()).toList();
      print("Loaded meals: $_loggedMeals");
    });
  }

  Future<void> _removeMeal(Map<String, dynamic> meal) async {
    var user = _auth.currentUser;
    if (user == null) return;

    var query = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('food_log')
        .where('recipe.label', isEqualTo: meal['recipe']['label'])
        .where('mealType', isEqualTo: meal['mealType'])
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }

    _loadFoodLog();
  }

  Future<void> logRecipeClick(String recipeLabel, String recipeShareAs) async {
    try {
      // Get the current user's ID (from FirebaseAuth)
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get reference to the user's 'clicks' subcollection
        CollectionReference clicks = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('clicks');

        // Reference to the recipe document using the recipeLabel as document ID
        DocumentReference recipeRef = clicks.doc(recipeLabel);

        // Get the document to check if it exists
        DocumentSnapshot snapshot = await recipeRef.get();

        // If the document exists, increment the click count
        if (snapshot.exists) {
          // Update the existing click count
          await recipeRef.update({
            'clickCount': FieldValue.increment(1),
          });
        } else {
          // If the document doesn't exist, create a new one with clickCount = 1
          await recipeRef.set({
            'clickCount': 1,
            'shareAs': recipeShareAs,
          });
        }

        print('Click logged successfully for $recipeLabel!');
      } else {
        print('User is not logged in.');
      }
    } catch (e) {
      print('Error logging click: $e');
    }
  }
}
