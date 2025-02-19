import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'calorie_tracking_next_screen.dart';

class CalorieTrackingScreen extends StatelessWidget {
  List<BarChartGroupData> _getBarGroups() {
    return [
      BarChartGroupData(
          x: 0, barRods: [BarChartRodData(toY: 40, color: Color(0xff4D7881))]),
      BarChartGroupData(
          x: 1, barRods: [BarChartRodData(toY: 20, color: Color(0xff4D7881))]),
      BarChartGroupData(
          x: 2, barRods: [BarChartRodData(toY: 50, color: Colors.red)]),
      BarChartGroupData(
          x: 3, barRods: [BarChartRodData(toY: 60, color: Colors.red)]),
      BarChartGroupData(
          x: 4, barRods: [BarChartRodData(toY: 24, color: Color(0xff4D7881))]),
      BarChartGroupData(
          x: 5, barRods: [BarChartRodData(toY: 54, color: Colors.red)]),
      BarChartGroupData(
          x: 6, barRods: [BarChartRodData(toY: 48, color: Color(0xff4D7881))]),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                        Navigator.pop(context);
                      },
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Action for calendar icon
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Circle
              Center(
                child: RadialClickableSections(),
              ),

              SizedBox(height: 30),

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
                            Row(
                              children: [
                                Icon(Icons.calendar_month_outlined),
                                Text(
                                  'See more',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '85',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                                Text(
                                  ' / 50 kg.',
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
                              'Energy Intake',
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
                                  ' +590 ',
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
                            Text(
                              'TDEE vs. intake',
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
                                  ' 1770 ',
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
                            )
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
                    Column(
                      children: [
                        Text(
                          '0%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Progress',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'BMI 26.2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Overweight',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '2360',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'TDEE',
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
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            barGroups: _getBarGroups(),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class RadialClickableSections extends StatelessWidget {
  void navigateToPage(BuildContext context, String pageName) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MealPlanningNextScreen(pageName: pageName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radial sections
          CustomPaint(
            size: Size(350, 350), // Set the size of the circle
            painter: RadialSectionsPainter(),
          ),
          // Calorie sum in the center
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.6),
            ),
            child: Center(
              child: Text(
                'Calorie Sum: 500 kcal', // Replace with actual calorie sum
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Make each section clickable
          Positioned(
            top: 0,
            left: 0,
            child: GestureDetector(
              onTap: () => navigateToPage(context, 'Snacks'),
              child: Container(
                width: 175,
                height: 175,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fastfood, color: Colors.white),
                    Text('Snacks', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => navigateToPage(context, 'Breakfast'),
              child: Container(
                width: 175,
                height: 175,
                color: Colors.transparent, // Make this section transparent
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.breakfast_dining, color: Colors.white),
                    Text('Breakfast', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: GestureDetector(
              onTap: () => navigateToPage(context, 'Lunch'),
              child: Container(
                width: 175,
                height: 175,
                color: Colors.transparent, // Make this section transparent
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lunch_dining, color: Colors.white),
                    Text('Lunch', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => navigateToPage(context, 'Dinner'),
              child: Container(
                width: 175,
                height: 175,
                color: Colors.transparent, // Make this section transparent
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dinner_dining, color: Colors.white),
                    Text('Dinner', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          // Text following circular path
          CustomPaint(
            size: Size(250, 250),
            painter: CircularTextPainter(),
          ),
        ],
      ),
    );
  }
}

class RadialSectionsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    // Define the radius for the circle
    final double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Colors for each section (room)
    final List<Color> colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent

      // Color(0xFF1F5F5B),
      // Color(0xFF40C5BD),
      // Color(0xFF1F5F5B),
      // Color(0xFF40C5BD)
    ];

    // Draw each quarter (90 degrees each)
    for (int i = 0; i < 4; i++) {
      paint.color = colors[i];

      double startAngle = (i * 90) * 3.1416 / 180; // Start angle (in radians)
      double sweepAngle = 90 * 3.1416 / 180; // Sweep angle (in radians)

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CircularTextPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final double radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final List<String> sectionLabels = [
      'Dinner',
      'Lunch',
      'Snacks',
      'Breakfast'
    ];
    final double angleStep = 90 * pi / 180; // 90 degrees per section

    for (int i = 0; i < sectionLabels.length; i++) {
      final label = sectionLabels[i];
      final angle =
          angleStep * (i + 0.5); // Position text in the middle of each section

      final textSpan = TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.text = textSpan;
      textPainter.layout();

      final x =
          center.dx + (radius + 60) * cos(angle) - (textPainter.width / 2);
      final y =
          center.dy + (radius + 60) * sin(angle) - (textPainter.height / 2);

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
