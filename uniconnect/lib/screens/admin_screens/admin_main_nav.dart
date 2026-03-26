import 'package:flutter/material.dart';
import 'package:uniconnect/screens/admin_screens/manage_timetable_screen.dart';
import 'package:uniconnect/screens/admin_screens/manage_users_screen.dart';
import 'manage_users_screen.dart';
import 'manage_club_screen.dart';
import 'manage_timetable_screen.dart';
import 'admin_settings.dart';

class AdminMainNav extends StatefulWidget {
  const AdminMainNav({super.key});

  @override
  State<AdminMainNav> createState() => _AdminMainNavState();
}

class _AdminMainNavState extends State<AdminMainNav> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ManageUsersScreen(),
    const ClubManageScreen(),  
    const TimetableManageScreen(),
    const AdminSettingsScreen(),
  ];

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
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Manage Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Manage Clubs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Manage Timetable',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}