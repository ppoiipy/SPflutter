// // import 'package:flutter/material.dart';
// // import 'package:fl_chart/fl_chart.dart';
// // import 'package:flutter_application_1/screens/calculate_screen.dart';
// // import 'package:flutter_application_1/screens/favorite_screen.dart';
// // import 'package:flutter_application_1/screens/menu_screen.dart';
// // import 'dart:math';
// // import 'calorie_tracking_next_screen.dart';
// // import 'botton_nav_bar.dart';
// // import 'homepage.dart';
// // import 'profile_screen.dart';

// // class CalorieTrackingScreen extends StatefulWidget {
// //   const CalorieTrackingScreen({super.key});

// //   @override
// //   State<CalorieTrackingScreen> createState() => _CalorieTrackingScreenState();
// // }

// // class _CalorieTrackingScreenState extends State<CalorieTrackingScreen> {
// //   // int _currentIndex = 5+;

// //   List<BarChartGroupData> _getBarGroups() {
// //     return [
// //       BarChartGroupData(
// //           x: 0, barRods: [BarChartRodData(toY: 40, color: Color(0xff4D7881))]),
// //       BarChartGroupData(
// //           x: 1, barRods: [BarChartRodData(toY: 20, color: Color(0xff4D7881))]),
// //       BarChartGroupData(
// //           x: 2, barRods: [BarChartRodData(toY: 50, color: Colors.red)]),
// //       BarChartGroupData(
// //           x: 3, barRods: [BarChartRodData(toY: 60, color: Colors.red)]),
// //       BarChartGroupData(
// //           x: 4, barRods: [BarChartRodData(toY: 24, color: Color(0xff4D7881))]),
// //       BarChartGroupData(
// //           x: 5, barRods: [BarChartRodData(toY: 54, color: Colors.red)]),
// //       BarChartGroupData(
// //           x: 6, barRods: [BarChartRodData(toY: 48, color: Color(0xff4D7881))]),
// //     ];
// //   }

// //   final int _currentIndex = 0;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SingleChildScrollView(
// //         child: Container(
// //           decoration: BoxDecoration(
// //             image: DecorationImage(
// //               image: AssetImage(
// //                   'assets/images/0c42e0e25128dfaf306ab0ac15f14d9a.jfif'),
// //               fit: BoxFit.cover,
// //               colorFilter: ColorFilter.mode(
// //                 Colors.black.withOpacity(0.7),
// //                 BlendMode.darken,
// //               ),
// //             ),
// //           ),
// //           child: Column(
// //             children: [
// //               Container(
// //                 width: MediaQuery.sizeOf(context).width,
// //                 height: 100,
// //                 decoration: BoxDecoration(
// //                   gradient: LinearGradient(
// //                     colors: [const Color(0xFF1F5F5B), Color(0xFF40C5BD)],
// //                     begin: Alignment.topCenter,
// //                     end: Alignment.bottomCenter,
// //                   ),
// //                 ),
// //                 child: Padding(
// //                   padding: EdgeInsets.all(8),
// //                   child: AppBar(
// //                     backgroundColor: Colors.transparent,
// //                     centerTitle: true,
// //                     title: Text(
// //                       'Calorie Tracking',
// //                       style: TextStyle(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.w600,
// //                           fontFamily: 'Inter',
// //                           letterSpacing: 1),
// //                     ),
// //                     leading: IconButton(
// //                       icon: Icon(
// //                         Icons.arrow_back_ios,
// //                         color: Colors.white,
// //                       ),
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                       },
// //                     ),
// //                     actions: [
// //                       IconButton(
// //                         icon: Icon(
// //                           Icons.calendar_today,
// //                           color: Colors.white,
// //                         ),
// //                         onPressed: () {
// //                           // Action for calendar icon
// //                         },
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),

// //               SizedBox(height: 30),

// //               // Circle
// //               Center(
// //                 child: SquareClickableSections(),
// //               ),

// //               SizedBox(height: 30),

// //               // Info
// //               Container(
// //                 decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.only(
// //                         topLeft: Radius.circular(40),
// //                         topRight: Radius.circular(40))),
// //                 width: 300,
// //                 padding: EdgeInsets.all(15),
// //                 child: Column(
// //                   children: [
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                       children: [
// //                         Column(
// //                           children: [
// //                             Row(
// //                               children: [
// //                                 Icon(Icons.calendar_month_outlined),
// //                                 Text(
// //                                   'See more',
// //                                   style: TextStyle(
// //                                     fontWeight: FontWeight.w600,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             Row(
// //                               children: [
// //                                 Text(
// //                                   '85',
// //                                   style: TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     fontSize: 24,
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   ' / 50 kg.',
// //                                   style: TextStyle(
// //                                     color: Colors.grey,
// //                                     fontWeight: FontWeight.w600,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ],
// //                         ),
// //                         Container(
// //                           color: Colors.grey[600],
// //                           width: 1,
// //                           height: 80,
// //                         ),
// //                         Column(
// //                           children: [
// //                             Text(
// //                               'Energy Intake',
// //                               style: TextStyle(fontWeight: FontWeight.w600),
// //                             ),
// //                             Row(
// //                               children: [
// //                                 Icon(
// //                                   Icons.energy_savings_leaf_outlined,
// //                                   size: 20,
// //                                   color: Colors.red,
// //                                 ),
// //                                 Text(
// //                                   ' +590 ',
// //                                   style: TextStyle(
// //                                     color: Colors.green,
// //                                     fontWeight: FontWeight.w600,
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   'kcal',
// //                                   style: TextStyle(
// //                                     color: Colors.grey[500],
// //                                     fontWeight: FontWeight.w600,
// //                                   ),
// //                                 )
// //                               ],
// //                             ),
// //                             SizedBox(height: 10),
// //                             Text(
// //                               'TDEE vs. intake',
// //                               style: TextStyle(fontWeight: FontWeight.w600),
// //                             ),
// //                             Row(
// //                               children: [
// //                                 Icon(
// //                                   Icons.energy_savings_leaf_outlined,
// //                                   size: 20,
// //                                   color: Colors.red,
// //                                 ),
// //                                 Text(
// //                                   ' 1770 ',
// //                                   style: TextStyle(
// //                                     color: Colors.green,
// //                                     fontWeight: FontWeight.w600,
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   'kcal',
// //                                   style: TextStyle(
// //                                     color: Colors.grey[500],
// //                                     fontWeight: FontWeight.w600,
// //                                   ),
// //                                 )
// //                               ],
// //                             )
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               Container(
// //                 padding: EdgeInsets.only(top: 5),
// //                 width: 300,
// //                 height: 60,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.only(
// //                       bottomLeft: Radius.circular(20),
// //                       bottomRight: Radius.circular(20)),
// //                   color: Colors.grey,
// //                 ),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                   children: [
// //                     Column(
// //                       children: [
// //                         Text(
// //                           '0%',
// //                           style: TextStyle(
// //                             color: Colors.white,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                         Text(
// //                           'Progress',
// //                           style: TextStyle(fontWeight: FontWeight.w600),
// //                         ),
// //                       ],
// //                     ),
// //                     Column(
// //                       children: [
// //                         Text(
// //                           'BMI 26.2',
// //                           style: TextStyle(
// //                             color: Colors.white,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                         Text(
// //                           'Overweight',
// //                           style: TextStyle(fontWeight: FontWeight.w600),
// //                         ),
// //                       ],
// //                     ),
// //                     Column(
// //                       children: [
// //                         Text(
// //                           '2360',
// //                           style: TextStyle(
// //                             color: Colors.white,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                         Text(
// //                           'TDEE',
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                       ],
// //                     )
// //                   ],
// //                 ),
// //               ),

// //               // Graph
// //               // Calorie Tracker
// //               Padding(
// //                 padding: const EdgeInsets.all(10),
// //                 child: Container(
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(10),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.2),
// //                         spreadRadius: 0,
// //                         blurRadius: 4,
// //                         offset: const Offset(0, 6),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       Container(
// //                         padding: EdgeInsets.all(5),
// //                         decoration: BoxDecoration(
// //                             color: Colors.grey,
// //                             borderRadius: BorderRadius.only(
// //                                 topLeft: Radius.circular(10),
// //                                 topRight: Radius.circular(10))),
// //                         child: Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                           children: [
// //                             // GestureDetector(
// //                             //   onTap: () {},
// //                             //   child: Icon(
// //                             //     Icons.arrow_back_ios,
// //                             //     color: Colors.white,
// //                             //   ),
// //                             // ),
// //                             Text(
// //                               'Calorie Tracker',
// //                               style: TextStyle(
// //                                 fontSize: 16,
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                             ),
// //                             // GestureDetector(
// //                             //   onTap: () {},
// //                             //   child: Icon(
// //                             //     Icons.arrow_forward_ios,
// //                             //     color: Colors.white,
// //                             //   ),
// //                             // ),
// //                           ],
// //                         ),
// //                       ),
// //                       Container(
// //                         padding: EdgeInsets.all(5),
// //                         height: 200,
// //                         child: BarChart(
// //                           BarChartData(
// //                             barGroups: _getBarGroups(),
// //                             borderData: FlBorderData(show: false),
// //                             titlesData: FlTitlesData(
// //                               leftTitles: AxisTitles(
// //                                 sideTitles: SideTitles(
// //                                   showTitles: true,
// //                                   reservedSize: 40,
// //                                 ),
// //                               ),
// //                               bottomTitles: AxisTitles(
// //                                 sideTitles: SideTitles(
// //                                   showTitles: true,
// //                                   getTitlesWidget: (value, meta) {
// //                                     switch (value.toInt()) {
// //                                       case 0:
// //                                         return Text('Mon');
// //                                       case 1:
// //                                         return Text('Tue');
// //                                       case 2:
// //                                         return Text('Wed');
// //                                       case 3:
// //                                         return Text('Thu');
// //                                       case 4:
// //                                         return Text('Fri');
// //                                       case 5:
// //                                         return Text('Sat');
// //                                       case 6:
// //                                         return Text('Sun');
// //                                       default:
// //                                         return Text('');
// //                                     }
// //                                   },
// //                                   reservedSize: 32,
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //       bottomNavigationBar: BottomNavigationBar(
// //         type: BottomNavigationBarType.fixed,
// //         selectedItemColor: Colors.black,
// //         unselectedItemColor: Colors.black,
// //         selectedLabelStyle: TextStyle(color: Colors.black),
// //         unselectedLabelStyle: TextStyle(color: Colors.black),
// //         currentIndex: _currentIndex,
// //         onTap: (index) {
// //           if (index == 0) {
// //             Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(builder: (context) => Homepage()),
// //             );
// //           } else if (index == 1) {
// //             Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(builder: (context) => MenuScreen()),
// //             );
// //           } else if (index == 2) {
// //             Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(builder: (context) => FavoriteScreen()),
// //             );
// //           } else if (index == 3) {
// //             Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(builder: (context) => CalculateScreen()),
// //             );
// //           } else if (index == 4) {
// //             Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(builder: (context) => ProfileScreen()),
// //             );
// //           } else {
// //             Navigator.pushReplacement(
// //               context,
// //               MaterialPageRoute(builder: (context) => CalorieTrackingScreen()),
// //             );
// //           }
// //         },
// //         items: [
// //           BottomNavigationBarItem(
// //             icon: Icon(
// //               Icons.home_outlined,
// //             ),
// //             label: 'Home',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(
// //               Icons.food_bank_outlined,
// //             ),
// //             label: 'Search',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(
// //               Icons.favorite_border_outlined,
// //             ),
// //             label: 'Favorites',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(
// //               Icons.calculate_outlined,
// //             ),
// //             label: 'Calculate',
// //           ),
// //           BottomNavigationBarItem(
// //             icon: Icon(
// //               Icons.person_outline,
// //             ),
// //             label: 'Profile',
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class SquareClickableSections extends StatelessWidget {
// //   void navigateToPage(BuildContext context, String pageName) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //           builder: (context) => MealPlanningNextScreen(pageName: pageName)),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Stack(
// //         alignment: Alignment.center,
// //         children: [
// //           // Square sections
// //           CustomPaint(
// //             size: Size(350, 350),
// //             painter: SquareSectionsPainter(),
// //           ),

// //           // Centered summary box
// //           Container(
// //             width: 150,
// //             height: 150,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               color: Colors.black.withOpacity(0.6),
// //             ),
// //             child: Center(
// //               child: Text(
// //                 'Calorie Sum: 590 kcal',
// //                 textAlign: TextAlign.center,
// //                 style: TextStyle(
// //                   fontSize: 14,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //             ),
// //           ),

// //           // Clickable sections
// //           Positioned(
// //             top: 0,
// //             left: 0,
// //             child: buildClickableSection('Snacks', Icons.fastfood, context),
// //           ),
// //           Positioned(
// //             top: 0,
// //             right: 0,
// //             child: buildClickableSection(
// //                 'Breakfast', Icons.breakfast_dining, context),
// //           ),
// //           Positioned(
// //             bottom: 0,
// //             left: 0,
// //             child: buildClickableSection('Lunch', Icons.lunch_dining, context),
// //           ),
// //           Positioned(
// //             bottom: 0,
// //             right: 0,
// //             child:
// //                 buildClickableSection('Dinner', Icons.dinner_dining, context),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget buildClickableSection(
// //       String label, IconData icon, BuildContext context) {
// //     return GestureDetector(
// //       onTap: () => navigateToPage(context, label),
// //       child: Container(
// //         width: 175,
// //         height: 175,
// //         color: Colors.transparent,
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(icon, color: Colors.white),
// //             Text(label, style: TextStyle(color: Colors.white)),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class SquareSectionsPainter extends CustomPainter {
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final Paint paint = Paint()..style = PaintingStyle.fill;

// //     final List<Color> colors = [
// //       Colors.blueAccent,
// //       Colors.greenAccent,
// //       Colors.orangeAccent,
// //       Colors.purpleAccent,
// //     ];

// //     final double halfWidth = size.width / 2;
// //     final double halfHeight = size.height / 2;

// //     final List<Rect> sections = [
// //       Rect.fromLTWH(0, 0, halfWidth, halfHeight), // Top-left
// //       Rect.fromLTWH(halfWidth, 0, halfWidth, halfHeight), // Top-right
// //       Rect.fromLTWH(0, halfHeight, halfWidth, halfHeight), // Bottom-left
// //       Rect.fromLTWH(
// //           halfWidth, halfHeight, halfWidth, halfHeight), // Bottom-right
// //     ];

// //     for (int i = 0; i < 4; i++) {
// //       paint.color = colors[i];
// //       canvas.drawRect(sections[i], paint);
// //     }
// //   }

// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) {
// //     return false;
// //   }
// // }

// // // class RadialClickableSections extends StatelessWidget {
// // //   void navigateToPage(BuildContext context, String pageName) {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(
// // //           builder: (context) => MealPlanningNextScreen(pageName: pageName)),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Center(
// // //       child: Stack(
// // //         alignment: Alignment.center,
// // //         children: [
// // //           // Radial sections
// // //           CustomPaint(
// // //             size: Size(350, 350),
// // //             painter: RadialSectionsPainter(),
// // //           ),

// // //           Container(
// // //             width: 150,
// // //             height: 150,
// // //             decoration: BoxDecoration(
// // //               shape: BoxShape.circle,
// // //               color: Colors.black.withOpacity(0.6),
// // //             ),
// // //             child: Center(
// // //               child: Text(
// // //                 'Calorie Sum: 590 kcal',
// // //                 style: TextStyle(
// // //                   fontSize: 14,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: Colors.white,
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //           // Make each section clickable
// // //           Positioned(
// // //             top: 0,
// // //             left: 0,
// // //             child: GestureDetector(
// // //               onTap: () => navigateToPage(context, 'Snacks'),
// // //               child: Container(
// // //                 width: 175,
// // //                 height: 175,
// // //                 color: Colors.transparent,
// // //                 child: Column(
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   children: [
// // //                     Icon(Icons.fastfood, color: Colors.white),
// // //                     Text('Snacks', style: TextStyle(color: Colors.white)),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //           Positioned(
// // //             top: 0,
// // //             right: 0,
// // //             child: GestureDetector(
// // //               onTap: () => navigateToPage(context, 'Breakfast'),
// // //               child: Container(
// // //                 width: 175,
// // //                 height: 175,
// // //                 color: Colors.transparent,
// // //                 child: Column(
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   children: [
// // //                     Icon(Icons.breakfast_dining, color: Colors.white),
// // //                     Text('Breakfast', style: TextStyle(color: Colors.white)),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //           Positioned(
// // //             bottom: 0,
// // //             left: 0,
// // //             child: GestureDetector(
// // //               onTap: () => navigateToPage(context, 'Lunch'),
// // //               child: Container(
// // //                 width: 175,
// // //                 height: 175,
// // //                 color: Colors.transparent,
// // //                 child: Column(
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   children: [
// // //                     Icon(Icons.lunch_dining, color: Colors.white),
// // //                     Text('Lunch', style: TextStyle(color: Colors.white)),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //           Positioned(
// // //             bottom: 0,
// // //             right: 0,
// // //             child: GestureDetector(
// // //               onTap: () => navigateToPage(context, 'Dinner'),
// // //               child: Container(
// // //                 width: 175,
// // //                 height: 175,
// // //                 color: Colors.transparent,
// // //                 child: Column(
// // //                   mainAxisAlignment: MainAxisAlignment.center,
// // //                   children: [
// // //                     Icon(Icons.dinner_dining, color: Colors.white),
// // //                     Text('Dinner', style: TextStyle(color: Colors.white)),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //           // Text following circular path
// // //           CustomPaint(
// // //             size: Size(250, 250),
// // //             painter: CircularTextPainter(),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // class RadialSectionsPainter extends CustomPainter {
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final Paint paint = Paint()
// //       ..style = PaintingStyle.fill
// //       ..strokeWidth = 2;

// //     // Define the radius for the circle
// //     final double radius = size.width / 2;
// //     final center = Offset(size.width / 2, size.height / 2);

// //     // Colors for each section (room)
// //     final List<Color> colors = [
// //       Colors.blueAccent,
// //       Colors.greenAccent,
// //       Colors.orangeAccent,
// //       Colors.purpleAccent

// //       // Color(0xFF1F5F5B),
// //       // Color(0xFF40C5BD),
// //       // Color(0xFF1F5F5B),
// //       // Color(0xFF40C5BD)
// //     ];

// //     // Draw each quarter (90 degrees each)
// //     for (int i = 0; i < 4; i++) {
// //       paint.color = colors[i];

// //       double startAngle = (i * 90) * 3.1416 / 180; // Start angle (in radians)
// //       double sweepAngle = 90 * 3.1416 / 180; // Sweep angle (in radians)

// //       canvas.drawArc(
// //         Rect.fromCircle(center: center, radius: radius),
// //         startAngle,
// //         sweepAngle,
// //         true,
// //         paint,
// //       );
// //     }
// //   }

// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) {
// //     return false;
// //   }
// // }

// // // class CircularTextPainter extends CustomPainter {
// // //   @override
// // //   void paint(Canvas canvas, Size size) {
// // //     final TextPainter textPainter = TextPainter(
// // //       textAlign: TextAlign.center,
// // //       textDirection: TextDirection.ltr,
// // //     );

// // //     final double radius = size.width / 2;
// // //     final center = Offset(size.width / 2, size.height / 2);
// // //     final List<String> sectionLabels = [
// // //       'Dinner',
// // //       'Lunch',
// // //       'Snacks',
// // //       'Breakfast'
// // //     ];
// // //     final double angleStep = 90 * pi / 180; // 90 degrees per section

// // //     for (int i = 0; i < sectionLabels.length; i++) {
// // //       final label = sectionLabels[i];
// // //       final angle =
// // //           angleStep * (i + 0.5); // Position text in the middle of each section

// // //       final textSpan = TextSpan(
// // //         text: label,
// // //         style: TextStyle(
// // //           color: Colors.white,
// // //           fontSize: 14,
// // //           fontWeight: FontWeight.bold,
// // //         ),
// // //       );
// // //       textPainter.text = textSpan;
// // //       textPainter.layout();

// // //       final x =
// // //           center.dx + (radius + 60) * cos(angle) - (textPainter.width / 2);
// // //       final y =
// // //           center.dy + (radius + 60) * sin(angle) - (textPainter.height / 2);

// // //       textPainter.paint(canvas, Offset(x, y));
// // //     }
// // //   }

// // //   @override
// // //   bool shouldRepaint(covariant CustomPainter oldDelegate) {
// // //     return false;
// // //   }
// // // }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_1/screens/calculate_screen.dart';
import 'package:flutter_application_1/screens/favorite_screen.dart';
import 'package:flutter_application_1/screens/menu_screen.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:math';
import 'calorie_tracking_next_screen.dart';
import 'botton_nav_bar.dart';
import 'homepage.dart';
import 'profile_screen.dart';

class CalorieTrackingScreen extends StatefulWidget {
  @override
  _CalorieTrackingScreenScreenState createState() =>
      _CalorieTrackingScreenScreenState();
}

class _CalorieTrackingScreenScreenState extends State<CalorieTrackingScreen> {
// int _currentIndex = 5+;

  String userWeight = '...';
  String weightGoal = '...';

  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  List<int> calorieData = [];
  // double totalLoggedCalories = 0.0;
  // double dailyGoal = 2000.0;

  List<String> last7Days = [];

  // double get remainingCalories {
  //   return dailyGoal - totalLoggedCalories;
  // }

  final int _currentIndex = 0;

  void navigateToMealScreen(String mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CalorieTrackingNextScreen(mealType: mealType)),
    );
  }

  late List<BarChartGroupData> barGroups;
  late List<String> days;

  @override
  void initState() {
    super.initState();
    // Generate the list of last 7 days when the screen initializes
    _generateLast7Days();
    barGroups = [];
    days = [];
    fetchUserData();
    _loadUserData();
  }

  String formatNumber(int number) {
    return NumberFormat("#,###").format(number);
  }

  // Generate last 7 days
  void _generateLast7Days() {
    last7Days = List.generate(7, (index) {
      DateTime date = DateTime.now().subtract(Duration(days: 6 - index));
      return DateFormat('dd MMM yyyy')
          .format(date); // Format each date as needed
    });
  }

  void _changeDate(int delta) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: delta));
      _generateLast7Days(); // Update the last 7 days when the date changes
    });

    fetchUserData(); // Fetch the data for the newly selected date
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        _generateLast7Days();
      });

      fetchUserData(); // Fetch the data for the newly selected date
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

  //
  Future<void> fetchUserData() async {
    try {
      // Get today's date and previous 6 days
      DateTime today = selectedDate; // Use selectedDate as the base date
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

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        List<int> caloriesSum = await Future.wait(dates.map((date) async {
          int totalCalories = 0;

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
                  color: Color(0xff4D7881),
                  width: 10,
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

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  //
  double? _calculatedBMI() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      return weight / ((height / 100) * (height / 100)); // BMI formula
    }
    return null; // Return null if the input values are invalid
  }

  String _bmiCategory(double? bmi) {
    if (bmi == null) return "N/A";

    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi < 24.9) {
      return "Normal weight";
    } else if (bmi < 29.9) {
      return "Overweight";
    } else {
      return "Obese";
    }
  }

  final List<String> activityLevels = [
    "Sedentary (little to no exercise)",
    "Lightly active (1-3 days/week)",
    "Moderately active (3-5 days/week)",
    "Very active (6-7 days/week)",
    "Super active (very hard exercise, physical job)"
  ];

  String _selectedActivityLevel = "Moderately active (3-5 days/week)";

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

  int _calculateAge(DateTime dob) {
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--; // Adjust age if the birthday hasn't occurred yet this year
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double circleSize = screenWidth * 0.38;
    double buttonSize = screenWidth * 0.44;

    int totalCalorieLimit = (_calculateTDEE() ?? 2000).toInt();

    // Calculate total calories consumed based on the updated barGroups
    int totalCaloriesConsumed =
        barGroups.isNotEmpty ? barGroups.last.barRods[0].toY.toInt() : 0;

    // Calculate remaining calories after fetching new data
    int remainingCalories = totalCalorieLimit - totalCaloriesConsumed;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/0c42e0e25128dfaf306ab0ac15f14d9a.jfif'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.7),
                BlendMode.darken,
              ),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1F5F5B), Color(0xFF40C5BD)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    centerTitle: true,
                    title: Text(
                      'Calorie Tracking',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          letterSpacing: 1),
                    ),
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Homepage()));
                      },
                    ),
                    // actions: [
                    //   IconButton(
                    //     icon: Icon(
                    //       Icons.refresh,
                    //       color: Colors.white,
                    //     ),
                    //     onPressed: _refreshData,
                    //   ),
                    // ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_left,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => _changeDate(-1),
                  ),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Text(
                      DateFormat('dd MMM yyyy').format(selectedDate),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => _changeDate(1),
                  ),
                ],
              ),

              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    //
                    Container(
                      width: screenWidth,
                      height: screenWidth,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Snacks (Top Left)
                          Positioned(
                            top: screenHeight * 0.025,
                            left: screenWidth * 0.05,
                            child: mealTypeButton("Snacks", Icons.fastfood,
                                Colors.blue, buttonSize),
                          ),
                          // Breakfast (Top Right)
                          Positioned(
                            top: screenHeight * 0.025,
                            right: screenWidth * 0.05,
                            child: mealTypeButton(
                                "Breakfast",
                                Icons.breakfast_dining,
                                Colors.green,
                                buttonSize),
                          ),
                          // Lunch (Bottom Left)
                          Positioned(
                            bottom: screenHeight * 0.025,
                            left: screenWidth * 0.05,
                            child: mealTypeButton("Lunch", Icons.lunch_dining,
                                Colors.orange, buttonSize),
                          ),
                          // Dinner (Bottom Right)
                          Positioned(
                            bottom: screenHeight * 0.025,
                            right: screenWidth * 0.05,
                            child: mealTypeButton("Dinner", Icons.dinner_dining,
                                Colors.purple, buttonSize),
                          ),
                        ],
                      ),
                    ),

                    // Remain Calories
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Today', // You can also show selectedDate here
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              remainingCalories < 0
                                  ? 'Exceeded Calorie Limit!'
                                  : 'Calories you can still consume',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: remainingCalories < 0
                                    ? Colors.red
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            formatNumber(remainingCalories),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: remainingCalories < 0
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Info
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40))),
                width: 300,
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            // Row(
                            //   children: [
                            //     Icon(Icons.calendar_month_outlined),
                            //     Text(
                            //       'See more',
                            //       style: TextStyle(
                            //         fontWeight: FontWeight.w600,
                            //       ),
                            //     ),
                            //   ],
                            // ),

                            Text(
                              'Weight / Weight Goal',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  userData?["weight"]?.toString() ?? '...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  ' / ${userData?["weightGoal"]?.toString() ?? '...'} kg.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          color: Colors.grey[600],
                          width: 1,
                          height: 80,
                        ),
                        Column(
                          children: [
                            Text(
                              'Calorie Intake',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.energy_savings_leaf_outlined,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                Text(
                                  ' ${formatNumber(totalCaloriesConsumed)} ',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'kcal',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            // Text(
                            //   'TDEE vs. intake',
                            //   style: TextStyle(fontWeight: FontWeight.w600),
                            // ),
                            // Row(
                            //   children: [
                            //     Icon(
                            //       Icons.energy_savings_leaf_outlined,
                            //       size: 20,
                            //       color: Colors.red,
                            //     ),
                            //     Text(
                            //       ' ${remainingCaloriesNum} ',
                            //       style: TextStyle(
                            //         color: Colors.green,
                            //         fontWeight: FontWeight.w600,
                            //       ),
                            //     ),
                            //     Text(
                            //       'kcal',
                            //       style: TextStyle(
                            //         color: Colors.grey[500],
                            //         fontWeight: FontWeight.w600,
                            //       ),
                            //     )
                            //   ],
                            // )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 5),
                width: 300,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  color: Colors.grey,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Column(
                    //   children: [
                    //     Text(
                    //       '0%',
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //     Text(
                    //       'Progress',
                    //       style: TextStyle(fontWeight: FontWeight.w600),
                    //     ),
                    //   ],
                    // ),
                    Column(
                      children: [
                        Text(
                          'BMI ${_calculatedBMI()?.toStringAsFixed(1) ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _bmiCategory(_calculatedBMI()),
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          formatNumber(_calculateTDEE()?.toInt() ?? 2000),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Total Daily Intake',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // Graph
              // Calorie Tracker
              Padding(
                padding: const EdgeInsets.all(10),
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
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // GestureDetector(
                            //   onTap: () {},
                            //   child: Icon(
                            //     Icons.arrow_back_ios,
                            //     color: Colors.white,
                            //   ),
                            // ),
                            Text(
                              'Calorie Tracker',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // GestureDetector(
                            //   onTap: () {},
                            //   child: Icon(
                            //     Icons.arrow_forward_ios,
                            //     color: Colors.white,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        height: 250,
                        child: isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: BarChart(
                                  BarChartData(
                                    gridData: FlGridData(show: true),
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        axisNameWidget: Text(
                                          "Date",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
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
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          interval: getDynamicInterval(),
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value.toInt().toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              textAlign: TextAlign.right,
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      rightTitles: AxisTitles(
                                        axisNameWidget: Text(
                                          "Calories",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: barGroups,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(color: Colors.black),
        unselectedLabelStyle: TextStyle(color: Colors.black),
        // currentIndex: _currentIndex,
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
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CalorieTrackingScreen()),
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

  double getDynamicInterval() {
    double maxCalories = barGroups.isNotEmpty
        ? barGroups.map((e) => e.barRods[0].toY).reduce((a, b) => a > b ? a : b)
        : 1000;

    if (maxCalories > 8000) return 2000;
    if (maxCalories > 5000) return 1000;
    if (maxCalories > 2000) return 500;
    return 200;
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

  // List<Map<String, dynamic>> recipesForToday = [];

  // Future<void> fetchRecipesForToday() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     try {
  //       DateTime now = DateTime.now();
  //       DateTime startOfDay = DateTime(now.year, now.month, now.day);
  //       DateTime endOfDay = startOfDay.add(Duration(days: 1));

  //       QuerySnapshot snapshot = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(user.uid)
  //           .collection('food_log')
  //           .where('date',
  //               isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
  //           .where('date', isLessThan: Timestamp.fromDate(endOfDay))
  //           .get();

  //       int todayCalories = 0;

  //       if (snapshot.docs.isEmpty) {
  //         print("❌ No recipes found for today.");
  //       } else {
  //         for (var doc in snapshot.docs) {
  //           var recipe = doc['recipe'];
  //           if (recipe == null) continue;

  //           num calories =
  //               recipe['totalNutrients']['ENERC_KCAL']['quantity'] ?? 0;
  //           todayCalories += calories.toInt();
  //         }
  //       }

  //       // Set today's calorie value once, preventing duplicates
  //       setState(() {
  //         calorieData[6] = todayCalories;
  //       });
  //     } catch (e) {
  //       print("❌ Error fetching recipes for today: $e");
  //     }
  //   }
  // }

  // void _fetchCalorieData() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     try {
  //       DateTime now = DateTime.now();
  //       DateTime startOfDay = DateTime(now.year, now.month, now.day);
  //       DateTime sevenDaysAgo = startOfDay.subtract(Duration(days: 6));

  //       List<int> caloriesPerDay = List.filled(7, 0);

  //       // Preserve today's data before fetching historical data
  //       int todayCalories = calorieData[6];

  //       QuerySnapshot snapshot = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(user.uid)
  //           .collection('food_log')
  //           .where('date',
  //               isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
  //           .where('date', isLessThanOrEqualTo: Timestamp.fromDate(startOfDay))
  //           .get();

  //       for (var doc in snapshot.docs) {
  //         var recipe = doc['recipe'];
  //         if (recipe != null &&
  //             recipe['totalNutrients'] != null &&
  //             recipe['totalNutrients']['ENERC_KCAL'] != null) {
  //           num calorie =
  //               recipe['totalNutrients']['ENERC_KCAL']['quantity'] ?? 0;

  //           var dateField = doc['date'];
  //           DateTime date;
  //           if (dateField is Timestamp) {
  //             date = dateField.toDate();
  //           } else if (dateField is String) {
  //             date = DateTime.parse(dateField);
  //           } else {
  //             print("❌ Unexpected date format: $dateField");
  //             continue;
  //           }

  //           for (int i = 0; i < 6; i++) {
  //             DateTime targetDate = startOfDay.subtract(Duration(days: 6 - i));
  //             if (date.day == targetDate.day &&
  //                 date.month == targetDate.month) {
  //               caloriesPerDay[i] += calorie.toInt();
  //               break;
  //             }
  //           }
  //         }
  //       }

  //       setState(() {
  //         calorieData = caloriesPerDay;
  //         calorieData[6] = todayCalories; // Restore today's calories
  //         isLoading = false;
  //       });

  //       print('Calories per day: $calorieData');
  //     } catch (e) {
  //       print("❌ Error fetching calorie data: $e");
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }

  List<BarChartGroupData> _getBarGroups(List<int> calorieData) {
    // Ensure there are at least 7 data points
    List<int> paddedData = List<int>.from(calorieData);
    while (paddedData.length < 7) {
      paddedData.add(0); // Add 0 for missing data
    }

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: paddedData[index].toDouble(),
            color: Colors.white,
          ),
        ],
      );
    });
  }
}
