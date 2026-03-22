import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/student_models/meeting_models.dart';
import '../../widgets/meeting_cards.dart';
import '../../services/database_service.dart';
import 'request_choice_screen.dart';

// Helper for filtering
enum MeetingTab { upcoming, pending, past }

class MeetingDataContainer {
  final String id;
  final Meeting meeting;
  MeetingDataContainer({required this.id, required this.meeting});
}

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({Key? key}) : super(key: key);

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  MeetingTab selectedTab = MeetingTab.upcoming;

  final Color primaryGreen = const Color(0xFF10B981);
  final Color bgColor = const Color(0xFFF4F6F9);
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meetings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              _buildTabToggle(),

              const SizedBox(height: 24),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: DatabaseService().getStudentMeetings(currentUid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF10B981)),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    final now = DateTime.now();

                    final List<MeetingDataContainer> allMeetings = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String status = data['status'] ?? "Pending";
                      final String dateStr = data['date'] ?? "";
                      final String timeStr = data['time'] ?? "";

                      // Determine if the meeting has passed
                      DateTime meetingEndTime = _parseEndDateTime(dateStr, timeStr);
                      bool isExpired = now.isAfter(meetingEndTime);

                      return MeetingDataContainer(
                        id: doc.id,
                        meeting: Meeting(
                          initials: (data['lecturerName'] ?? "U")[0].toUpperCase(),
                          name: data['lecturerName'] ?? "Unknown",
                          subject: data['moduleName'] ?? "General",
                          date: dateStr,
                          time: timeStr,
                          location: data['location'] ?? "Consultation Room",
                          status: status,
                          // --- UPDATED LOGIC: Only show cancel if status is active AND meeting hasn't passed ---
                          showCancelButton: (status == 'Pending' || 
                                             status == 'Accepted' || 
                                             status == 'Confirmed') && 
                                             !isExpired,
                        ),
                      );
                    }).toList();

                    // --- ROBUST FILTERING LOGIC ---
                    final filteredData = allMeetings.where((container) {
                      final m = container.meeting;
                      DateTime meetingEndTime = _parseEndDateTime(m.date, m.time);
                      bool isPast = now.isAfter(meetingEndTime);

                      if (selectedTab == MeetingTab.upcoming) {
                        return (m.status == 'Accepted' || m.status == 'Confirmed') && !isPast;
                      } else if (selectedTab == MeetingTab.pending) {
                        return m.status == 'Pending' && !isPast;
                      } else {
                        bool isFinishedStatus = (m.status == 'Completed' || m.status == 'Cancelled' || m.status == 'Declined');
                        return isFinishedStatus || isPast;
                      }
                    }).toList();

                    // Sort: Upcoming/Pending show soonest first; Past shows most recent first
                    filteredData.sort((a, b) {
                      DateTime aTime = _parseEndDateTime(a.meeting.date, a.meeting.time);
                      DateTime bTime = _parseEndDateTime(b.meeting.date, b.meeting.time);
                      return selectedTab == MeetingTab.past ? bTime.compareTo(aTime) : aTime.compareTo(bTime);
                    });

                    if (filteredData.isEmpty) return _buildEmptyState();

                    return ListView.separated(
                      itemCount: filteredData.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final container = filteredData[index];
                        return MeetingCard(
                          meeting: container.meeting,
                          onCancel: () async {
                            bool? confirm = await _showCancelDialog();
                            if (confirm == true) {
                              final messenger = ScaffoldMessenger.of(context);
                              await DatabaseService().cancelMeeting(container.id);
                              if (!mounted) return;
                              messenger.showSnackBar(const SnackBar(content: Text("Meeting cancelled")));
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              _buildRequestButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB TOGGLE WIDGET ---
  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tabButton("Upcoming", MeetingTab.upcoming),
          _tabButton("Pending", MeetingTab.pending),
          _tabButton("Past", MeetingTab.past),
        ],
      ),
    );
  }

  Widget _tabButton(String title, MeetingTab tab) {
    bool isSelected = selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // --- ROBUST PARSER ---
  DateTime _parseEndDateTime(String dateStr, String timeRange) {
    try {
      int year = 2026;
      int month = DateTime.now().month;
      int day = DateTime.now().day;

      if (dateStr.contains('/')) {
        List<String> parts = dateStr.split('/');
        day = int.parse(parts[0]);
        month = int.parse(parts[1]);
        year = int.parse(parts[2]);
        if (year < 100) year += 2000;
      } else {
        String clean = dateStr.replaceAllMapped(RegExp(r'([a-zA-Z]+)(\d+)'), (m) => '${m.group(1)} ${m.group(2)}').trim();
        DateTime parsed = DateFormat("MMM d").parse(clean);
        month = parsed.month;
        day = parsed.day;
      }

      String timeToParse = timeRange.contains('-') ? timeRange.split('-')[1].trim() : timeRange.trim();
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

  Future<bool?> _showCancelDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Meeting"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String msg = "";
    if (selectedTab == MeetingTab.upcoming) msg = "No confirmed meetings.";
    if (selectedTab == MeetingTab.pending) msg = "No pending requests.";
    if (selectedTab == MeetingTab.past) msg = "No past history.";
    return Center(child: Text(msg, style: const TextStyle(color: Colors.grey)));
  }

  Widget _buildRequestButton() {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RequestChoiceScreen())),
        style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: const Text('Request a Meeting', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}