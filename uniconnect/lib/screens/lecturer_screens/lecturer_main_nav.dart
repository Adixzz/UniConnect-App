import 'package:flutter/material.dart';
import 'lecturer_home.dart';
import 'availability_screen.dart';
import 'lecturer_request.dart';
import 'lecturer_notifications_screen.dart';
import 'lecturer_settings.dart'; 
import '../../models/lecturer_model.dart';
import '../../services/lecturer_database_service.dart'; 

class LecturerMainNavigation extends StatefulWidget {
  final String lecturerUid;

  const LecturerMainNavigation({super.key, required this.lecturerUid});

  @override
  State<LecturerMainNavigation> createState() => _LecturerMainNavigationState();
}

class _LecturerMainNavigationState extends State<LecturerMainNavigation> {
  int _selectedIndex = 0;
  final LecturerDatabaseService _dbService = LecturerDatabaseService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- NEW: Use FutureBuilder to fetch the lecturer data ---
    return FutureBuilder(
      future: _dbService.getUserData(widget.lecturerUid),
      builder: (context, snapshot) {
        // 1. Show loading while fetching the profile
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Handle Errors
        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Error loading profile. Please log in again.")),
          );
        }

        // 3. Data is ready! Convert to LecturerModel
        final lecturer = LecturerModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        // Define the screens now that we have the lecturer data
        final List<Widget> screens = [
          LecturerHomeScreen(currentLecturer: lecturer), 
          AvailabilityScreen(currentLecturer: lecturer), 
          RequestsScreen(currentLecturer: lecturer), 
          LecturerNotificationsScreen(currentLecturer: lecturer), 
          LecturerSettingsScreen(currentLecturer: lecturer), 
        ];

        return Scaffold(
          body: screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex, 
            onTap: _onItemTapped, 
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1565C0), 
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Availability'),
              BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Requests'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        );
      },
    );
  }
}