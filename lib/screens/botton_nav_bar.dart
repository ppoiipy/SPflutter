import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      indicatorColor: Color(0xff4D7881),
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.black, size: 30),
            label: 'Home'),
        NavigationDestination(
            icon: Icon(Icons.food_bank_outlined, color: Colors.black, size: 30),
            label: 'Menu'),
        NavigationDestination(
            icon: Icon(Icons.favorite_outline, color: Colors.black, size: 30),
            label: 'Favorites'),
        NavigationDestination(
            icon: Icon(Icons.calculate_outlined, color: Colors.black, size: 30),
            label: 'Calculate'),
        NavigationDestination(
            icon: Icon(Icons.person_outline, color: Colors.black, size: 30),
            label: 'Profile'),
      ],
    );
  }
}
