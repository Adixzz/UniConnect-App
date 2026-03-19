import 'package:flutter/material.dart';
import 'lecturer_home.dart';
import 'availability_screen.dart';
// Make sure this path points to where your RequestsScreen is located!
import 'lecturer_request.dart';
// Make sure this path matches where your model is saved!
import '../../models/lecturer_model.dart';

class LecturerMainNavigation extends StatefulWidget {
  // 1. Navigation screen requires the full lecturer model
  final LecturerModel currentLecturer;

  const LecturerMainNavigation({super.key, required this.currentLecturer});

  @override
  State<LecturerMainNavigation> createState() => _LecturerMainNavigationState();
}

class _LecturerMainNavigationState extends State<LecturerMainNavigation> {
  int _selectedIndex = 0;

  // 2. Late list built after the widget receives data
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // 3. Initialize screens and pass the FULL model to each child widget
    _screens = [
      LecturerHomeScreen(currentLecturer: widget.currentLecturer), 
      
      // FIXED: Passing the entire model to match the updated AvailabilityScreen constructor
      AvailabilityScreen(currentLecturer: widget.currentLecturer), 
      
      RequestsScreen(currentLecturer: widget.currentLecturer), 
      
      const Center(child: Text("Settings Screen")), 
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
        currentIndex: _selectedIndex, 
        onTap: _onItemTapped, 
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1565C0), 
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