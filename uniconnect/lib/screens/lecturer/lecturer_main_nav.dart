import 'package:flutter/material.dart';
import 'lecturer_home.dart';
import 'availability_screen.dart';
// Make sure this path points to where your RequestsScreen is located!
import 'lecturer_request.dart';
// Make sure this path matches where your model is saved!
import '../../models/lecturer_model.dart';

class LecturerMainNavigation extends StatefulWidget {
  // 1. Tell the navigation screen it requires the lecturer's data
  final LecturerModel currentLecturer;

  const LecturerMainNavigation({super.key, required this.currentLecturer});

  @override
  State<LecturerMainNavigation> createState() => _LecturerMainNavigationState();
}

class _LecturerMainNavigationState extends State<LecturerMainNavigation> {
  int _selectedIndex = 0;

  // 2. Make this a 'late' list so we can build it after the widget receives the data
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // 3. Initialize the screens here and pass the data to both Home and Requests!
    _screens = [
      LecturerHomeScreen(currentLecturer: widget.currentLecturer), // Index 0
      const AvailabilityScreen(), // Index 1
      RequestsScreen(
        currentLecturer: widget.currentLecturer,
      ), // Index 2 (Updated to live screen!)
      const Center(child: Text("Settings Screen")), // Index 3 (Placeholder)
    ];
  }

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
        onTap: _onItemTapped, // Changes the screen
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1565C0), // Matches your primary blue
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Availability',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Requests'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
