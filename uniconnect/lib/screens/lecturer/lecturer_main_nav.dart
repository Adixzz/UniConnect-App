import 'package:flutter/material.dart';
import 'lecturer_home.dart';
import 'availability_screen.dart';


class LecturerMainNavigation extends StatefulWidget {
  const LecturerMainNavigation({super.key});

  @override
  State<LecturerMainNavigation> createState() => _LecturerMainNavigationState();
}

class _LecturerMainNavigationState extends State<LecturerMainNavigation> {
  int _selectedIndex = 0;

  // List of screens to switch between
  final List<Widget> _screens = [
    const LecturerHomeScreen(),     // Index 0
    const AvailabilityScreen(), // Index 1
    const Center(child: Text("Requests Screen")), // Index 2 (Placeholder)
    const Center(child: Text("Settings Screen")), // Index 3 (Placeholder)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body changes based on which icon is tapped
      body: _screens[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Highlights the correct icon
        onTap: _onItemTapped,         // Changes the screen
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1565C0), // Matches your primary blue
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Availability'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}