import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../models/meeting_models.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
  final DatabaseService _dbService = DatabaseService();
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F9FD),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStatsRow(),
            const SizedBox(height: 32),
            _buildUpcomingSection(),
            const SizedBox(height: 32), // Spacing for new section
            _buildPendingSection(),     // NEW SECTION
          ],
        ),
      ),
    ),
  );
}

  // 1. DYNAMIC GREETING
  Widget _buildHeader() {
    return FutureBuilder<DocumentSnapshot>(
      future: _dbService.getUserData(currentUid),
      builder: (context, snapshot) {
        String name = "User";
        if (snapshot.hasData && snapshot.data!.exists) {
          name = snapshot.data!.get('name') ?? "User";
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Good Morning", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(name, 
              style: const TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        );
      },
    );
  }

  // 2. DYNAMIC STATS (Meetings & Clubs)
  Widget _buildStatsRow() {
    return Row(
      children: [
        // Live Meeting Count
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _dbService.getStudentMeetings(currentUid),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return _statCard("Meetings", count.toString(), Icons.calendar_today, Colors.blue);
            },
          ),
        ),
        const SizedBox(width: 16),
        // Club Count
        Expanded(
          child: FutureBuilder<List>(
            future: _dbService.getClubs(),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.length : 0;
              return _statCard("Clubs", count.toString(), Icons.groups, Colors.green);
            },
          ),
        ),
      ],
    );
  }

Widget _buildUpcomingSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Upcoming Meetings",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      StreamBuilder<QuerySnapshot>(
        stream: _dbService.getStudentMeetings(currentUid),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text("No upcoming meetings scheduled.");
          }

          final now = DateTime.now();

          // Filter logic
          final filteredDocs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String status = data['status'] ?? '';
            
            // 1. Only show 'Accepted' or 'Confirmed'
            if (status != 'Accepted' && status != 'Confirmed') return false;

            // 2. Filter out meetings passed by more than 30 minutes
            try {
              DateTime meetingDateTime = _parseDateTime(data['date'], data['time']);
              // Keep meeting if: meetingTime > (now - 30 minutes)
              return meetingDateTime.isAfter(now.subtract(const Duration(minutes: 30)));
            } catch (e) {
              return true; // Keep it if parsing fails to avoid missing meetings
            }
          }).toList();

          if (filteredDocs.isEmpty) {
            return const Text("No recently accepted meetings.");
          }

          // Show the top 3 relevant meetings
          var docsToShow = filteredDocs.take(3).toList();

          return Column(
            children: docsToShow.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _upcomingMeetingTile(
                data['lecturerName'] ?? "Lecturer",
                "${data['date']} at ${data['time']}",
                data['status'] ?? "Accepted",
              );
            }).toList(),
          );
        },
      ),
    ],
  );
}

// 2. ADD THIS NEW PENDING SECTION METHOD
Widget _buildPendingSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Pending Requests",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      StreamBuilder<QuerySnapshot>(
        stream: _dbService.getStudentMeetings(currentUid),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text("No pending requests.");
          }

          // Filter specifically for 'Pending' status
          final pendingDocs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'Pending';
          }).toList();

          if (pendingDocs.isEmpty) {
            return const Text("No pending requests at the moment.");
          }

          // Show top 2 pending requests to keep dashboard clean
          var docsToShow = pendingDocs.take(2).toList();

          return Column(
            children: docsToShow.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _upcomingMeetingTile(
                data['lecturerName'] ?? "Lecturer",
                "${data['date']} at ${data['time']}",
                "Pending", // Hardcoded label for this section
              );
            }).toList(),
          );
        },
      ),
    ],
  );
}

// HELPER TO CONVERT STRING DATE/TIME TO DATETIME OBJECT
DateTime _parseDateTime(String dateStr, String timeStr) {
  // Assuming date format is "d/M/yyyy" (e.g. 18/3/2026)
  List<String> dateParts = dateStr.split('/');
  int day = int.parse(dateParts[0]);
  int month = int.parse(dateParts[1]);
  int year = int.parse(dateParts[2]);

  // Parsing Time (e.g. "9:15 PM" or "11:10 PM")
  int hour = int.parse(timeStr.split(':')[0]);
  int minute = int.parse(timeStr.split(':')[1].split(' ')[0]);
  String period = timeStr.split(' ')[1]; // AM or PM

  if (period == 'PM' && hour != 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;

  return DateTime(year, month, day, hour, minute);
}

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _upcomingMeetingTile(String name, String dateTime, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(dateTime, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'Accepted' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status, style: TextStyle(color: status == 'Accepted' ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}