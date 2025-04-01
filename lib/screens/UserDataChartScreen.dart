import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:ginraidee/screens/calorie_tracking_screen.dart';
import 'package:ginraidee/screens/calorie_tracking_next_screen.dart';

class UserDataChartScreen extends StatefulWidget {
  @override
  _UserDataChartScreenState createState() => _UserDataChartScreenState();
}

class _UserDataChartScreenState extends State<UserDataChartScreen> {
  late List<BarChartGroupData> barGroups;
  late List<String> days;

  void navigateToMealScreen(String mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CalorieTrackingNextScreen(mealType: mealType)),
    );
  }

  @override
  void initState() {
    super.initState();
    barGroups = [];
    days = [];
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Get today's date and previous 6 days
      DateTime today = DateTime.now();
      List<DateTime> dates = List.generate(7, (index) {
        return today.subtract(Duration(days: 6 - index));
      });

      // Format dates to "dd/MM" for display
      List<String> formattedDates = dates.map((date) {
        return DateFormat('dd/MM').format(date);
      }).toList();

      setState(() {
        days = formattedDates;
      });

      // Get the current user
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        List<int> caloriesSum = await Future.wait(dates.map((date) async {
          int totalCalories = 0;

          // Convert date to Firestore Timestamp range (from start to end of the day)
          DateTime startOfDay = DateTime(date.year, date.month, date.day);
          DateTime endOfDay = startOfDay
              .add(Duration(days: 1))
              .subtract(Duration(milliseconds: 1));

          QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('food_log')
              .where('date',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
              .get();

          for (var doc in snapshot.docs) {
            var recipe = doc['recipe'];
            if (recipe != null &&
                recipe['totalNutrients'] != null &&
                recipe['totalNutrients']['ENERC_KCAL'] != null) {
              num calorie =
                  recipe['totalNutrients']['ENERC_KCAL']['quantity'] ?? 0;
              totalCalories += calorie.toInt();
            }
          }

          print(
              "Date: ${DateFormat('dd/MM').format(date)}, Calories: $totalCalories");
          return totalCalories;
        }));

        setState(() {
          barGroups = List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: caloriesSum[index].toDouble(),
                  color: Colors.blue, // Bar color
                  width: 15, // Bar width
                ),
              ],
            );
          });
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        barGroups = [];
        days = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalCalorieLimit = 2000; // Replace with user's actual daily limit
    int totalCaloriesConsumed = barGroups.isNotEmpty
        ? barGroups.last.barRods[0].toY.toInt()
        : 0; // Calories consumed today
    int remainingCalories = totalCalorieLimit - totalCaloriesConsumed;

    double circleSize = 150;

    return Scaffold(
      appBar: AppBar(title: Text('User Data Chart')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Calories Intake Over the Last 7 Days',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            barGroups.isEmpty
                ? Center(child: CircularProgressIndicator())
                : AspectRatio(
                    aspectRatio: 1.7,
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text("Date"),
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  days[value.toInt()],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            axisNameWidget: Text("Calories"),
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        barGroups: barGroups,
                      ),
                    ),
                  ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CalorieTrackingScreen()));
              },
              child: Text('Cal Next Screen'),
            ),
            // Remain Calories Display
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'Today',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        remainingCalories < 0
                            ? 'You have exceeded your calorie limit'
                            : 'Calories you can still consume',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        remainingCalories.toStringAsFixed(0),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                              remainingCalories < 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget mealTypeButton(
      String mealType, IconData icon, Color color, double size) {
    return GestureDetector(
      onTap: () => navigateToMealScreen(mealType),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: size * 0.2, color: Colors.white),
            SizedBox(height: size * 0.03),
            Text(
              mealType,
              style: TextStyle(
                  fontSize: size * 0.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
