import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/calculate_screen.dart';
import 'package:flutter_application_1/screens/favorite_screen.dart';
import 'package:flutter_application_1/screens/homepage.dart';
import 'package:flutter_application_1/screens/menu_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:intl/intl.dart';

class NutritionScreen extends StatefulWidget {
  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int _currentIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;

  List<Map<String, dynamic>> foodLogData = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadFoodLogData();
    _loadUserData();
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

  /// Change the date by adding or subtracting days
  void _changeDate(int delta) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: delta));
    });
  }

  /// Open date picker
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_left, size: 32),
                onPressed: () => _changeDate(-1),
              ),
              GestureDetector(
                onTap: _pickDate,
                child: Text(
                  DateFormat('dd MMM yyyy').format(selectedDate),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_right, size: 32),
                onPressed: () => _changeDate(1),
              ),
            ],
          ),
          Padding(
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
          ),
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
            MenuScreen(),
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
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.food_bank_outlined), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_outlined), label: 'Favorites'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined), label: 'Calculate'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
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
}
