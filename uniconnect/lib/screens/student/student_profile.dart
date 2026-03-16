import 'package:flutter/material.dart';
import '../../widgets/profile_activity_item.dart';
import '../../widgets/profile_notification_item.dart';
import '../../widgets/profile_setting_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedIndex = 4;

  bool meetingReminders = true;
  bool clubAnnouncements = true;

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
                'Profile',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 18),

              // USER CARD
              Container(
                decoration: cardDecoration(),
                padding: const EdgeInsets.all(20),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0xFFE61E6E),
                      child: Text(
                        'DU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo User',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'demo@university.edu',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Student Account',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'ACTIVITY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              // ACTIVITY CARD
              Container(
                decoration: cardDecoration(),
                child: const Column(
                  children: [
                    ProfileActivityItem(
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.blue,
                      iconBgColor: Color(0xFFEAF2FF),
                      title: 'Total Meetings',
                      value: '12',
                    ),
                    Divider(height: 1),
                    ProfileActivityItem(
                      icon: Icons.groups_2_outlined,
                      iconColor: Colors.purple,
                      iconBgColor: Color(0xFFF3E8FF),
                      title: 'Clubs Joined',
                      value: '5',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'NOTIFICATIONS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              // NOTIFICATION SETTINGS
              Container(
                decoration: cardDecoration(),
                child: Column(
                  children: [
                    ProfileNotificationItem(
                      title: 'Meeting Reminders',
                      subtitle: 'Get notified about upcoming meetings',
                      value: meetingReminders,
                      onChanged: (value) {
                        setState(() {
                          meetingReminders = value;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    ProfileNotificationItem(
                      title: 'Club Announcements',
                      subtitle: 'Receive updates from your clubs',
                      value: clubAnnouncements,
                      onChanged: (value) {
                        setState(() {
                          clubAnnouncements = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'SETTINGS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              // SETTINGS CARD
              Container(
                decoration: cardDecoration(),
                child: const Column(
                  children: [
                    ProfileSettingItem(
                      icon: Icons.settings_outlined,
                      title: 'Account Settings',
                    ),
                    Divider(height: 1),
                    ProfileSettingItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      showArrow: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
