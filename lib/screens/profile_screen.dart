import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/SQLite/sqlite.dart';
import 'package:flutter_application_1/screens/homepage.dart';
import 'package:flutter_application_1/screens/profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userEmail;

  const ProfileScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _email = "Loading...";
  String _selected = '';
  String selectedTab = "profile";
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _onSelect(String period) {
    setState(() {
      _selected = period;
    });
  }

  Future<void> _loadUserData() async {
    final user = await _dbHelper.getUserByEmail(widget.userEmail);
    if (user != null) {
      setState(() {
        _email = user['usrEmail'];
      });
    } else {
      setState(() {
        _email = "User not found";
      });
    }
  }

  List<BarChartGroupData> _getBarGroups() {
    return [
      BarChartGroupData(
          x: 0, barRods: [BarChartRodData(toY: 40, color: Color(0xff4D7881))]),
      BarChartGroupData(
          x: 1, barRods: [BarChartRodData(toY: 20, color: Color(0xff4D7881))]),
      BarChartGroupData(
          x: 2, barRods: [BarChartRodData(toY: 49, color: Color(0xff4D7881))]),
      BarChartGroupData(
          x: 3, barRods: [BarChartRodData(toY: 60, color: Color(0xff4D7881))]),
      BarChartGroupData(
          x: 4, barRods: [BarChartRodData(toY: 24, color: Color(0xff4D7881))]),
      BarChartGroupData(
          x: 5, barRods: [BarChartRodData(toY: 54, color: Color(0xff4D7881))]),
      BarChartGroupData(
          x: 6, barRods: [BarChartRodData(toY: 48, color: Color(0xff4D7881))]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // selectedTab == 'profile'
            //     ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        const AssetImage('assets/images/default.png'),
                  ),
                ),
                const SizedBox(height: 20),

                // Show user email
                Center(
                  child: Text(
                    _email,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Container(
                  margin: const EdgeInsets.all(0),
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
                  width: MediaQuery.sizeOf(context).width,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Gender: ',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Male',
                                  style: TextStyle(
                                    color: Color(0xff4D7881),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.male,
                                  size: 16,
                                  color: Color(0xff4D7881),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Birth Date: ',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'xx/xx/xxxx',
                                  style: TextStyle(
                                    color: Color(0xff4D7881),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // selectedTab = 'profile';
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileEditScreen(
                                                    userEmail: _email)),
                                      );
                                    });
                                  },
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Height: ',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '152 cm',
                                  style: TextStyle(
                                    color: Color(0xff4D7881),
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Activity level: ',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Sedentary',
                                  style: TextStyle(
                                    color: Color(0xff4D7881),
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Container(
                  padding: EdgeInsets.all(10),
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPeriodButton('D'),
                      _buildPeriodButton('W'),
                      _buildPeriodButton('M'),
                      _buildPeriodButton('Y'),
                    ],
                  ),
                ),

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
                                  sideTitles: SideTitles(
                                      showTitles: true, reservedSize: 40),
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
                                  '52.2 kg',
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
                                        text:
                                            "Consult a Professional: Seek advice. ",
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
                                  sideTitles: SideTitles(
                                      showTitles: true, reservedSize: 40),
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
                                  sideTitles: SideTitles(
                                      showTitles: true, reservedSize: 40),
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
                                  sideTitles: SideTitles(
                                      showTitles: true, reservedSize: 40),
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
                                  sideTitles: SideTitles(
                                      showTitles: true, reservedSize: 40),
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

                // Date of Birth Selection
                TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                  },
                  child: const Text('Select Date of Birth'),
                ),

                const SizedBox(height: 20),

                // Save Profile Button
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Save Profile'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label) {
    return GestureDetector(
      onTap: () => _onSelect(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: _selected == label ? Color(0xff4D7881) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _selected == label ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
