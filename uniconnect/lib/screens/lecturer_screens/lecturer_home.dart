import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/lecturer_widgets/summary_card.dart';
import '../../widgets/lecturer_widgets/request_card.dart';
import '../../widgets/lecturer_widgets/schedule_tile.dart';
import '../../models/lecturer_model.dart'; 
import '../../services/lecturer_database_service.dart';
import 'lecturer_request.dart';

class LecturerHomeScreen extends StatefulWidget {
  final LecturerModel currentLecturer;

  const LecturerHomeScreen({super.key, required this.currentLecturer});

  @override
  State<LecturerHomeScreen> createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  final LecturerDatabaseService _dbService = LecturerDatabaseService();
  int _totalStudents = 0;

  @override
  void initState() {
    super.initState();
    _fetchTotalStudents();
  }

  // --- DYNAMIC GREETING HELPER ---
  String _getDynamicGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _fetchTotalStudents() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      if (mounted) {
        setState(() {
          _totalStudents = snapshot.docs.length;
        });
      }
    } catch (e) {
      debugPrint("Error fetching students: $e");
    }
  }

  String _getTodayDateString() {
    DateTime now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  int _timeToMinutes(String timeStr) {
    try {
      timeStr = timeStr.trim().toUpperCase();
      if (timeStr.isEmpty) return 9999; 
      bool isPM = timeStr.contains('PM');
      String timePart = timeStr.replaceAll(RegExp(r'[^0-9:]'), '');
      List<String> parts = timePart.split(':');

      if (parts.length != 2) return 9999;

      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      if (isPM && hours != 12) hours += 12; 
      if (!isPM && hours == 12) hours = 0; 

      return hours * 60 + minutes; 
    } catch (e) {
      return 9999; 
    }
  }

  @override
  Widget build(BuildContext context) {
    String todayString = _getTodayDateString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('meetings')
              .where('lecturerUid', isEqualTo: widget.currentLecturer.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            List<QueryDocumentSnapshot> allMeetings = snapshot.data?.docs ?? [];

            List<QueryDocumentSnapshot> pendingRequests = allMeetings.where((doc) {
              return doc['status'] == 'Pending';
            }).toList();

            List<QueryDocumentSnapshot> todaysSchedule = allMeetings.where((doc) {
              return doc['date'] == todayString && doc['status'] == 'Accepted';
            }).toList();

            todaysSchedule.sort((a, b) {
              Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
              Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;
              return _timeToMinutes(dataA['time'] ?? '').compareTo(_timeToMinutes(dataB['time'] ?? '')); 
            });

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDynamicGreeting(),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.currentLecturer.name,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SummaryCard(
                        title: "Today",
                        count: "${todaysSchedule.length}", 
                        icon: Icons.calendar_today,
                        color: Colors.blue,
                        cardWidth: 120,
                      ),
                      SummaryCard(
                        title: "Pending",
                        count: "${pendingRequests.length}", 
                        icon: Icons.error_outline,
                        color: Colors.orange,
                        cardWidth: 120,
                      ),
                      SummaryCard(
                        title: "Students",
                        count: "$_totalStudents", 
                        icon: Icons.people_outline,
                        color: Colors.green,
                        cardWidth: 120,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    "Today's Schedule",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  if (todaysSchedule.isEmpty)
                    const Text(
                      "No meetings scheduled for today.",
                      style: TextStyle(color: Colors.grey),
                    ),

                  ...todaysSchedule.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(data['studentUid']).get(),
                      builder: (context, userSnapshot) {
                        String studentName = "Loading...";
                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          studentName = userSnapshot.data!['name'];
                        }
                        return ScheduleTile(
                          name: studentName,
                          time: data['time'] ?? 'No time set',
                          type: data['moduleName'] ?? 'General',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RequestsScreen(currentLecturer: widget.currentLecturer)));
                          },
                        );
                      },
                    );
                  }), 

                  const SizedBox(height: 30),

                  const Text(
                    "Pending Requests",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  if (pendingRequests.isEmpty)
                    const Text("No pending requests.", style: TextStyle(color: Colors.grey)),

                  ...pendingRequests.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    final String sUid = data['studentUid'] ?? "";
                    final String mDate = data['date'] ?? "No Date";

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(sUid).get(),
                      builder: (context, userSnapshot) {
                        String studentName = "Loading...";
                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          studentName = userSnapshot.data!['name'];
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: RequestActionCard(
                            name: studentName,
                            reason: data['reason'] ?? 'No reason provided',
                            time: "$mDate at ${data['time'] ?? 'No Time'}",
                            onApprove: () async {
                              await _dbService.updateMeetingStatus(doc.id, 'Accepted');
                              await _dbService.notifyStudent(
                                studentUid: sUid,
                                status: 'Accepted',
                                date: mDate,
                                lecturerName: widget.currentLecturer.name,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meeting Approved!')));
                              }
                            },
                            onDecline: () async {
                              await _dbService.updateMeetingStatus(doc.id, 'Declined');
                              await _dbService.notifyStudent(
                                studentUid: sUid,
                                status: 'Declined',
                                date: mDate,
                                lecturerName: widget.currentLecturer.name,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meeting Declined.')));
                              }
                            },
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}