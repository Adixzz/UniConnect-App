import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/request_card.dart';
import '../../widgets/ScheduleTile.dart';
import '../../models/lecturer_model.dart'; // Adjust import if needed

class LecturerHomeScreen extends StatefulWidget {
  final LecturerModel currentLecturer;

  const LecturerHomeScreen({super.key, required this.currentLecturer});

  @override
  State<LecturerHomeScreen> createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  int _totalStudents = 0;

  @override
  void initState() {
    super.initState();
    // Fetch the total student count as soon as the screen loads
    _fetchTotalStudents();
  }

  // STEP 1: Fetch total students from the 'users' collection
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
      print("Error fetching students: $e");
    }
  }

  // Helper method to get today's date in the exact format your database uses (e.g., "17/3/2026")
  String _getTodayDateString() {
    DateTime now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    String todayString = _getTodayDateString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        // STEP 2: The StreamBuilder listens to the 'meetings' collection live!
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('meetings')
              .where('lecturerUid', isEqualTo: widget.currentLecturer.uid)
              .snapshots(),
          builder: (context, snapshot) {
            // If the database is loading, show a little spinner
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // If there's an error
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            // STEP 3: Organize the data!
            // We separate the meetings into "Pending" and "Today's Accepted Schedule"
            List<QueryDocumentSnapshot> allMeetings = snapshot.data?.docs ?? [];

            List<QueryDocumentSnapshot> pendingRequests = allMeetings.where((
              doc,
            ) {
              return doc['status'] == 'Pending';
            }).toList();

            List<QueryDocumentSnapshot> todaysSchedule = allMeetings.where((
              doc,
            ) {
              // Assuming you want to show "Accepted" or "Scheduled" meetings for today
              return doc['date'] == todayString && doc['status'] == 'Accepted';
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Good Morning",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.currentLecturer.name,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 25),

                  // STEP 4: Plug the live counts into your Summary Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SummaryCard(
                        title: "Today",
                        count:
                            "${todaysSchedule.length}", // Live count of today's meetings
                        icon: Icons.calendar_today,
                        color: Colors.blue,
                        cardWidth: 120,
                      ),
                      SummaryCard(
                        title: "Pending",
                        count:
                            "${pendingRequests.length}", // Live count of pending requests
                        icon: Icons.error_outline,
                        color: Colors.orange,
                        cardWidth: 120,
                      ),
                      SummaryCard(
                        title: "Students",
                        count:
                            "$_totalStudents", // Count fetched from initState
                        icon: Icons.people_outline,
                        color: Colors.green,
                        cardWidth: 120,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // STEP 5: Display Today's Schedule
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

                  // Loop through today's meetings and build a ScheduleTile for each
                  ...todaysSchedule.map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    // We use a FutureBuilder to look up the student's name using their Uid
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(data['studentUid'])
                          .get(),
                      builder: (context, userSnapshot) {
                        String studentName = "Loading...";
                        if (userSnapshot.hasData && userSnapshot.data!.exists) {
                          studentName = userSnapshot.data!['name'];
                        }

                        return ScheduleTile(
                          name: studentName,
                          time: data['time'] ?? 'No time set',
                          type: data['moduleName'] ?? 'General',
                        );
                      },
                    );
                  }), // Note: The .toList() is implicitly handled by the spread operator (...)

                  const SizedBox(height: 30),

                  // STEP 6: Display Pending Requests
                  const Text(
                    "Pending Requests",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  if (pendingRequests.isEmpty)
                    const Text(
                      "No pending requests.",
                      style: TextStyle(color: Colors.grey),
                    ),

                  // Loop through pending requests and build a RequestActionCard for each
                  ...pendingRequests.map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(data['studentUid'])
                          .get(),
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

                            // --- NEW LOGIC FOR BUTTONS ---
                            onApprove: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('meetings')
                                    .doc(
                                      doc.id,
                                    ) // Target this specific document
                                    .update({'status': 'Accepted'});

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Meeting Approved!'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print("Error approving: $e");
                              }
                            },

                            onDecline: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('meetings')
                                    .doc(
                                      doc.id,
                                    ) // Target this specific document
                                    .update({'status': 'Declined'});

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Meeting Declined.'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print("Error declining: $e");
                              }
                            },

                            // -----------------------------
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
