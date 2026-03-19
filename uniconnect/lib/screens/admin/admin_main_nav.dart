import 'package:flutter/material.dart';
import 'add_user_screen.dart';
import 'manage_club_screen.dart';

class AdminMainNav extends StatefulWidget {
  const AdminMainNav({super.key});

  @override
  State<AdminMainNav> createState() => _AdminMainNavState();
}

class _AdminMainNavState extends State<AdminMainNav> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AddUserScreen(),           // index 1 — add user
    const ClubManageScreen(),        // index 2 — manage clubs
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
            icon: Icon(Icons.dashboard),
            label: 'Add User',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Manage Clubs',
          ),
        ],
      ),
    );
  }
}