import 'package:flutter/material.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/meeting_item.dart';
import '../../widgets/lecturer_item.dart';
import '../../widgets/announcement_item.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int selectedIndex = 0;

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 8),

              const Text(
                'Good Morning',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Demo User',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              /// ===== TOP CARDS =====
              Row(
                children: const [

                  Expanded(
                    child: StatCard(
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.blue,
                      iconBgColor: Color(0xFFEAF2FF),
                      count: '2',
                      label: 'Meetings',
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: StatCard(
                      icon: Icons.groups_outlined,
                      iconColor: Colors.green,
                      iconBgColor: Color(0xFFEAF8EE),
                      count: '5',
                      label: 'Clubs',
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 28),

              /// ===== UPCOMING MEETINGS =====
              const Text(
                'Upcoming Meetings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                decoration: cardDecoration(),
                padding: const EdgeInsets.all(14),
                child: const Column(
                  children: [

                    MeetingItem(
                      title: 'Dr. Sarah Johnson',
                      dateTime: '2025-10-28 at 10:00 AM',
                      statusText: 'confirmed',
                      statusColor: Colors.blue,
                    ),

                    Divider(height: 24),

                    MeetingItem(
                      title: 'Prof. Michael Chen',
                      dateTime: '2025-10-29 at 2:00 PM',
                      statusText: 'pending',
                      statusColor: Color(0xFFE5E7EB),
                      statusTextColor: Colors.black87,
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// ===== FIND LECTURERS =====
              const Text(
                'Find Lecturers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Container(
                decoration: cardDecoration(),
                padding: const EdgeInsets.all(14),
                child: const Column(
                  children: [

                    LecturerItem(
                      initials: 'DJ',
                      avatarColor: Colors.red,
                      name: 'Dr. Sarah Johnson',
                      subject: 'Data Structures',
                      location: 'Building A, Room 201',
                      buttonColor: Colors.blue,
                    ),

                    Divider(height: 24),

                    LecturerItem(
                      initials: 'PC',
                      avatarColor: Colors.red,
                      name: 'Prof. Michael Chen',
                      subject: 'Web Development',
                      location: 'Building B, Room 305',
                      buttonColor: Colors.blue,
                    ),

                    Divider(height: 24),

                    LecturerItem(
                      initials: 'DB',
                      avatarColor: Colors.cyan,
                      name: 'Dr. Emily Brown',
                      subject: 'Database Systems',
                      location: 'Building A, Room 207',
                      buttonColor: Color(0xFF7CB5F9),
                    ),

                    Divider(height: 24),

                    LecturerItem(
                      initials: 'PW',
                      avatarColor: Colors.pink,
                      name: 'Prof. James Wilson',
                      subject: 'Software Engineering',
                      location: 'Building C, Room 102',
                      buttonColor: Colors.blue,
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// ===== ANNOUNCEMENTS =====
              const Text(
                'Recent Announcements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                decoration: cardDecoration(),
                padding: const EdgeInsets.all(14),
                child: const Column(
                  children: [

                    AnnouncementItem(
                      title: 'Hackathon 2025',
                      subtitle: 'Tech Society',
                      timeAgo: '2 hours ago',
                      isImportant: true,
                    ),

                    Divider(height: 24),

                    AnnouncementItem(
                      title: 'Annual Play Auditions',
                      subtitle: 'Drama Club',
                      timeAgo: '5 hours ago',
                    ),

                    Divider(height: 24),

                    AnnouncementItem(
                      title: 'Football Tournament',
                      subtitle: 'Sports Club',
                      timeAgo: '1 day ago',
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      /// ===== BOTTOM NAVIGATION =====
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        destinations: const [

          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.blue),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month, color: Colors.blue),
            label: 'Meetings',
          ),

          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups, color: Colors.blue),
            label: 'Clubs',
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
            label: 'Alerts',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.blue),
            label: 'Profile',
          ),

        ],
      ),
    );
  }
}