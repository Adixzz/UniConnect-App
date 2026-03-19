import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/meeting_models.dart';
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
  // Use enum to track 3 states now
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

              // New 3-Tab Toggle
              _buildTabToggle(),

              const SizedBox(height: 24),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: DatabaseService().getStudentMeetings(currentUid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF10B981),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    final List<MeetingDataContainer>
                    allMeetings = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String status =
                          data['status'] ?? "Pending"; // Capture status first

                      return MeetingDataContainer(
                        id: doc.id,
                        meeting: Meeting(
                          initials: (data['lecturerName'] ?? "U")[0]
                              .toUpperCase(),
                          name: data['lecturerName'] ?? "Unknown",
                          subject: data['moduleName'] ?? "General",
                          date: data['date'] ?? "",
                          time: data['time'] ?? "",
                          // Use the dynamic location from the database we set up!
                          location: data['location'] ?? "Consultation Room",
                          status: status,
                          // ONLY show the button if it's Pending or Accepted
                          showCancelButton:
                              status == 'Pending' ||
                              status == 'Accepted' ||
                              status == 'Confirmed',
                        ),
                      );
                    }).toList();

                    final now = DateTime.now();

                    // --- ENHANCED FILTERING FOR 3 TABS ---
                    final filteredData = allMeetings.where((container) {
                      final m = container.meeting;
                      DateTime meetingTime = _parseDateTime(m.date, m.time);
                      bool isExpired = now.isAfter(
                        meetingTime.add(const Duration(minutes: 30)),
                      );

                      if (selectedTab == MeetingTab.upcoming) {
                        // Confirmed/Accepted only + Not Expired
                        return (m.status == 'Accepted' ||
                                m.status == 'Confirmed') &&
                            !isExpired;
                      } else if (selectedTab == MeetingTab.pending) {
                        // Pending only + Not Expired
                        return m.status == 'Pending' && !isExpired;
                      } else {
                        // Past: Anything Finished OR anything Expired
                        bool isFinished =
                            (m.status == 'Completed' ||
                            m.status == 'Cancelled' ||
                            m.status == 'Declined');
                        return isFinished || isExpired;
                      }
                    }).toList();

                    if (filteredData.isEmpty) return _buildEmptyState();

                    return ListView.separated(
                      itemCount: filteredData.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final container = filteredData[index];
                        return MeetingCard(
                          meeting: container.meeting,
                          onCancel: () async {
                            bool? confirm = await _showCancelDialog();
                            if (confirm == true) {
                              final messenger = ScaffoldMessenger.of(context);
                              await DatabaseService().cancelMeeting(
                                container.id,
                              );
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text("Meeting cancelled"),
                                ),
                              );
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
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                : [],
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

  // --- HELPERS (Keep your existing _parseDateTime, _showCancelDialog, etc.) ---
  DateTime _parseDateTime(String dateStr, String timeStr) {
    try {
      List<String> dateParts = dateStr.split('/');
      int day = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int year = int.parse(dateParts[2]);
      List<String> timeParts = timeStr.split(' ');
      String timeOnly = timeParts[0];
      String period = timeParts[1];
      int hour = int.parse(timeOnly.split(':')[0]);
      int minute = int.parse(timeOnly.split(':')[1]);
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<bool?> _showCancelDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Meeting"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String msg = "";
    if (selectedTab == MeetingTab.upcoming) msg = "No confirmed meetings.";
    if (selectedTab == MeetingTab.pending) msg = "No pending requests.";
    if (selectedTab == MeetingTab.past) msg = "No past history.";

    return Center(
      child: Text(msg, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildRequestButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RequestChoiceScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Request a Meeting',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
