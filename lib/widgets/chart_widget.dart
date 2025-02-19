import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChartWidget extends StatefulWidget {
  // const ChartWidget({Key? key}) : super(key: key);

  final String selectedTrack;

  ChartWidget({required this.selectedTrack});

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  // List<BarChartGroupData> _getBarGroups() {
  //   return [
  //     BarChartGroupData(x: 1, barRods: [
  //       BarChartRodData(
  //         toY: (userData?['weight'] is double)
  //             ? userData!['weight'] as double
  //             : (double.tryParse(userData?['weight']?.toString() ?? '') ?? 0.0),
  //         color: Color(0xff4D7881),
  //       )
  //     ]),
  //     BarChartGroupData(x: 2, barRods: [
  //       BarChartRodData(
  //         toY: (userData?['weight'] is double)
  //             ? userData!['weight'] as double
  //             : (double.tryParse(userData?['weight']?.toString() ?? '') ?? 0.0),
  //         color: Color(0xff4D7881),
  //       )
  //     ]),
  //     BarChartGroupData(x: 3, barRods: [
  //       BarChartRodData(
  //         toY: (userData?['weight'] is double)
  //             ? userData!['weight'] as double
  //             : (double.tryParse(userData?['weight']?.toString() ?? '') ?? 0.0),
  //         color: Color(0xff4D7881),
  //       )
  //     ]),
  //     BarChartGroupData(x: 4, barRods: [
  //       BarChartRodData(
  //         toY: (userData?['weight'] is double)
  //             ? userData!['weight'] as double
  //             : (double.tryParse(userData?['weight']?.toString() ?? '') ?? 0.0),
  //         color: Color(0xff4D7881),
  //       )
  //     ]),
  //     BarChartGroupData(x: 5, barRods: [
  //       BarChartRodData(
  //         toY: (userData?['weight'] is double)
  //             ? userData!['weight'] as double
  //             : (double.tryParse(userData?['weight']?.toString() ?? '') ?? 0.0),
  //         color: Color(0xff4D7881),
  //       )
  //     ]),
  //     BarChartGroupData(x: 6, barRods: [
  //       BarChartRodData(
  //         toY: (userData?['weight'] is double)
  //             ? userData!['weight'] as double
  //             : (double.tryParse(userData?['weight']?.toString() ?? '') ?? 0.0),
  //         color: Color(0xff4D7881),
  //       )
  //     ]),
  //     BarChartGroupData(x: 7, barRods: [
  //       BarChartRodData(
  //         toY: (userData?['weight'] is double)
  //             ? userData!['weight'] as double
  //             : (double.tryParse(userData?['weight']?.toString() ?? '') ?? 0.0),
  //         color: Color(0xff4D7881),
  //       )
  //     ]),
  //   ];
  // }

  double _getValueForTrack(String track, Map<String, dynamic>? userData) {
    switch (track) {
      case 'Body Weight':
        return double.tryParse(userData?['weight']?.toString() ?? '') ?? 0.0;
      case 'BMI':
        return double.tryParse(userData?['bmi']?.toString() ?? '') ?? 0.0;
      case 'BMR':
        return double.tryParse(userData?['bmr']?.toString() ?? '') ?? 0.0;
      case 'TDEE':
        return double.tryParse(userData?['tdee']?.toString() ?? '') ?? 0.0;
      case 'Calorie':
        return double.tryParse(userData?['calorie']?.toString() ?? '') ?? 0.0;
      default:
        return 0.0;
    }
  }

  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

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
          weight =
              double.tryParse(userData?['weight']?.toString() ?? '0.0') ?? 0.0;
          weightGoal =
              double.tryParse(userData?['weightGoal']?.toString() ?? '0.0') ??
                  0.0;
          difference = weight - weightGoal;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  double _getWeightValue() {
    return (userData?['weight'] is double)
        ? userData!['weight'] as double
        : (double.tryParse(userData?['weight']?.toString() ?? '') ?? 0.0);
  }

  List<BarChartGroupData> _getBarGroups(String track) {
    List<double> dataPoints;

    switch (track) {
      case 'Body Weight':
        dataPoints = [60, 61, 62, 61.5, 62.3]; // Example, fetch actual data
        break;
      case 'BMI':
        dataPoints = [22.5, 22.6, 22.7, 22.65, 22.8];
        break;
      case 'BMR':
        dataPoints = [1500, 1510, 1520, 1515, 1525];
        break;
      case 'TDEE':
        dataPoints = [2000, 2050, 2100, 2150, 2200];
        break;
      case 'Calorie':
        dataPoints = [1800, 1850, 1900, 1950, 2000];
        break;
      default:
        dataPoints = [0.0];
    }

    return List.generate(dataPoints.length, (index) {
      return BarChartGroupData(
        x: index + 1,
        barRods: [
          BarChartRodData(
            toY: dataPoints[index],
            color: Color(0xff4D7881),
          ),
        ],
      );
    });
  }

  double weight = 0.0;
  double weightGoal = 0.0;
  double? difference;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (userData != null) {
      weight = double.tryParse(userData?['weight']) ?? 0.0;
      weightGoal = double.tryParse(userData?['weightGoal']) ?? 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData != null) {
      difference = weight - weightGoal;
    }

    return Column(children: [
      // Body Weight
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monitor_weight,
                        color: Color(0xff4D7881),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Body Weight',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff4D7881),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${userData?['weight'] ?? 'N/A'} kg',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff4D7881),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${difference ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: difference! > 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Goal: ${userData?['weightGoal'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Container(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: _getBarGroups(_selectedTrack),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            DateTime today = DateTime.now();
                            DateTime date = today
                                .subtract(Duration(days: 7 - value.toInt()));

                            String dateString = "${date.day}${[
                              'Jan',
                              'Feb',
                              'Mar',
                              'Apr',
                              'May',
                              'Jun',
                              'Jul',
                              'Aug',
                              'Sep',
                              'Oct',
                              'Nov',
                              'Dec'
                            ][date.month - 1]}";

                            return Text(
                              dateString,
                              style: TextStyle(fontSize: 12),
                            );
                          },
                          reservedSize: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // BMI

      // BMI

      // BMI

      // Calorie
    ]);
  }

  String _selectedTrack = 'Body Weight';
  void _onSelectTrack(String track) {
    setState(() {
      _selectedTrack = track;
    });
  }

  Widget _buildChart() {
    return BarChart(
      BarChartData(
        barGroups: _getBarGroups(_selectedTrack),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                DateTime today = DateTime.now();
                DateTime date =
                    today.subtract(Duration(days: 6 - value.toInt()));
                String dateString = "${date.day}${[
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec'
                ][date.month - 1]}";
                return Text(dateString, style: TextStyle(fontSize: 12));
              },
              reservedSize: 32,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<double> dataPoints) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: _getBarGroups(_selectedTrack),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  // switch (value.toInt()) {
                  //   case 0:
                  //     return Text('Mon');
                  //   case 1:
                  //     return Text('Tue');
                  //   case 2:
                  //     return Text('Wed');
                  //   case 3:
                  //     return Text('Thu');
                  //   case 4:
                  //     return Text('Fri');
                  //   case 5:
                  //     return Text('Sat');
                  //   case 6:
                  //     return Text('Sun');
                  //   default:
                  //     return Text('');
                  // }
                  DateTime today = DateTime.now();
                  DateTime date =
                      today.subtract(Duration(days: 6 - value.toInt()));

                  // Format: "13 Feb"
                  String dateString = "${date.day}${[
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec'
                  ][date.month - 1]}";

                  return Text(
                    dateString,
                    style: TextStyle(fontSize: 12),
                  );
                },
                reservedSize: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
