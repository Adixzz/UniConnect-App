import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';

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
              const SizedBox(height: 32),
              _buildPendingSection(),
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

  // 3. UPCOMING MEETINGS SECTION
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
            if (!snapshot.hasData) return const SizedBox();

            final now = DateTime.now();
            final filteredDocs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final String status = data['status'] ?? '';
              if (status != 'Accepted' && status != 'Confirmed') return false;
              try {
                DateTime meetingEndTime = _parseEndDateTime(data['date'], data['time']);
                return meetingEndTime.isAfter(now);
              } catch (e) { return true; }
            }).toList();

            // Display Empty State if no meetings
            if (filteredDocs.isEmpty) {
              return _buildEmptyState(
                icon: Icons.event_available_outlined,
                message: "No upcoming meetings scheduled.",
              );
            }

            filteredDocs.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              return _parseEndDateTime(aData['date'], aData['time'])
                  .compareTo(_parseEndDateTime(bData['date'], bData['time']));
            });

            return Column(
              children: filteredDocs.take(3).map((doc) {
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

  // 4. PENDING REQUESTS SECTION
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
            if (!snapshot.hasData) return const SizedBox();

            final pendingDocs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] == 'Pending';
            }).toList();

            // Display Empty State if no requests
            if (pendingDocs.isEmpty) {
              return _buildEmptyState(
                icon: Icons.hourglass_empty_rounded,
                message: "No pending requests at the moment.",
              );
            }

            return Column(
              children: pendingDocs.take(2).map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _upcomingMeetingTile(
                  data['lecturerName'] ?? "Lecturer",
                  "${data['date']} at ${data['time']}",
                  "Pending",
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // --- NEW: POLISHED EMPTY STATE WIDGET ---
  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Use the Meetings tab to request a new meeting.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // --- REWRITTEN: ROBUST DATE/TIME PARSING ---
  DateTime _parseEndDateTime(String dateStr, String timeRange) {
    try {
      int year = 2026; 
      int month = DateTime.now().month;
      int day = DateTime.now().day;

      if (dateStr.contains('/')) {
        List<String> dateParts = dateStr.split('/');
        day = int.parse(dateParts[0]);
        month = int.parse(dateParts[1]);
        year = int.parse(dateParts[2]);
        if (year < 100) year += 2000;
      } else {
        String cleanDate = dateStr.replaceAllMapped(
          RegExp(r'([a-zA-Z]+)(\d+)'), 
          (match) => '${match.group(1)} ${match.group(2)}'
        ).trim();
        DateTime parsed = DateFormat("MMM d").parse(cleanDate);
        month = parsed.month;
        day = parsed.day;
      }

      String timeToParse = timeRange.contains('-') 
          ? timeRange.split('-')[1].trim() 
          : timeRange.trim();

      timeToParse = timeToParse.replaceAll('.', ':');
      final parts = timeToParse.split(" ");
      final hm = parts[0].split(":");
      int hour = int.parse(hm[0]);
      int min = int.parse(hm[1]);
      
      if (parts[1].toUpperCase() == 'PM' && hour != 12) hour += 12;
      if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;

      return DateTime(year, month, day, hour, min);
    } catch (e) {
      return DateTime(2000, 1, 1);
    }
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
          CircleAvatar(
            backgroundColor: (status == 'Accepted' ? Colors.green : Colors.orange).withOpacity(0.1),
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', 
              style: TextStyle(color: status == 'Accepted' ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
          ),
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
            child: Text(status, 
              style: TextStyle(
                color: status == 'Accepted' ? Colors.green : Colors.orange, 
                fontSize: 10, 
                fontWeight: FontWeight.bold
              )
            ),
          ),
        ],
      ),
    );
  }
}