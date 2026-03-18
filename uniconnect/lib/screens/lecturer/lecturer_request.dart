import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/lecturer_request.dart';
import '../../models/meeting_request.dart';
// IMPORTANT: Make sure this import points to your LecturerModel
import '../../models/lecturer_model.dart';

class RequestsScreen extends StatefulWidget {
  // 1. We require the current lecturer to fetch only their specific meetings
  final LecturerModel currentLecturer;

  const RequestsScreen({Key? key, required this.currentLecturer})
    : super(key: key);

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  int _selectedTabIndex = 0;

  // Helper method to generate initials for the avatar (e.g., "Lisa Anderson" -> "LA")
  String _getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    List<String> parts = name.trim().split(' ');
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  // --- 2. Action Function to Update Firestore ---
  Future<void> _updateRequestStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('meetings').doc(docId).update(
        {'status': newStatus},
      );

      if (mounted) {
        // Show a quick success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Meeting $newStatus!')));
      }
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Requests',
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Add a back button so they can return to the Home Screen
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),

      // --- 3. The Live StreamBuilder ---
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('meetings')
            .where('lecturerUid', isEqualTo: widget.currentLecturer.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong loading requests."),
            );
          }

          // 4. Categorize the live data into our 3 tabs
          List<QueryDocumentSnapshot> allDocs = snapshot.data?.docs ?? [];

          List<QueryDocumentSnapshot> pendingDocs = allDocs
              .where((d) => d['status'] == 'Pending')
              .toList();
          List<QueryDocumentSnapshot> approvedDocs = allDocs
              .where((d) => d['status'] == 'Accepted')
              .toList(); // Note: DB uses 'Accepted'
          List<QueryDocumentSnapshot> declinedDocs = allDocs
              .where((d) => d['status'] == 'Declined')
              .toList();

          // 5. Determine which list to show based on the selected tab
          List<QueryDocumentSnapshot> currentDocs = _selectedTabIndex == 0
              ? pendingDocs
              : (_selectedTabIndex == 1 ? approvedDocs : declinedDocs);

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Custom Tab Bar (Now with LIVE dynamic numbers!)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      _buildTab('Pending (${pendingDocs.length})', 0),
                      _buildTab('Approved (${approvedDocs.length})', 1),
                      _buildTab('Declined (${declinedDocs.length})', 2),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // List of Cards
                Expanded(
                  child: currentDocs.isEmpty
                      ? Center(
                          child: Text(
                            "No requests in this tab.",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: currentDocs.length,
                          itemBuilder: (context, index) {
                            final doc = currentDocs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            // 6. Look up the student's actual name and ID from the users collection
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(data['studentUid'])
                                  .get(),
                              builder: (context, userSnapshot) {
                                String studentName = "Loading...";
                                String studentId = "...";

                                if (userSnapshot.hasData &&
                                    userSnapshot.data!.exists) {
                                  studentName =
                                      userSnapshot.data!['name'] ??
                                      "Unknown Student";
                                  studentId =
                                      userSnapshot.data!['studentId'] ??
                                      "No ID";
                                }

                                // 7. Map the Firestore data to your existing RequestItem model
                                RequestStatus currentStatus =
                                    RequestStatus.pending;
                                if (data['status'] == 'Accepted')
                                  currentStatus = RequestStatus.approved;
                                if (data['status'] == 'Declined')
                                  currentStatus = RequestStatus.declined;

                                final requestItem = RequestItem(
                                  name: studentName,
                                  initials: _getInitials(studentName),
                                  id: studentId,
                                  date: data['date'] ?? 'No Date',
                                  time: data['time'] ?? 'No Time set',
                                  description:
                                      data['reason'] ?? 'No reason provided',
                                  requestedAgo:
                                      'Recently', // Can be updated if you store timestamps in DB
                                  status: currentStatus,
                                );

                                // 8. Return your custom card, connected to Firestore!
                                return RequestCard(
                                  request: requestItem,
                                  // Connect the buttons to update Firestore
                                  onApprove: () =>
                                      _updateRequestStatus(doc.id, 'Accepted'),
                                  onDecline: () =>
                                      _updateRequestStatus(doc.id, 'Declined'),
                                  // Connect the tap event to show your Dialog
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return RequestDetailsDialog(
                                          request: requestItem,
                                          onApprove: () {
                                            _updateRequestStatus(
                                              doc.id,
                                              'Accepted',
                                            );
                                            Navigator.pop(
                                              dialogContext,
                                            ); // Close dialog
                                          },
                                          onDecline: () {
                                            _updateRequestStatus(
                                              doc.id,
                                              'Declined',
                                            );
                                            Navigator.pop(
                                              dialogContext,
                                            ); // Close dialog
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isActive
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                )
              : null,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.black87 : Colors.grey.shade500,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
