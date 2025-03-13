// import 'package:flutter/material.dart';
// import 'custom_bottom_bar.dart';
// import 'package:flutter_application_1/screens/homepage.dart';
// import 'package:flutter_application_1/screens/menu_screen.dart';
// import 'package:flutter_application_1/screens/favorite_screen.dart';
// import 'package:flutter_application_1/screens/calculate_screen.dart';
// import 'package:flutter_application_1/screens/profile_screen.dart';

// class ScreenSelector extends StatefulWidget {
//   const ScreenSelector({super.key});

//   @override
//   _ScreenSelectorState createState() => _ScreenSelectorState();
// }

// class _ScreenSelectorState extends State<ScreenSelector> {
//   int _selectedIndex = 0;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('GinRaiDee App'),
//         centerTitle: true,
//       ),
//       body: _getScreen(_selectedIndex),
//       bottomNavigationBar: CustomBottomBar(
//         selectedIndex: _selectedIndex,
//         onItemTapped: _onItemTapped,
//       ),
//     );
//   }

//   Widget _getScreen(int index) {
//     switch (index) {
//       case 0:
//         return Homepage();
//       case 1:
//         return MenuScreen();
//       case 2:
//         return FavoriteScreen();
//       case 3:
//         return CalculateScreen();
//       case 4:
//         return ProfileScreen();
//       default:
//         return Homepage();
//     }
//   }
// }
