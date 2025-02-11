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
// import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  // final String userEmail;

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  // void _navigateToEditScreen() async {
  //   final updatedData = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ProfileEditScreen(userEmail: widget.userEmail),
  //     ),
  //   );

  //   if (updatedData != null && updatedData is Map<String, String>) {
  //     setState(() {
  //       userProfile = updatedData;
  //     });
  //   }
  // }

  // Future<void> _loadUserData() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   Map<String, dynamic>? userData;
  //   if (user == null) {
  //     try {
  //       // Assuming you are fetching user profile data from Firestore
  //       // DocumentSnapshot userData = await FirebaseFirestore.instance
  //       //     .collection('users')
  //       //     .doc(user!.uid)
  //       //     .get();

  //       DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(user!.uid)
  //           .get();

  //       // if (userData.exists && userData.data() != null) {
  //       // Safely retrieve data, use fallback values if field is missing or null
  //       if (userDoc.exists) {
  //         setState(() {
  //           // userProfile = {
  //           // "nickname": userData['email'] ?? "John Doe",
  //           // "gender": userData["gender"] ?? "Male",
  //           // "weight": userData["weight"] ?? "70",
  //           // "height": userData['height'] ?? "175",
  //           // "weightGoal": userData["weightGoal"] ?? "Maintain weight",
  //           // "dob": userData["dob"] ?? "1995-06-15",
  //           // "preferredFlavors": userData["preferredFlavors"] ?? "Vegetarian",
  //           // "allergies": userData["allergies"] ?? "None",
  //           // "activityLevel": userData["activityLevel"] ?? "Moderate",
  //           // };
  //           userData = userDoc.data() as Map<String, dynamic>;
  //         });
  //       } else {
  //         // Handle case when user data doesn't exist or is null
  //         setState(() {
  //           userProfile = {
  //             "nickname": "John Doe",
  //             "gender": "Male",
  //             "weight": "70",
  //             "height": "175",
  //             "weightGoal": "Maintain weight",
  //             "dob": "1995-06-15",
  //             "preferredFlavors": "Vegetarian",
  //             "allergies": "None",
  //             "activityLevel": "Moderate",
  //           };
  //         });
  //       }
  //     } catch (e) {
  //       print("Error loading user data: $e");
  //     }
  //   } else {
  //     print("No user is currently logged in");
  //   }
  // }

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

//   Future<void> _loadUserData() async {
//   User? user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//     setState(() {
//       _email = "No user logged in";
//     });
//     return;
//   }

//   try {
//     var userData = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.email)
//         .get();

//     if (userData.exists && userData.data() != null) {
//       setState(() {
//         userProfile = {
//           "nickname": userData.data()?["nickname"] ?? "John Doe",
//           "gender": userData.data()?["gender"] ?? "Male",
//           "weight": userData.data()?["weight"]?.toString() ?? "70",
//           "height": userData.data()?["height"]?.toString() ?? "175",
//           "goal": userData.data()?["goal"] ?? "Maintain weight",
//           "birthdate": userData.data()?["birthdate"] ?? "1995-06-15",
//           "foodPref": userData.data()?["foodPref"] ?? "Vegetarian",
//           "allergies": userData.data()?["allergies"] ?? "None",
//           "activityLevel": userData.data()?["activityLevel"] ?? "Moderate",
//         };
//         _email = user.email ?? "No email found";
//       });
//     } else {
//       setState(() {
//         _email = "No user data available";
//       });
//     }
//   } catch (e) {
//     print("Error loading user data: $e");
//     setState(() {
//       _email = "Error loading data";
//     });
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // appBar: SliverAppBar(),
      appBar: AppBar(
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
                                          Icons.male,
                                          size: 16,
                                          color: Color(0xff4D7881),
                                        )
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
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FoodSearchScreen()));
                },
                child: Text(
                  'Go to search',
                  style: TextStyle(color: Color(0xFF1F5F5B)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FoodFilterScreen()));
                },
                child: Text(
                  'Go to filter',
                  style: TextStyle(color: Color(0xFF1F5F5B)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CalculateTest()));
                },
                child: Text(
                  'Go to test',
                  style: TextStyle(color: Color(0xFF1F5F5B)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserCalculation()));
                },
                child: Text(
                  'Go to cal',
                  style: TextStyle(color: Color(0xFF1F5F5B)),
                ),
              ),

              SizedBox(height: 10),
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
              ChartWidget(selectedTrack: _selectedTrack),
              // _buildChart(),

              // Chart
              // ChartWidget(),

              // _buildProfileDetail("Nickname", userProfile["nickname"]!),
              // _buildProfileDetail("Gender", userProfile["gender"]!),
              // _buildProfileDetail("Weight", "${userProfile["weight"]} kg"),
              // _buildProfileDetail("Height", "${userProfile["height"]} cm"),
              // _buildProfileDetail("Goal", userProfile["goal"]!),
              // _buildProfileDetail("Birthdate", userProfile["dob"]!),
              // _buildProfileDetail(
              //     "Food Preference", userProfile["preferredFlavors"]!),
              // _buildProfileDetail("Allergies", userProfile["allergies"]!),
              // _buildProfileDetail(
              //     "Activity Level", userProfile["activityLevel"]!),
            ]),
          ]))
        ],
      ),
    );
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

  Widget _buildPeriodButton(String label) {
    return GestureDetector(
      onTap: () => _onSelect(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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

  Widget _buildTrackDataButton(String label) {
    return GestureDetector(
      onTap: () => _onSelectTrack(label),
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

  // Widget _buildChart() {
  //   switch (_selectedTrack) {
  //     case 'Body Weight':
  //       return _buildTrackDataButton('Body Weight');
  //     case 'BMI':
  //       return _buildTrackDataButton('TDEE');
  //     case 'BMR':
  //       return _buildTrackDataButton('BMR');
  //     case 'TDEE':
  //       return _buildTrackDataButton('TDEE');
  //     case 'Calorie':
  //       return _buildTrackDataButton('Calorie');
  //     default:
  //       return Container();
  //   }
  // }
  // Widget _buildChart() {
  //   switch (_selectedTrack) {
  //     case 'Body Weight':
  //       return _buildLineChart([60, 61, 62, 61.5, 62.3]);
  //     case 'BMI':
  //       return _buildLineChart([22.5, 22.6, 22.7, 22.65, 22.8]);
  //     case 'BMR':
  //       return _buildLineChart([1500, 1510, 1520, 1515, 1525]);
  //     case 'TDEE':
  //       return _buildLineChart([2000, 2050, 2100, 2150, 2200]);
  //     case 'Calorie':
  //       return _buildLineChart([1800, 1850, 1900, 1950, 2000]);
  //     default:
  //       return Container();
  //   }
  // }

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
              // colors: [Colors.blue],
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
