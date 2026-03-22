import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/student_database_service.dart';
import '../../screens/auth/welcome_screen.dart'; 
import '../student_widgets/profile_activity_item.dart';
import '../student_widgets/profile_notification_item.dart';
import '../student_widgets/profile_setting_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Backend variables
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
  final DatabaseService _dbService = DatabaseService();

  bool meetingReminders = true;
  bool clubAnnouncements = true;

  // Logout Logic
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

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

              // --- DYNAMIC USER CARD ---
              FutureBuilder<DocumentSnapshot>(
                future: _dbService.getUserData(currentUid),
                builder: (context, snapshot) {
                  String name = "Loading...";
                  String email = "...";
                  String initials = "??";

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    name = data['name'] ?? "User";
                    email = data['email'] ?? "No Email";
                    initials = name.isNotEmpty ? name[0].toUpperCase() : "U";
                  }

                  return Container(
                    decoration: cardDecoration(),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: const Color(0xFFE61E6E),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                email,
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Student Account',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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

              // --- DYNAMIC ACTIVITY CARD ---
              Container(
                decoration: cardDecoration(),
                child: Column(
                  children: [
                    // Meetings Count
                    StreamBuilder<QuerySnapshot>(
                      stream: _dbService.getStudentMeetings(currentUid),
                      builder: (context, snapshot) {
                        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                        return ProfileActivityItem(
                          icon: Icons.calendar_today_outlined,
                          iconColor: Colors.blue,
                          iconBgColor: const Color(0xFFEAF2FF),
                          title: 'Total Meetings',
                          value: count.toString(),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    // Clubs Count
                    FutureBuilder<List>(
                      future: _dbService.getClubs(),
                      builder: (context, snapshot) {
                        int count = snapshot.hasData ? snapshot.data!.length : 0;
                        return ProfileActivityItem(
                          icon: Icons.groups_2_outlined,
                          iconColor: Colors.purple,
                          iconBgColor: const Color(0xFFF3E8FF),
                          title: 'Clubs Joined',
                          value: count.toString(),
                        );
                      },
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

              Container(
                decoration: cardDecoration(),
                child: Column(
                  children: [
                    ProfileNotificationItem(
                      title: 'Meeting Reminders',
                      subtitle: 'Get notified about upcoming meetings',
                      value: meetingReminders,
                      onChanged: (value) {
                        setState(() => meetingReminders = value);
                      },
                    ),
                    const Divider(height: 1),
                    ProfileNotificationItem(
                      title: 'Club Announcements',
                      subtitle: 'Receive updates from your clubs',
                      value: clubAnnouncements,
                      onChanged: (value) {
                        setState(() => clubAnnouncements = value);
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

              Container(
                decoration: cardDecoration(),
                child: Column(
                  children: [
                    const ProfileSettingItem(
                      icon: Icons.settings_outlined,
                      title: 'Account Settings',
                    ),
                    const Divider(height: 1),
                    // Functional Logout Item
                    GestureDetector(
                      onTap: _handleLogout,
                      child: const ProfileSettingItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        titleColor: Colors.red,
                        iconColor: Colors.red,
                        showArrow: false,
                      ),
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