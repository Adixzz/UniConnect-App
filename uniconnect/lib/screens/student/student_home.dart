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
                style: TextStyle(fontSize: 15, color: Colors.grey),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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

              

              /// ===== ANNOUNCEMENTS =====
              const Text(
                'Recent Announcements',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
    );
  }
}
