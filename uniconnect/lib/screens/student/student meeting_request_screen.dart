import 'package:flutter/material.dart';
import '../../models/meeting_models.dart';
import '../../widgets/meeting_cards.dart';
import 'faculty_selection_screen.dart';
import 'request_choice_screen.dart'; // Make sure this is imported

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({Key? key}) : super(key: key);

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  bool isUpcomingSelected = true;
  final Color primaryGreen = const Color(0xFF10B981);
  final Color bgColor = const Color(0xFFF4F6F9);

  // Mock Data
  final List<Meeting> upcomingMeetings = [
    Meeting(
      initials: 'DJ',
      name: 'Dr. Sarah Johnson',
      subject: 'Data Structures',
      date: '2025-10-28',
      time: '10:00 AM - 10:30 AM',
      location: 'Building A, Room 201',
      status: 'Confirmed',
      showCancelButton: true,
    ),
    Meeting(
      initials: 'PC',
      name: 'Prof. Michael Chen',
      subject: 'Web Development',
      date: '2025-10-29',
      time: '2:00 PM - 3:00 PM',
      location: 'Building B, Room 305',
      status: 'Pending',
    ),
  ];

  final List<Meeting> pastMeetings = [
    Meeting(
      initials: 'AS',
      name: 'Dr. Alice Smith',
      subject: 'Algorithms',
      date: '2025-09-15',
      time: '11:00 AM - 12:00 PM',
      location: 'Online',
      status: 'Confirmed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    List<Meeting> currentList = isUpcomingSelected ? upcomingMeetings : pastMeetings;

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
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              _buildTabToggle(),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
                    ],
                  ),
                  child: ListView.separated(
                    itemCount: currentList.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) => MeetingCard(meeting: currentList[index]),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // We pass the navigation logic here
              _buildRequestButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RequestChoiceScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabToggle() {
    return Row(
      children: [
        _tabButton("Upcoming (${upcomingMeetings.length})", true),
        _tabButton("Past (${pastMeetings.length})", false),
      ],
    );
  }

  Widget _tabButton(String title, bool isUpcoming) {
    bool isSelected = isUpcomingSelected == isUpcoming;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isUpcomingSelected = isUpcoming),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : [],
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black87 : Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text(
          'Request a Meeting',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}