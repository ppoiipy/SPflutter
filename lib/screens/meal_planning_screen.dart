import 'package:flutter/material.dart';
import 'dart:math';
import 'meal_planning_next_screen.dart';

class MealPlanningScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                    'Meal Planning',
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
            SizedBox(height: 50),
            Center(
              child: RadialClickableSections(),
            ),
          ],
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
