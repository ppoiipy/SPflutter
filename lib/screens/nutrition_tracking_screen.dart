import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:ginraidee/screens/calculate_screen.dart';
import 'package:ginraidee/screens/favorite_screen.dart';
import 'package:ginraidee/screens/homepage.dart';
import 'package:ginraidee/screens/history_screen.dart';
import 'package:ginraidee/screens/profile_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final int _currentIndex = 0;
  String selectedTab = 'Summary';
  User? user = FirebaseAuth.instance.currentUser;

  List<Map<String, dynamic>> foodLogData = [];
  DateTime selectedDate = DateTime.now();

  Map<String, bool> _isExpanded = {
    'Calories': false,
    'Protein': false,
    'Carbs': false,
    'Fats': false,
    'Fiber': false,
    'Sugar': false,
    'Sodium': false,
  };

  // MARK: initState
  @override
  void initState() {
    super.initState();
    fetchUserData();
    _loadUserData();
    _loadFoodLogData();
    // fetchWeeklyNutritionData();
    fetchCaloriesData('ENERC_KCAL', Colors.orange);
    fetchProteinData('PROCNT', Colors.blue);
    fetchCarbsData('CHOCDF', Colors.green);
    fetchFatsData('FAT', Colors.red);
    fetchFiberData('FIBTG', Colors.brown);
    fetchSugarData('SUGAR', Colors.pink);
    _updateNutrientTotals();
  }

  late List<BarChartGroupData> caloriesGroups = [];
  late List<BarChartGroupData> proteinGroups = [];
  late List<BarChartGroupData> carbsGroups = [];
  late List<BarChartGroupData> fatsGroups = [];
  late List<BarChartGroupData> fiberGroups = [];
  late List<BarChartGroupData> sugarGroups = [];

  // MARK: V1
  Future<void> fetchCaloriesData(String nutrientKey, Color color) async {
    try {
      DateTime today = selectedDate;
      List<DateTime> dates = List.generate(7, (index) {
        return today.subtract(Duration(days: 6 - index));
      });

      List<String> formattedDates = dates.map((date) {
        return DateFormat('dd/MM').format(date);
      }).toList();

      setState(() {
        days = formattedDates;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        List<double> caloriesValues = await Future.wait(dates.map((date) async {
          double total = 0;

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

          print(
              '📅 ${DateFormat('dd/MM/yyyy').format(date)} → ${snapshot.docs.length} logs found');

          for (var doc in snapshot.docs) {
            var recipe = doc['recipe'];
            if (recipe != null &&
                recipe['totalNutrients'] != null &&
                recipe['totalNutrients'][nutrientKey] != null) {
              var nutrient = recipe['totalNutrients'][nutrientKey];
              num quantity = nutrient['quantity'] ?? 0;
              String label = nutrient['label'] ?? nutrientKey;
              String unit = nutrient['unit'] ?? '';

              print('  🔹 $label: $quantity $unit');
              total += quantity.toDouble();
            } else {
              print('  ⚠️ No $nutrientKey data in one log');
            }
          }

          print(
              "✅✅ Total $nutrientKey on ${DateFormat('dd/MM').format(date)}: $total\n");
          return total;
        }));

        setState(() {
          caloriesGroups = List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: caloriesValues[index],
                  color: color,
                  width: 10,
                ),
              ],
            );
          });
        });
      }
    } catch (e) {
      print("❌ Error fetching nutrient data: $e");
      setState(() {
        caloriesGroups = [];
        days = [];
      });
    }
  }

  Future<void> fetchProteinData(String nutrientKey, Color color) async {
    try {
      DateTime today = selectedDate;
      List<DateTime> dates = List.generate(7, (index) {
        return today.subtract(Duration(days: 6 - index));
      });

      List<String> formattedDates = dates.map((date) {
        return DateFormat('dd/MM').format(date);
      }).toList();

      setState(() {
        days = formattedDates;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        List<double> values = await Future.wait(dates.map((date) async {
          double total = 0;

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

          print(
              '📅 ${DateFormat('dd/MM/yyyy').format(date)} → ${snapshot.docs.length} logs found');

          for (var doc in snapshot.docs) {
            var recipe = doc['recipe'];
            if (recipe != null &&
                recipe['totalNutrients'] != null &&
                recipe['totalNutrients'][nutrientKey] != null) {
              var nutrient = recipe['totalNutrients'][nutrientKey];
              num quantity = nutrient['quantity'] ?? 0;
              String label = nutrient['label'] ?? nutrientKey;
              String unit = nutrient['unit'] ?? '';

              print('  🔹 $label: $quantity $unit');
              total += quantity.toDouble();
            } else {
              print('  ⚠️ No $nutrientKey data in one log');
            }
          }

          print(
              "✅✅ Total $nutrientKey on ${DateFormat('dd/MM').format(date)}: $total\n");
          return total;
        }));

        setState(() {
          proteinGroups = List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index],
                  color: color,
                  width: 10,
                ),
              ],
            );
          });
        });
      }
    } catch (e) {
      print("❌ Error fetching nutrient data: $e");
      setState(() {
        proteinGroups = [];
        days = [];
      });
    }
  }

  Future<void> fetchCarbsData(String nutrientKey, Color color) async {
    try {
      DateTime today = selectedDate;
      List<DateTime> dates = List.generate(7, (index) {
        return today.subtract(Duration(days: 6 - index));
      });

      List<String> formattedDates = dates.map((date) {
        return DateFormat('dd/MM').format(date);
      }).toList();

      setState(() {
        days = formattedDates;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        List<double> caloriesValues = await Future.wait(dates.map((date) async {
          double total = 0;

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

          print(
              '📅 ${DateFormat('dd/MM/yyyy').format(date)} → ${snapshot.docs.length} logs found');

          for (var doc in snapshot.docs) {
            var recipe = doc['recipe'];
            if (recipe != null &&
                recipe['totalNutrients'] != null &&
                recipe['totalNutrients'][nutrientKey] != null) {
              var nutrient = recipe['totalNutrients'][nutrientKey];
              num quantity = nutrient['quantity'] ?? 0;
              String label = nutrient['label'] ?? nutrientKey;
              String unit = nutrient['unit'] ?? '';

              print('  🔹 $label: $quantity $unit');
              total += quantity.toDouble();
            } else {
              print('  ⚠️ No $nutrientKey data in one log');
            }
          }

          print(
              "✅✅ Total $nutrientKey on ${DateFormat('dd/MM').format(date)}: $total\n");
          return total;
        }));

        setState(() {
          carbsGroups = List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: caloriesValues[index],
                  color: color,
                  width: 10,
                ),
              ],
            );
          });
        });
      }
    } catch (e) {
      print("❌ Error fetching nutrient data: $e");
      setState(() {
        carbsGroups = [];
        days = [];
      });
    }
  }

  Future<void> fetchFatsData(String nutrientKey, Color color) async {
    try {
      DateTime today = selectedDate;
      List<DateTime> dates = List.generate(7, (index) {
        return today.subtract(Duration(days: 6 - index));
      });

      List<String> formattedDates = dates.map((date) {
        return DateFormat('dd/MM').format(date);
      }).toList();

      setState(() {
        days = formattedDates;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        List<double> caloriesValues = await Future.wait(dates.map((date) async {
          double total = 0;

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

          print(
              '📅 ${DateFormat('dd/MM/yyyy').format(date)} → ${snapshot.docs.length} logs found');

          for (var doc in snapshot.docs) {
            var recipe = doc['recipe'];
            if (recipe != null &&
                recipe['totalNutrients'] != null &&
                recipe['totalNutrients'][nutrientKey] != null) {
              var nutrient = recipe['totalNutrients'][nutrientKey];
              num quantity = nutrient['quantity'] ?? 0;
              String label = nutrient['label'] ?? nutrientKey;
              String unit = nutrient['unit'] ?? '';

              print('  🔹 $label: $quantity $unit');
              total += quantity.toDouble();
            } else {
              print('  ⚠️ No $nutrientKey data in one log');
            }
          }

          print(
              "✅✅ Total $nutrientKey on ${DateFormat('dd/MM').format(date)}: $total\n");
          return total;
        }));

        setState(() {
          fatsGroups = List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: caloriesValues[index],
                  color: color,
                  width: 10,
                ),
              ],
            );
          });
        });
      }
    } catch (e) {
      print("❌ Error fetching nutrient data: $e");
      setState(() {
        fatsGroups = [];
        days = [];
      });
    }
  }

  Future<void> fetchFiberData(String nutrientKey, Color color) async {
    try {
      DateTime today = selectedDate;
      List<DateTime> dates = List.generate(7, (index) {
        return today.subtract(Duration(days: 6 - index));
      });

      List<String> formattedDates = dates.map((date) {
        return DateFormat('dd/MM').format(date);
      }).toList();

      setState(() {
        days = formattedDates;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        List<double> caloriesValues = await Future.wait(dates.map((date) async {
          double total = 0;

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

          print(
              '📅 ${DateFormat('dd/MM/yyyy').format(date)} → ${snapshot.docs.length} logs found');

          for (var doc in snapshot.docs) {
            var recipe = doc['recipe'];
            if (recipe != null &&
                recipe['totalNutrients'] != null &&
                recipe['totalNutrients'][nutrientKey] != null) {
              var nutrient = recipe['totalNutrients'][nutrientKey];
              num quantity = nutrient['quantity'] ?? 0;
              String label = nutrient['label'] ?? nutrientKey;
              String unit = nutrient['unit'] ?? '';

              print('  🔹 $label: $quantity $unit');
              total += quantity.toDouble();
            } else {
              print('  ⚠️ No $nutrientKey data in one log');
            }
          }

          print(
              "✅✅ Total $nutrientKey on ${DateFormat('dd/MM').format(date)}: $total\n");
          return total;
        }));

        setState(() {
          fiberGroups = List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: caloriesValues[index],
                  color: color,
                  width: 10,
                ),
              ],
            );
          });
        });
      }
    } catch (e) {
      print("❌ Error fetching nutrient data: $e");
      setState(() {
        fiberGroups = [];
        days = [];
      });
    }
  }

  Future<void> fetchSugarData(String nutrientKey, Color color) async {
    try {
      DateTime today = selectedDate;
      List<DateTime> dates = List.generate(7, (index) {
        return today.subtract(Duration(days: 6 - index));
      });

      List<String> formattedDates = dates.map((date) {
        return DateFormat('dd/MM').format(date);
      }).toList();

      setState(() {
        days = formattedDates;
      });

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        List<double> caloriesValues = await Future.wait(dates.map((date) async {
          double total = 0;

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

          print(
              '📅 ${DateFormat('dd/MM/yyyy').format(date)} → ${snapshot.docs.length} logs found');

          for (var doc in snapshot.docs) {
            var recipe = doc['recipe'];
            if (recipe != null &&
                recipe['totalNutrients'] != null &&
                recipe['totalNutrients'][nutrientKey] != null) {
              var nutrient = recipe['totalNutrients'][nutrientKey];
              num quantity = nutrient['quantity'] ?? 0;
              String label = nutrient['label'] ?? nutrientKey;
              String unit = nutrient['unit'] ?? '';

              print('  🔹 $label: $quantity $unit');
              total += quantity.toDouble();
            } else {
              print('  ⚠️ No $nutrientKey data in one log');
            }
          }

          print(
              "✅✅ Total $nutrientKey on ${DateFormat('dd/MM').format(date)}: $total\n");
          return total;
        }));

        setState(() {
          sugarGroups = List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: caloriesValues[index],
                  color: color,
                  width: 10,
                ),
              ],
            );
          });
        });
      }
    } catch (e) {
      print("❌ Error fetching nutrient data: $e");
      setState(() {
        sugarGroups = [];
        days = [];
      });
    }
  }

  // MARK: V2
  // Map<String, List<BarChartGroupData>> nutrientBarGroups = {};

  // Future<void> fetchNutrientData(String nutrientKey, Color color) async {
  //   try {
  //     DateTime today = selectedDate;
  //     List<DateTime> dates = List.generate(7, (index) {
  //       return today.subtract(Duration(days: 6 - index));
  //     });

  //     List<String> formattedDates = dates.map((date) {
  //       return DateFormat('dd/MM').format(date);
  //     }).toList();

  //     setState(() {
  //       days = formattedDates;
  //     });

  //     final user = FirebaseAuth.instance.currentUser;

  //     if (user != null) {
  //       List<double> nutrientValues = await Future.wait(dates.map((date) async {
  //         double total = 0;

  //         DateTime startOfDay = DateTime(date.year, date.month, date.day);
  //         DateTime endOfDay = startOfDay
  //             .add(Duration(days: 1))
  //             .subtract(Duration(milliseconds: 1));

  //         QuerySnapshot snapshot = await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user.uid)
  //             .collection('food_log')
  //             .where('date',
  //                 isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
  //             .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
  //             .get();

  //         for (var doc in snapshot.docs) {
  //           var recipe = doc['recipe'];
  //           if (recipe != null &&
  //               recipe['totalNutrients'] != null &&
  //               recipe['totalNutrients'][nutrientKey] != null) {
  //             var nutrient = recipe['totalNutrients'][nutrientKey];
  //             num quantity = nutrient['quantity'] ?? 0;
  //             total += quantity.toDouble();
  //           }
  //         }

  //         return total;
  //       }));

  //       // Set the barGroups for the given nutrient
  //       setState(() {
  //         nutrientBarGroups[nutrientKey] = List.generate(7, (index) {
  //           return BarChartGroupData(
  //             x: index,
  //             barRods: [
  //               BarChartRodData(
  //                 toY: nutrientValues[index],
  //                 color: color,
  //                 width: 10,
  //               ),
  //             ],
  //           );
  //         });
  //       });
  //     }
  //   } catch (e) {
  //     print("❌ Error fetching nutrient data: $e");
  //     setState(() {
  //       // Handle errors (e.g., empty barGroups)
  //       nutrientBarGroups[nutrientKey] = [];
  //       days = [];
  //     });
  //   }
  // }

  Future<void> fetchUserData() async {
    try {
      // Get today's date and previous 6 days
      DateTime today = DateTime.now();
      List<DateTime> dates = List.generate(7, (index) {
        return today.subtract(Duration(days: 6 - index));
      });

      List<String> formattedDates = dates.map((date) {
        return DateFormat('dd/MM').format(date);
      }).toList();

      // Fetch data for each day in the list
      List<Map<String, int>> dailyNutrients =
          await Future.wait(dates.map((date) async {
        num cal = 0,
            protein = 0,
            carbs = 0,
            fat = 0,
            fiber = 0,
            sugar = 0,
            sodium = 0;

        DateTime startOfDay = DateTime(date.year, date.month, date.day);
        DateTime endOfDay = startOfDay
            .add(Duration(days: 1))
            .subtract(Duration(milliseconds: 1));

        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('food_log')
            .where('date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
            .get();

        for (var doc in snapshot.docs) {
          var recipe = doc['recipe'];
          var nutrients = recipe?['totalNutrients'];

          if (nutrients != null) {
            cal += (nutrients['ENERC_KCAL']?['quantity'] ?? 0).toInt();
            protein += (nutrients['PROCNT']?['quantity'] ?? 0).toInt();
            carbs += (nutrients['CHOCDF']?['quantity'] ?? 0).toInt();
            fat += (nutrients['FAT']?['quantity'] ?? 0).toInt();
            fiber += (nutrients['FIBTG']?['quantity'] ?? 0).toInt();
            sugar += (nutrients['SUGAR']?['quantity'] ?? 0).toInt();
            sodium += (nutrients['NA']?['quantity'] ?? 0).toInt();
          }
        }

        return {
          'calories': cal.toInt(),
          'protein': protein.toInt(),
          'carbs': carbs.toInt(),
          'fat': fat.toInt(),
          'fiber': fiber.toInt(),
          'sugar': sugar.toInt(),
          'sodium': sodium.toInt(),
        };
      }));

      setState(() {
        // Save this daily nutrient data for each day (past 7 days)
        weeklyData = dailyNutrients;
        days = formattedDates;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        weeklyData = [];
        days = [];
      });
    }
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

      if (foodLogSnapshot.docs.isNotEmpty && mounted) {
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

  /// Filter food logs based on the selected date
  List<Map<String, dynamic>> _getFilteredLogs() {
    return foodLogData.where((food) {
      final dynamic rawDate = food['date'];
      DateTime? logDate;

      if (rawDate is Timestamp) {
        logDate = rawDate.toDate();
      } else if (rawDate is String) {
        try {
          logDate = DateTime.parse(rawDate);
        } catch (_) {
          return false; // Invalid date string
        }
      } else {
        return false; // Not a recognized date format
      }

      return logDate.year == selectedDate.year &&
          logDate.month == selectedDate.month &&
          logDate.day == selectedDate.day;
    }).toList();
  }

  // MARK:
  // final int totalCalories = totalNutrients['calories']?.toInt() ?? 0;
  // final int totalProtein = totalNutrients['protein']?.toInt() ?? 0;
  // final int totalFat = totalNutrients['fat']?.toInt() ?? 0;
  // final int totalFiber = totalNutrients['fiber']?.toInt() ?? 0;
  // final int totalSugar = totalNutrients['sugar']?.toInt() ?? 0;
  // final int totalCarbs = totalNutrients['carbs']?.toInt() ?? 0;

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

  // MARK: V1
  // Map<String, double> _calculateTotalCalories(
  //     List<Map<String, dynamic>> logs) {
  //   double totalCalories = 0;

  //   for (var food in logs) {
  //     var recipe = food['recipe'] ?? {};
  //     var nutrients = recipe['totalNutrients'] ?? {};

  //     totalCalories += (nutrients['ENERC_KCAL']?['quantity'] ?? 0).toDouble();
  //   }

  //   return {
  //     'calories': totalCalories,
  //   };
  // }
  // MARK: V2
  double _calculateTotalCalories(List<Map<String, dynamic>> logs) {
    double totalCalories = 0;
    for (var food in logs) {
      var recipe = food['recipe'] ?? {};
      var nutrients = recipe['totalNutrients'] ?? {};
      totalCalories += (nutrients['ENERC_KCAL']?['quantity'] ?? 0).toDouble();
    }
    return totalCalories;
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
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
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

  double totalCalories = 0;
  int totalProtein = 0;
  void _updateNutrientTotals() async {
    final filteredLogs = _getFilteredLogs();
    // final totalCaloriess = _calculateTotalCalories(filteredLogs);

    // setState(() {
    totalCalories = _calculateTotalCalories(filteredLogs);
    //   // totalProtein = totalNutrients['protein']?.toInt() ?? 0;
    //   // etc.
    // });
  }

  // List<Map<String, dynamic>> filteredLogs = _getFilteredLogs();
  // Map<String, double> totalNutrients = _calculateTotalNutrients(filteredLogs);

  // final int totalCalories = totalNutrients['calories']?.toInt() ?? 0;
  // final int totalProtein = totalNutrients['protein']?.toInt() ?? 0;
  // final int totalFat = totalNutrients['fat']?.toInt() ?? 0;
  // final int totalFiber = totalNutrients['fiber']?.toInt() ?? 0;
  // final int totalSugar = totalNutrients['sugar']?.toInt() ?? 0;
  // final int totalCarbs = totalNutrients['carbs']?.toInt() ?? 0;

  // MARK: widget build
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
                  // onPressed: () {},
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
                      // MARK: V1
                      _buildCaloriesCard(
                        'Calories',
                        totalNutrients['calories']?.toInt() ?? 0,
                        // totalCalories,
                        _calculateTDEE()?.toInt() ?? 2000,
                        Icons.local_fire_department,
                        Colors.orange,
                        'kcal',
                        'Calories',
                      ),
                      _buildProteinCard(
                        'Protein',
                        totalNutrients['protein']?.toInt() ?? 0,
                        // totalProtein,
                        (userData?['weight'] != null)
                            ? (double.parse(userData!['weight']) * 0.8).toInt()
                            : 50,
                        Icons.fitness_center,
                        Colors.blue,
                        'g',
                        'Protein',
                      ),
                      _buildCarbsCard(
                        'Carbs',
                        totalNutrients['carbs']?.toInt() ?? 0,
                        300,
                        Icons.fastfood,
                        Colors.green,
                        'g',
                        'Carbs',
                      ),
                      _buildFatsCard(
                        'Fats',
                        totalNutrients['fat']?.toInt() ?? 0,
                        65,
                        Icons.opacity,
                        Colors.red,
                        'g',
                        'Fats',
                      ),
                      _buildFiberCard(
                        'Fiber',
                        totalNutrients['fiber']?.toInt() ?? 0,
                        userData?['gender'] == 'Male' ? 38 : 25,
                        Icons.eco,
                        Colors.brown,
                        'g',
                        'Fiber',
                      ),
                      _buildSugarCard(
                        'Sugar',
                        totalNutrients['sugar']?.toInt() ?? 0,
                        50,
                        Icons.icecream,
                        Colors.pink,
                        'g',
                        'Sugar',
                      ),
                      // MARK: V2
                      // _buildNutritionCard(
                      //   'Calories',
                      //   totalNutrients['calories']?.toInt() ?? 0,
                      //   _calculateTDEE()?.toInt() ?? 2000,
                      //   Icons.local_fire_department,
                      //   Colors.orange,
                      //   'kcal',
                      //   'calories',
                      //   nutrientBarGroups['calories'] ??
                      //       [], // <- pass the correct data
                      // ),
                      // _buildNutritionCard(
                      //   'Protein',
                      //   totalNutrients['protein']?.toInt() ?? 0,
                      //   _calculateTDEE()?.toInt() ?? 2000,
                      //   Icons.local_fire_department,
                      //   Colors.orange,
                      //   'kcal',
                      //   'protein',
                      //   nutrientBarGroups['protein'] ??
                      //       [], // <- pass the correct data
                      // ),
                    ],
                  ),
                )
              : SizedBox()
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

  // MARK: Card
  Widget _buildCaloriesCard(
    String title,
    int value,
    int maxValue,
    IconData icon,
    Color color,
    String unit,
    String key,
    // List<BarChartGroupData> barChartData,
  ) {
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
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              ListTile(
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color),
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
                onTap: () {
                  setState(() {
                    _isExpanded[key] = !(_isExpanded[key] ??
                        false); // Toggle the expansion state for the selected card
                  });
                },
              ),
              if (_isExpanded[key] == true) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    height: 200,
                    width: MediaQuery.sizeOf(context).width / 1.15,
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    days[value.toInt()],
                                    style: TextStyle(fontSize: 10),
                                  );
                                }),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                        barGroups: caloriesGroups,
                        // barGroups: barChartData,
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProteinCard(
    String title,
    int value,
    int maxValue,
    IconData icon,
    Color color,
    String unit,
    String key,
    // List<BarChartGroupData> barChartData,
  ) {
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
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              ListTile(
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                    if (isExceeding)
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 4),
                      //   child: Container(
                      //     height: 200,
                      //     child: BarChart(
                      //       BarChartData(
                      //         titlesData: FlTitlesData(
                      //           show: true,
                      //           bottomTitles: AxisTitles(
                      //             sideTitles: SideTitles(
                      //                 showTitles: true,
                      //                 getTitlesWidget: (value, meta) {
                      //                   return Text(
                      //                     days[value.toInt()],
                      //                     style: TextStyle(fontSize: 10),
                      //                   );
                      //                 }),
                      //           ),
                      //           leftTitles: AxisTitles(
                      //             sideTitles: SideTitles(showTitles: true),
                      //           ),
                      //         ),
                      //         borderData: FlBorderData(show: true),
                      //         gridData: FlGridData(show: true),
                      //         barGroups:
                      //             barGroups, // Using the updated barGroups
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Text(
                        '⚠ Exceeding!',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _isExpanded[key] = !(_isExpanded[key] ??
                        false); // Toggle the expansion state for the selected card
                  });
                },
              ),
              if (_isExpanded[key] == true) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    height: 200,
                    width: MediaQuery.sizeOf(context).width / 1.15,
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    days[value.toInt()],
                                    style: TextStyle(fontSize: 10),
                                  );
                                }),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                        barGroups: proteinGroups,
                        // barGroups: barChartData,
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarbsCard(
    String title,
    int value,
    int maxValue,
    IconData icon,
    Color color,
    String unit,
    String key,
    // List<BarChartGroupData> barChartData,
  ) {
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
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              ListTile(
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                    if (isExceeding)
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 4),
                      //   child: Container(
                      //     height: 200,
                      //     child: BarChart(
                      //       BarChartData(
                      //         titlesData: FlTitlesData(
                      //           show: true,
                      //           bottomTitles: AxisTitles(
                      //             sideTitles: SideTitles(
                      //                 showTitles: true,
                      //                 getTitlesWidget: (value, meta) {
                      //                   return Text(
                      //                     days[value.toInt()],
                      //                     style: TextStyle(fontSize: 10),
                      //                   );
                      //                 }),
                      //           ),
                      //           leftTitles: AxisTitles(
                      //             sideTitles: SideTitles(showTitles: true),
                      //           ),
                      //         ),
                      //         borderData: FlBorderData(show: true),
                      //         gridData: FlGridData(show: true),
                      //         barGroups:
                      //             barGroups, // Using the updated barGroups
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Text(
                        '⚠ Exceeding!',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _isExpanded[key] = !(_isExpanded[key] ??
                        false); // Toggle the expansion state for the selected card
                  });
                },
              ),
              if (_isExpanded[key] == true) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    height: 200,
                    width: MediaQuery.sizeOf(context).width / 1.15,
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    days[value.toInt()],
                                    style: TextStyle(fontSize: 10),
                                  );
                                }),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                        barGroups: carbsGroups,
                        // barGroups: barChartData,
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFatsCard(
    String title,
    int value,
    int maxValue,
    IconData icon,
    Color color,
    String unit,
    String key,
    // List<BarChartGroupData> barChartData,
  ) {
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
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              ListTile(
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                    if (isExceeding)
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 4),
                      //   child: Container(
                      //     height: 200,
                      //     child: BarChart(
                      //       BarChartData(
                      //         titlesData: FlTitlesData(
                      //           show: true,
                      //           bottomTitles: AxisTitles(
                      //             sideTitles: SideTitles(
                      //                 showTitles: true,
                      //                 getTitlesWidget: (value, meta) {
                      //                   return Text(
                      //                     days[value.toInt()],
                      //                     style: TextStyle(fontSize: 10),
                      //                   );
                      //                 }),
                      //           ),
                      //           leftTitles: AxisTitles(
                      //             sideTitles: SideTitles(showTitles: true),
                      //           ),
                      //         ),
                      //         borderData: FlBorderData(show: true),
                      //         gridData: FlGridData(show: true),
                      //         barGroups:
                      //             barGroups, // Using the updated barGroups
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Text(
                        '⚠ Exceeding!',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _isExpanded[key] = !(_isExpanded[key] ??
                        false); // Toggle the expansion state for the selected card
                  });
                },
              ),
              if (_isExpanded[key] == true) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    height: 200,
                    width: MediaQuery.sizeOf(context).width / 1.15,
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    days[value.toInt()],
                                    style: TextStyle(fontSize: 10),
                                  );
                                }),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                        barGroups: fatsGroups,
                        // barGroups: barChartData,
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiberCard(
    String title,
    int value,
    int maxValue,
    IconData icon,
    Color color,
    String unit,
    String key,
    // List<BarChartGroupData> barChartData,
  ) {
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
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              ListTile(
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                    if (isExceeding)
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 4),
                      //   child: Container(
                      //     height: 200,
                      //     child: BarChart(
                      //       BarChartData(
                      //         titlesData: FlTitlesData(
                      //           show: true,
                      //           bottomTitles: AxisTitles(
                      //             sideTitles: SideTitles(
                      //                 showTitles: true,
                      //                 getTitlesWidget: (value, meta) {
                      //                   return Text(
                      //                     days[value.toInt()],
                      //                     style: TextStyle(fontSize: 10),
                      //                   );
                      //                 }),
                      //           ),
                      //           leftTitles: AxisTitles(
                      //             sideTitles: SideTitles(showTitles: true),
                      //           ),
                      //         ),
                      //         borderData: FlBorderData(show: true),
                      //         gridData: FlGridData(show: true),
                      //         barGroups:
                      //             barGroups, // Using the updated barGroups
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Text(
                        '⚠ Exceeding!',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _isExpanded[key] = !(_isExpanded[key] ??
                        false); // Toggle the expansion state for the selected card
                  });
                },
              ),
              if (_isExpanded[key] == true) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    height: 200,
                    width: MediaQuery.sizeOf(context).width / 1.15,
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    days[value.toInt()],
                                    style: TextStyle(fontSize: 10),
                                  );
                                }),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                        barGroups: fiberGroups,
                        // barGroups: barChartData,
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSugarCard(
    String title,
    int value,
    int maxValue,
    IconData icon,
    Color color,
    String unit,
    String key,
    // List<BarChartGroupData> barChartData,
  ) {
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
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              ListTile(
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                    if (isExceeding)
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 4),
                      //   child: Container(
                      //     height: 200,
                      //     child: BarChart(
                      //       BarChartData(
                      //         titlesData: FlTitlesData(
                      //           show: true,
                      //           bottomTitles: AxisTitles(
                      //             sideTitles: SideTitles(
                      //                 showTitles: true,
                      //                 getTitlesWidget: (value, meta) {
                      //                   return Text(
                      //                     days[value.toInt()],
                      //                     style: TextStyle(fontSize: 10),
                      //                   );
                      //                 }),
                      //           ),
                      //           leftTitles: AxisTitles(
                      //             sideTitles: SideTitles(showTitles: true),
                      //           ),
                      //         ),
                      //         borderData: FlBorderData(show: true),
                      //         gridData: FlGridData(show: true),
                      //         barGroups:
                      //             barGroups, // Using the updated barGroups
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Text(
                        '⚠ Exceeding!',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _isExpanded[key] = !(_isExpanded[key] ??
                        false); // Toggle the expansion state for the selected card
                  });
                },
              ),
              if (_isExpanded[key] == true) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    height: 200,
                    width: MediaQuery.sizeOf(context).width / 1.15,
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    days[value.toInt()],
                                    style: TextStyle(fontSize: 10),
                                  );
                                }),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                        barGroups: sugarGroups,
                        // barGroups: barChartData,
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // MARK: Card Image
  Widget _buildNutritionCardWithImage(String title, int value, int maxValue,
      String imagePath, Color color, String unit, String key) {
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
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.all(20),
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: color.withOpacity(0.2)),
                  child: Image.asset(imagePath,
                      color: color, width: 40, height: 40),
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                    if (isExceeding)
                      // Container(
                      //   height: 200,
                      //   child: BarChart(
                      //     BarChartData(
                      //       titlesData: FlTitlesData(
                      //         show: true,
                      //         bottomTitles: AxisTitles(
                      //           sideTitles: SideTitles(
                      //               showTitles: true,
                      //               getTitlesWidget: (value, meta) {
                      //                 return Text(
                      //                   days[value.toInt()],
                      //                   style: TextStyle(fontSize: 10),
                      //                 );
                      //               }),
                      //         ),
                      //         leftTitles: AxisTitles(
                      //           sideTitles: SideTitles(showTitles: true),
                      //         ),
                      //       ),
                      //       borderData: FlBorderData(show: true),
                      //       gridData: FlGridData(show: true),
                      //       barGroups: barGroups, // Using the updated barGroups
                      //     ),
                      //   ),
                      // ),
                      Text(
                        '⚠ Exceeding!',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _isExpanded[key] = !_isExpanded[key]!;
                  });
                },
              ),
              if (_isExpanded[key]!) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    height: 200,
                    width: MediaQuery.sizeOf(context).width / 1.15,
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    days[value.toInt()],
                                    style: TextStyle(fontSize: 10),
                                  );
                                }),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        gridData: FlGridData(show: true),
                        // barGroups: barGroups, // Using the updated barGroups
                        barGroups: sugarGroups,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, num>> weeklyData = [
    {
      'Calories': 2000,
      'Protein': 80,
      'Carbs': 250,
      'Fats': 70,
      'Fiber': 30,
      'Sugar': 25,
      'Sodium': 1500
    },
  ];
  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Map<String, List<int>> _weeklyData = {
    'calories': [],
    'protein': [],
    'carbs': [],
    'fat': [],
    'fiber': [],
    'sugar': [],
    'sodium': [],
  };

  // Future<void> fetchWeeklyNutritionData() async {
  //   try {
  //     DateTime today = selectedDate;
  //     List<DateTime> dates = List.generate(7, (index) {
  //       return today.subtract(Duration(days: 6 - index));
  //     });

  //     List<String> formattedDates = dates.map((date) {
  //       return DateFormat('dd/MM').format(date);
  //     }).toList();

  //     setState(() {
  //       days = formattedDates;
  //     });

  //     final user = FirebaseAuth.instance.currentUser;

  //     if (user != null) {
  //       // initialize all nutrients
  //       Map<String, List<int>> weeklyNutrients = {
  //         'calories': [],
  //         'protein': [],
  //         'carbs': [],
  //         'fat': [],
  //         'fiber': [],
  //         'sugar': [],
  //         'sodium': [],
  //       };

  //       for (var date in dates) {
  //         // Declare the variables as num to avoid type issues
  //         num cal = 0,
  //             protein = 0,
  //             carbs = 0,
  //             fat = 0,
  //             fiber = 0,
  //             sugar = 0,
  //             sodium = 0;

  //         DateTime startOfDay = DateTime(date.year, date.month, date.day);
  //         DateTime endOfDay = startOfDay
  //             .add(Duration(days: 1))
  //             .subtract(Duration(milliseconds: 1));

  //         QuerySnapshot snapshot = await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user.uid)
  //             .collection('food_log')
  //             .where('date',
  //                 isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
  //             .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
  //             .get();

  //         for (var doc in snapshot.docs) {
  //           var recipe = doc['recipe'];
  //           var nutrients = recipe?['totalNutrients'];

  //           if (nutrients != null) {
  //             cal += (nutrients['ENERC_KCAL']?['quantity'] ?? 0).toDouble();
  //             protein += (nutrients['PROCNT']?['quantity'] ?? 0).toDouble();
  //             carbs += (nutrients['CHOCDF']?['quantity'] ?? 0).toDouble();
  //             fat += (nutrients['FAT']?['quantity'] ?? 0).toDouble();
  //             fiber += (nutrients['FIBTG']?['quantity'] ?? 0).toDouble();
  //             sugar += (nutrients['SUGAR']?['quantity'] ?? 0).toDouble();
  //             sodium += (nutrients['NA']?['quantity'] ?? 0).toDouble();
  //           }
  //         }

  //         weeklyNutrients['calories']!.add(cal.toInt());
  //         weeklyNutrients['protein']!.add(protein.toInt());
  //         weeklyNutrients['carbs']!.add(carbs.toInt());
  //         weeklyNutrients['fat']!.add(fat.toInt());
  //         weeklyNutrients['fiber']!.add(fiber.toInt());
  //         weeklyNutrients['sugar']!.add(sugar.toInt());
  //         weeklyNutrients['sodium']!.add(sodium.toInt());

  //         print(
  //             "Date: ${DateFormat('dd/MM').format(date)} | Cal: $cal, Protein: $protein, Carbs: $carbs, Fat: $fat, Fiber: $fiber, Sugar: $sugar, Sodium: $sodium");
  //       }

  //       // Save in state for graphing
  //       setState(() {
  //         _weeklyData = weeklyNutrients;
  //       });
  //     }
  //   } catch (e) {
  //     print("Error fetching nutrition data: $e");
  //     setState(() {
  //       _weeklyData = {};
  //       days = [];
  //     });
  //     print(weeklyData);
  //   }
  // }
}

class GraphWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text('Graph Placeholder'), // Replace with your actual graph
      ),
    );
  }
}

class NutritionGraphWidget extends StatelessWidget {
  final String title;
  final List<double> data; // Nutritional data for the graph
  final List<String> labels; // Nutritional labels for the x-axis

  NutritionGraphWidget(
      {required this.title, required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    // Check if data and labels are valid
    if (data.isEmpty || labels.isEmpty) {
      return Center(child: Text('No data available'));
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(8),
          height: 250, // Height for the graph
          child: BarChart(
            BarChartData(
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(labels[value.toInt()]);
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
              borderData: FlBorderData(show: true),
              gridData: FlGridData(show: true),
              barGroups: data
                  .asMap()
                  .map((index, value) {
                    return MapEntry(
                      index,
                      BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            color: Colors.blue, // Optionally customize
                          ),
                        ],
                      ),
                    );
                  })
                  .values
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
