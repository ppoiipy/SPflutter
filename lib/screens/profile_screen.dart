import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_application_1/SQLite/sqlite.dart';
import 'package:flutter_application_1/screens/calculate_test.dart';
import 'package:flutter_application_1/screens/food_filter_screen.dart';
import 'package:flutter_application_1/screens/food_search_screen.dart';
import 'package:flutter_application_1/screens/homepage.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/profile_edit_screen.dart';
import 'package:flutter_application_1/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/user_calculation.dart';
import 'package:flutter_application_1/widgets/chart_widget.dart';
import 'package:fl_chart/fl_chart.dart';

import 'menu_screen.dart';
import 'favorite_screen.dart';
import 'calculate_screen.dart';

// import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  // final String userEmail;

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _currentIndex = 4;

  String _email = "Loading...";
  String _selected = 'D';
  String _selectedTrack = 'Body Weight';
  String selectedTab = "profile";
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, String> userProfile = {};

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

  void _onSelectTrack(String track) {
    setState(() {
      _selectedTrack = track;
    });
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
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: SliverAppBar(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'User Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              onPressed: () {
                // context.read<AuthService>().signOut();
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                          title: Text('Logout'),
                          content: Text('Are you sure you want to log out?'),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'No',
                                style: TextStyle(color: Color(0xFF1F5F5B)),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await AuthService().signOut();
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFF1F5F5B),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 40)),
                              child: Text('Yes',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ]);
                    });
              },
              icon: Icon(Icons.logout, color: Colors.white),
            ),
          )
        ],
      ),

      body: CustomScrollView(
        slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 330,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1F5F5B), Color(0xFF40C5BD)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(height: 100),
                      // Profile Picture
                      Stack(children: [
                        Center(
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                const AssetImage('assets/images/default.png'),
                          ),
                        ),
                        // Positioned(
                        //   bottom: 0,
                        //   right: 120,
                        //   child: Icon(
                        //     Icons.camera_alt,
                        //     size: 36,
                        //   ),
                        // ),
                      ]),
                      const SizedBox(height: 20),

                      // Show user email
                      Center(
                        child: Text(
                          userData?['email'] ?? 'No email available',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Container(
                        margin: const EdgeInsets.all(12),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Gender: ',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          userData?['gender'] ?? 'N/A',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff4D7881),
                                          ),
                                        ),
                                        Icon(
                                          _getGenderIcon(userData?['gender']),
                                          size: 16,
                                          color: Color(0xff4D7881),
                                        ),
                                      ],
                                    ),
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
                                        userData?["dob"] ?? 'N/A',
                                        style: TextStyle(
                                          color: Color(0xff4D7881),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () async {
                                      final updatedProfile =
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileEditScreen()));
                                      if (updatedProfile != null) {
                                        setState() {
                                          userData = updatedProfile
                                              as Map<String, dynamic>;
                                        }
                                      }
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Height: ',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "${userData?["height"]?.toString() ?? 'N/A'} cm",
                                          style: TextStyle(
                                            color: Color(0xff4D7881),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Weight: ',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "${userData?["weight"]?.toString() ?? 'N/A'} kg",
                                          style: TextStyle(
                                            color: Color(0xff4D7881),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              //
              Container(
                padding: EdgeInsets.all(0),
                width: MediaQuery.sizeOf(context).width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTrackDataButton('Body Weight'),
                    _buildTrackDataButton('BMI'),
                    _buildTrackDataButton('BMR'),
                    _buildTrackDataButton('TDEE'),
                    _buildTrackDataButton('Calorie'),
                  ],
                ),
              ),
              ChartWidget(selectedTrack: _selectedTrack, dateRange: 'Day'),
            ]),
          ]))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF1F5F5B),
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(color: Color(0xFF1F5F5B)),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Homepage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MenuScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FavoriteScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CalculateScreen()),
            );
          } else if (index == 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.food_bank_outlined,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border_outlined,
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calculate_outlined,
            ),
            label: 'Calculate',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  IconData _getGenderIcon(String? gender) {
    switch (gender) {
      case 'Male':
        return Icons.male;
      case 'Female':
        return Icons.female;
      default:
        return Icons.transgender;
    }
  }

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTrackDataButton(String label) {
    return GestureDetector(
      onTap: () => _onSelectTrack(label), // Update selected track when tapped
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color:
              _selectedTrack == label ? Color(0xff4D7881) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _selectedTrack == label ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<double> dataPoints) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartWidget extends StatefulWidget {
  final String selectedTrack;
  final String dateRange;

  ChartWidget({required this.selectedTrack, required this.dateRange});

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
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

  List<BarChartGroupData> _getBarGroups(String track, String dateRange) {
    List<double> dataPoints;
    List<String> dateLabels = [];

    // Sample data for the demonstration
    switch (track) {
      case 'Body Weight':
        dataPoints = [60, 61, 62, 61.5, 62.3]; // Example values for testing
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

    // Adjust the dateLabels to show the dates starting from today (on the left)
    for (int i = 0; i < dataPoints.length; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      dateLabels.add(getFormattedDate(date)); // Get formatted date for each day
    }

    // Reverse the dateLabels to ensure today is on the leftmost side of the chart
    dateLabels = dateLabels.reversed.toList();

    return List.generate(dataPoints.length, (index) {
      return BarChartGroupData(
        x: index, // Ensuring that the chart starts from the left for today
        barRods: [
          BarChartRodData(
            toY: dataPoints[index],
            color: Color(0xff4D7881),
          ),
        ],
      );
    });
  }

  String getFormattedDate(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));

    if (date.isAtSameMomentAs(today)) {
      return "Today";
    } else if (date.isAtSameMomentAs(yesterday)) {
      return "Yesterday";
    } else {
      return "${date.day} ${_getMonthString(date.month)}";
    }
  }

  String _getMonthString(int month) {
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                          widget.selectedTrack,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff4D7881),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      barGroups:
                          _getBarGroups(widget.selectedTrack, widget.dateRange),
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
                              String dateString = widget.dateRange == 'Day'
                                  ? getFormattedDate(DateTime.now().subtract(
                                      Duration(
                                          days: (meta.max - value).toInt())))
                                  : "Day ${value.toInt() + 1}";

                              return Text(dateString,
                                  style: TextStyle(fontSize: 12));
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
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ProfileScreen extends StatefulWidget {
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   User? user = FirebaseAuth.instance.currentUser;
//   Map<String, dynamic>? userData;

//   @override
//   void initState() {
//     super.initState();
//     fetchUserData();
//   }

//   Future<void> fetchUserData() async {
//     if (user == null) return;

//     try {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user!.uid)
//           .get();

//       if (userDoc.exists) {
//         setState(() {
//           userData = userDoc.data() as Map<String, dynamic>;
//         });
//       }
//     } catch (e) {
//       print('Error fetching user data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Profile')),
//       body: userData == null
//           ? Center(child: CircularProgressIndicator())
//           : Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Email: ${userData?['email'] ?? 'Not provided'}',
//                       style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 10),
//                   Text('Height: ${userData?['height'] ?? 'Not provided'} cm',
//                       style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 10),
//                   Text('Weight: ${userData?['weight'] ?? 'Not provided'} kg',
//                       style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 10),
//                   Text('Date of Birth: ${userData?['dob'] ?? 'Not provided'}',
//                       style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 10),
//                   Text('Gender: ${userData?['gender'] ?? 'Not provided'}',
//                       style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 10),
//                   Text(
//                       'Allergies: ${userData?['allergies'] ?? 'Not provided'} kg',
//                       style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 10),
//                   Text(
//                       'Weight Goal: ${userData?['weightGoal'] ?? 'Not provided'}',
//                       style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 10),
//                   Text(
//                       'Preferred Flavors: ${userData?['preferredFlavors'] ?? 'Not provided'}',
//                       style: TextStyle(fontSize: 18)),
//                   SizedBox(height: 10),
//                   Text(
//                       'Activity Level: ${userData?['activityLevel'] ?? 'Not provided'}',
//                       style: TextStyle(fontSize: 18)),
//                 ],
//               ),
//             ),
//     );
//   }
// }
