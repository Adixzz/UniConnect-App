import 'package:flutter/material.dart';
import 'lecturer_home.dart';
import 'availability_screen.dart';
import 'lecturer_request.dart';
import 'lecturer_settings.dart'; 
import '../../models/lecturer_model.dart';

class LecturerMainNavigation extends StatefulWidget {
  final LecturerModel currentLecturer;

  const LecturerMainNavigation({super.key, required this.currentLecturer});

  @override
  State<LecturerMainNavigation> createState() => _LecturerMainNavigationState();
}

class _LecturerMainNavigationState extends State<LecturerMainNavigation> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

 @override
  void initState() {
    super.initState();
    _screens = [
      LecturerHomeScreen(currentLecturer: widget.currentLecturer), 
      AvailabilityScreen(currentLecturer: widget.currentLecturer), 
      RequestsScreen(currentLecturer: widget.currentLecturer), 
      
      LecturerSettingsScreen(currentLecturer: widget.currentLecturer), 
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