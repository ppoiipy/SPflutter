import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'history_screen.dart';
import 'favorite_screen.dart';
import 'calculate_screen.dart';
import 'package:ginraidee/SQLite/sqlite.dart';
import 'package:ginraidee/screens/homepage.dart';
import 'package:ginraidee/screens/login_screen.dart';
import 'package:ginraidee/screens/profile_edit_screen.dart';
import 'package:ginraidee/auth/auth_service.dart';

// import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  // final String userEmail;

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _currentIndex = 4;

  File? _image;
  String? _profileImageUrl;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Future<void> _getProfilePicture() async {
  //   try {
  //     String userId = FirebaseAuth.instance.currentUser!.uid;
  //     // Reference the user's profile picture in Firebase Storage
  //     Reference storageRef =
  //         FirebaseStorage.instance.ref().child('profile_pictures/$userId.jpg');

  //     // Get the download URL of the profile picture
  //     String downloadUrl = await storageRef.getDownloadURL();

  //     setState(() {
  //       _profileImageUrl = downloadUrl; // Store the download URL
  //     });
  //   } catch (e) {
  //     print('Error fetching profile image: $e');
  //   }
  // }

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

    // _getProfilePicture();
    // saveDailyStats(userData!);
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
    // if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>;
        });
        if (userData != null && userData!.isNotEmpty) {
          saveUserData(userData!);
        }
        print("User Data Loaded: $userData"); // Print user data for debugging
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
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: _profileImageUrl != null
                                      ? NetworkImage(
                                          _profileImageUrl!) // Use the Firebase URL
                                      : const AssetImage(
                                              'assets/images/default.png')
                                          as ImageProvider,
                                ),
                                Positioned(
                                  right: 4,
                                  bottom: 0,
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 30,
                                    color: Color(0xFF1F5F5B),
                                    // backgroundColor:
                                    //     Colors.black.withOpacity(0.5),
                                    // padding: EdgeInsets.all(6),
                                    // shape: CircleBorder(),
                                  ),
                                ),
                              ],
                            ),
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
                                  Expanded(
                                    child: Row(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                    // _buildTrackDataButton('Calorie'),
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
              MaterialPageRoute(builder: (context) => HistoryScreen()),
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
              Icons.history,
            ),
            label: 'History',
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
      onTap: () async {
        _onSelectTrack(label); // Update selected track when tapped

        if (label == 'Calorie') {
          await _fetchCalorieDataForLastWeek();
        }
      }, // Call function to fetch calories when 'Calorie' is tapped
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

  Future<void> _fetchCalorieDataForLastWeek() async {
    // Get the current user ID
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Initialize lists to hold calorie data and corresponding date labels
    List<double> calorieData = [];
    List<String> dateLabels = [];

    // Loop through the last 7 days and fetch calorie data
    for (int i = 0; i < 7; i++) {
      DateTime date =
          DateTime.now().subtract(Duration(days: 6 - i)); // 6 to 0 days ago
      String dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Query the 'food_log' collection for calories for the specific day
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('food_log')
          .where('timestamp',
              isGreaterThanOrEqualTo: DateTime(date.year, date.month, date.day))
          .where('timestamp',
              isLessThan: DateTime(date.year, date.month, date.day + 1))
          .get();

      // Sum up the calories for the specific day
      double dailyCalories = 0.0;
      for (var doc in querySnapshot.docs) {
        dailyCalories += (doc['calories'] ?? 0.0);
      }

      // Add the total daily calories and formatted date
      calorieData.add(dailyCalories);
      dateLabels.add(getFormattedDate(date));
    }

    // Now you can use the calorieData to update the chart
    setState(() {
      // Update chart or any other UI with the calorie data
      print("Calories Data for the last week: $calorieData");
      // Call to update chart widget or other UI with the fetched calorie data
    });
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

  //
  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> activityLevels = [
    "Sedentary (little to no exercise)",
    "Lightly active (1-3 days/week)",
    "Moderately active (3-5 days/week)",
    "Very active (6-7 days/week)",
    "Super active (very hard exercise, physical job)"
  ];

  double? _bmi, _bmr, _tdee;

  // final DatabaseHelper _dbHelper = DatabaseHelper();

// Activity level multipliers
  final Map<String, double> _activityMultipliers = {
    'Sedentary (little to no exercise)': 1.2,
    'Lightly active (1-3 days/week)': 1.375,
    'Moderately active (3-5 days/week)': 1.55,
    'Very active (6-7 days/week)': 1.725,
    'Super active (very hard exercise, physical job)': 1.9,
  };

// Controllers
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _selectedGender;
  String? _selectedActivityLevel;

  int _calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> storeTrackingData({
    required double bodyWeight,
    required double bmi,
    required double bmr,
    required double tdee,
    required String
        userId, // Assuming you have a userId for identifying the user
  }) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Create a timestamp for today
    DateTime today = DateTime.now();
    String dateString = "${today.year}-${today.month}-${today.day}";

    // Prepare data for Firestore
    Map<String, dynamic> data = {
      'userId': userId,
      'bodyWeight': bodyWeight,
      'bmi': bmi,
      'bmr': bmr,
      'tdee': tdee,
      'timestamp': today, // This will save the date & time
      'date': dateString, // Store just the date for reference
    };

    // Store the data in Firestore (in a collection named 'tracking_logs')
    await _firestore.collection('tracking_logs').add(data);
  }

  void updateTrackingData() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    double bodyWeight = double.tryParse(_weightController.text) ?? 0.0;
    double height = double.tryParse(_heightController.text) ?? 0.0;
    double bmi = _calculateBmi(bodyWeight, height);
    double bmr = _calculateBmr(
        bmi, _calculateAge(DateTime.parse(userData?["dob"] ?? '')));
    double tdee = _calculateTdee(bmr, _selectedActivityLevel!);

    // Store data in Firebase
    storeTrackingData(
      bodyWeight: bodyWeight,
      bmi: bmi,
      bmr: bmr,
      tdee: tdee,
      userId: userId, // Pass the current userId
    );
  }

  double _calculateBmi(double weight, double height) {
    return weight /
        ((height / 100) * (height / 100)); // BMI = weight (kg) / height (m)^2
  }

  double _calculateBmr(double bmi, int age) {
    // Using Mifflin-St Jeor equation for BMR (assuming male gender here)
    double bmr = 10 * (bmi * 0.9) +
        6.25 * 180 -
        5 * age +
        5; // You can adjust this formula based on gender and other factors
    return bmr;
  }

  double _calculateTdee(double bmr, String activityLevel) {
    double activityMultiplier = _activityMultipliers[activityLevel] ?? 1.2;
    return bmr * activityMultiplier;
  }
}

Future<void> saveUserData(Map<String, dynamic> userData) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Extract user data from the map
  final weight = double.tryParse(userData['weight'].toString()) ?? 0.0;
  final height = double.tryParse(userData['height'].toString()) ?? 0.0;
  final gender = userData['gender'];
  final dob = DateTime.parse(userData['dob']);
  final activityLevel = userData['activityLevel'] ?? 'Sedentary';

  // Calculate BMI
  double bmi = weight / ((height / 100) * (height / 100));

  // Calculate age from DOB
  int age = DateTime.now().difference(dob).inDays ~/ 365;

  // Calculate BMR using Mifflin-St Jeor Equation (assuming male/female based on gender)
  double bmr;
  if (gender == 'Male') {
    bmr = 9.99 * weight + 6.25 * height - 4.92 * age + 5;
  } else {
    bmr = 9.99 * weight + 6.25 * height - 4.92 * age - 161;
  }

  // Calculate TDEE based on activity level
  final Map<String, double> activityMultipliers = {
    'Sedentary (little to no exercise)': 1.2,
    'Lightly active (1-3 days/week)': 1.375,
    'Moderately active (3-5 days/week)': 1.55,
    'Very active (6-7 days/week)': 1.725,
    'Super active (very hard exercise, physical job)': 1.9,
  };

  double tdee = bmr * (activityMultipliers[activityLevel] ?? 1.2);

  // Print values for debugging purposes
  print("User Data to Save:");
  print("User ID: $userId");
  print("Weight: $weight");
  print("Height: $height");
  print("Gender: $gender");
  print("Age: $age");
  print("BMI: $bmi");
  print("BMR: $bmr");
  print("TDEE: $tdee");
  print("Activity Level: $activityLevel");
  print("Date Key: $dateKey");

  // Store data to Firestore (under users/uid/dailyStats)
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('dailyStats')
      .doc(dateKey)
      .set({
    'weight': weight,
    'height': height,
    'bmi': bmi,
    'bmr': bmr,
    'tdee': tdee,
    'activityLevel': activityLevel,
    'timestamp': FieldValue.serverTimestamp(),
  }).then((value) {
    print("Data successfully saved to Firebase.");
  }).catchError((error) {
    print("Failed to save data: $error");
  });
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

  // This will fetch the data for the last 7 days
  Future<List<BarChartGroupData>> _getBarGroups(
      String track, String dateRange) async {
    List<double> dataPoints = [];
    List<String> dateLabels = [];

    // Fetching data for the last 7 days from Firestore (or use dummy data for testing)
    for (int i = 6; i >= 0; i--) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      String dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Here, replace with the actual Firestore query to get the data for this date
      // For example:
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('dailyStats')
          .doc(dateKey)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data();
        double value = _getValueForTrack(track, data);
        dataPoints.add(value);
        dateLabels.add(
            getFormattedDate(date)); // Add the formatted date to the labels
      } else {
        // If no data for that date, use a default value (e.g., 0 or previous day's value)
        dataPoints.add(0.0);
        dateLabels.add(getFormattedDate(date));
      }
    }

    // Return a list of BarChartGroupData
    return List.generate(dataPoints.length, (index) {
      return BarChartGroupData(
        x: index, // Ensures bars are in chronological order
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
    return FutureBuilder<List<BarChartGroupData>>(
      future: _getBarGroups(widget.selectedTrack, widget.dateRange),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error loading data"));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Padding(
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
                    height: 230,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: BarChart(
                        BarChartData(
                          barGroups: snapshot.data!,
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true, reservedSize: 40),
                            ),
                            topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              axisNameWidget: Text(
                                'Date',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  String dateString = getFormattedDate(
                                      DateTime.now().subtract(Duration(
                                          days:
                                              (meta.max - value + 5).toInt())));

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
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text("No data available"));
        }
      },
    );
  }
}
