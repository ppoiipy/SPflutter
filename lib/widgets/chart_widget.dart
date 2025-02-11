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

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index + 1,
        barRods: [
          BarChartRodData(
            toY: _getWeightValue(),
            color: Color(0xff4D7881),
          )
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
                    barGroups: _getBarGroups(),
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

      // Body Mass Index
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
                        'Body Mass Index',
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
                        'Obesity Level 3',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Appropriate Value: 18.5-22.9',
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
                child: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Recommended Actions: ",
                              style: TextStyle(
                                color: Colors
                                    .black, // Color for the first part of the text
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "Consult a Professional: Seek advice. ",
                              style: TextStyle(
                                color: Colors
                                    .blue, // Color for this part of the text
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Consider lifestyle changes including diet and exercise for weight management.",
                              style: TextStyle(
                                color: Colors
                                    .green, // Color for this part of the text
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Image.asset(
                      "assets/images/Jake-removebg-preview.png",
                      width: 80,
                    ),
                    Expanded(
                      child: Text(
                          "Recommended Actions: Consult a Professional: Seek advice. Consider lifestyle changes including diet and exercise for weight management."),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // BMI
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
                        'BMI',
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
                        '52.2 kg',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff4D7881),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '+2.2',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Goal: 50',
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
                    barGroups: _getBarGroups(),
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
                            switch (value.toInt()) {
                              case 0:
                                return Text('Mon');
                              case 1:
                                return Text('Tue');
                              case 2:
                                return Text('Wed');
                              case 3:
                                return Text('Thu');
                              case 4:
                                return Text('Fri');
                              case 5:
                                return Text('Sat');
                              case 6:
                                return Text('Sun');
                              default:
                                return Text('');
                            }
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

      // BMR
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
                        'BMR',
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
                        '52.2 kg',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff4D7881),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '+2.2',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Goal: 50',
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
                    barGroups: _getBarGroups(),
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
                            switch (value.toInt()) {
                              case 0:
                                return Text('Mon');
                              case 1:
                                return Text('Tue');
                              case 2:
                                return Text('Wed');
                              case 3:
                                return Text('Thu');
                              case 4:
                                return Text('Fri');
                              case 5:
                                return Text('Sat');
                              case 6:
                                return Text('Sun');
                              default:
                                return Text('');
                            }
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

      // TDEE
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
                        'TDEE',
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
                        '52.2 kg',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff4D7881),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '+2.2',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Goal: 50',
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
                    barGroups: _getBarGroups(),
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
                            switch (value.toInt()) {
                              case 0:
                                return Text('Mon');
                              case 1:
                                return Text('Tue');
                              case 2:
                                return Text('Wed');
                              case 3:
                                return Text('Thu');
                              case 4:
                                return Text('Fri');
                              case 5:
                                return Text('Sat');
                              case 6:
                                return Text('Sun');
                              default:
                                return Text('');
                            }
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

      // Calorie Tracker
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
                        'Calorie Tracker',
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
                        '52.2 kg',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xff4D7881),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '+2.2',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Goal: 50',
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
                    barGroups: _getBarGroups(),
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
                            switch (value.toInt()) {
                              case 0:
                                return Text('Mon');
                              case 1:
                                return Text('Tue');
                              case 2:
                                return Text('Wed');
                              case 3:
                                return Text('Thu');
                              case 4:
                                return Text('Fri');
                              case 5:
                                return Text('Sat');
                              case 6:
                                return Text('Sun');
                              default:
                                return Text('');
                            }
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
    ]);
  }

  String _selectedTrack = 'Body Weight';
  void _onSelectTrack(String track) {
    setState(() {
      _selectedTrack = track;
    });
  }

  Widget _buildChart() {
    switch (_selectedTrack) {
      case 'Body Weight':
        return _buildLineChart([60, 61, 62, 61.5, 62.3]);
      case 'BMI':
        return _buildLineChart([22.5, 22.6, 22.7, 22.65, 22.8]);
      case 'BMR':
        return _buildLineChart([1500, 1510, 1520, 1515, 1525]);
      case 'TDEE':
        return _buildLineChart([2000, 2050, 2100, 2150, 2200]);
      case 'Calorie':
        return _buildLineChart([1800, 1850, 1900, 1950, 2000]);
      default:
        return Container();
    }
  }

  Widget _buildLineChart(List<double> dataPoints) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: _getBarGroups(),
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
