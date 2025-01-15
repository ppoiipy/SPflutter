import 'package:flutter/material.dart';

class CustomWidgets extends StatelessWidget {
  const CustomWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Transform.translate(
                offset: Offset(-40, -10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 2,
                        // offset: const Offset(0, -40),
                      )
                    ],
                  ),
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Transform.rotate(
                angle: 0.2,
                child: Transform.translate(
                  offset: Offset(-20, -40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(80),
                      boxShadow: [
                        // BoxShadow(
                        //   color: Colors.black.withOpacity(0.3),
                        //   spreadRadius: 2,
                        //   blurRadius: 2,
                        //   // offset: const Offset(0, -40),
                        // )
                      ],
                    ),
                    child: Container(
                      height: 160,
                      width: 370,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(80),
                        color: Color(0xff1f5f5b),
                      ),
                    ),
                  ),
                ),
              ),
              Transform.rotate(
                angle: 0.2,
                child: Transform.translate(
                  offset: Offset(35, -40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(80),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 2,
                          // offset: const Offset(0, -40),
                        )
                      ],
                    ),
                    child: Container(
                      height: 160,
                      width: 370,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(80),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
