import 'package:flutter/material.dart';
import 'package:uniconnect/screens/student_screens/notification_history_screen.dart';
import 'student_home.dart';
import 'student_profile.dart';
import 'student meeting_request_screen.dart';
import 'club_list_screen.dart';

class StudentMainNavigation extends StatefulWidget {
  const StudentMainNavigation({super.key});

  @override
  State<StudentMainNavigation> createState() => _StudentMainNavigationState();
}

class _StudentMainNavigationState extends State<StudentMainNavigation> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const StudentHomeScreen(),
    const MeetingsScreen(),
    const ClubListScreen(),
    const NotificationHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        selectedIndex: currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.blue),
            label: "Home",
          ),

          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: Colors.blue),
            label: "Meetings",
          ),

          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, color: Colors.blue),
            label: "Clubs",
          ),

          NavigationDestination(
            icon: Badge(
              smallSize: 8,
              child: Icon(Icons.notifications_none_outlined),
            ),
            selectedIcon: Badge(
              smallSize: 8,
              child: Icon(Icons.notifications, color: Colors.blue),
            ),
            label: "Alerts",
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.blue),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
