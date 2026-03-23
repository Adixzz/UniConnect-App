import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/lecturer_widgets/lecturer_request.dart';
import '../../models/meeting_request.dart';
import '../../models/lecturer_model.dart';
import '../../services/lecturer_database_service.dart'; //

class RequestsScreen extends StatefulWidget {
  final LecturerModel currentLecturer;

  const RequestsScreen({Key? key, required this.currentLecturer})
    : super(key: key);

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final LecturerDatabaseService _dbService = LecturerDatabaseService(); //
  int _selectedTabIndex = 0;
  String _selectedDateFilter = "All"; 

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    List<String> parts = name.trim().split(' ');
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  // --- UPDATED LOGIC: Update Status + Notify Student ---
  Future<void> _updateRequestStatus(String docId, String newStatus, String studentUid, String date) async {
    try {
      // 1. Update the meeting status
      await _dbService.updateMeetingStatus(docId, newStatus);

      // 2. Send the notification to the student's subcollection
      await _dbService.notifyStudent(
        studentUid: studentUid,
        status: newStatus,
        date: date,
        lecturerName: widget.currentLecturer.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Meeting $newStatus!')));
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: const Text('Requests', style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('meetings')
            .where('lecturerUid', isEqualTo: widget.currentLecturer.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text("Error loading requests."));

          List<QueryDocumentSnapshot> allDocs = snapshot.data?.docs ?? [];
          
          // Date filtering logic
          Set<String> dateSet = {"All"};
          for (var doc in allDocs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['date'] != null) dateSet.add(data['date']);
          }
          List<String> availableDates = dateSet.toList()..sort();

          List<QueryDocumentSnapshot> dateFilteredDocs = _selectedDateFilter == "All"
              ? allDocs
              : allDocs.where((d) => d['date'] == _selectedDateFilter).toList();

          List<QueryDocumentSnapshot> pendingDocs = dateFilteredDocs.where((d) => d['status'] == 'Pending').toList();
          List<QueryDocumentSnapshot> approvedDocs = dateFilteredDocs.where((d) => d['status'] == 'Accepted').toList(); 
          List<QueryDocumentSnapshot> declinedDocs = dateFilteredDocs.where((d) => d['status'] == 'Declined').toList();

          List<QueryDocumentSnapshot> currentDocs = _selectedTabIndex == 0
              ? pendingDocs
              : (_selectedTabIndex == 1 ? approvedDocs : declinedDocs);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      _buildTab('Pending (${pendingDocs.length})', 0),
                      _buildTab('Approved (${approvedDocs.length})', 1),
                      _buildTab('Declined (${declinedDocs.length})', 2),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildDateDropdown(availableDates),
                const SizedBox(height: 16),
                Expanded(
                  child: currentDocs.isEmpty
                      ? const Center(child: Text("No results for this date."))
                      : ListView.builder(
                          itemCount: currentDocs.length,
                          itemBuilder: (context, index) {
                            final doc = currentDocs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final String sUid = data['studentUid'] ?? "";
                            final String mDate = data['date'] ?? "No Date";

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('users').doc(sUid).get(),
                              builder: (context, userSnapshot) {
                                String sName = userSnapshot.hasData && userSnapshot.data!.exists ? userSnapshot.data!['name'] : "Loading...";
                                String sId = userSnapshot.hasData && userSnapshot.data!.exists ? userSnapshot.data!['studentId'] : "...";

                                RequestStatus currentStatus = data['status'] == 'Accepted' ? RequestStatus.approved : (data['status'] == 'Declined' ? RequestStatus.declined : RequestStatus.pending);

                                final requestItem = RequestItem(
                                  name: sName,
                                  initials: _getInitials(sName),
                                  id: sId,
                                  date: mDate,
                                  time: data['time'] ?? 'No Time',
                                  description: data['reason'] ?? 'No reason',
                                  requestedAgo: 'Recently',
                                  status: currentStatus,
                                );

                                return RequestCard(
                                  request: requestItem,
                                  onApprove: () => _updateRequestStatus(doc.id, 'Accepted', sUid, mDate),
                                  onDecline: () => _updateRequestStatus(doc.id, 'Declined', sUid, mDate),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return RequestDetailsDialog(
                                          request: requestItem,
                                          onApprove: () {
                                            _updateRequestStatus(doc.id, 'Accepted', sUid, mDate);
                                            Navigator.pop(dialogContext);
                                          },
                                          onDecline: () {
                                            _updateRequestStatus(doc.id, 'Declined', sUid, mDate);
                                            Navigator.pop(dialogContext);
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

  Widget _buildDateDropdown(List<String> availableDates) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedDateFilter,
            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF10B981)),
            onChanged: (String? val) => setState(() => _selectedDateFilter = val!),
            items: availableDates.map<DropdownMenuItem<String>>((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val == "All" ? "All Dates" : val));
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isActive ? BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]) : null,
          child: Center(child: Text(title, style: TextStyle(color: isActive ? Colors.black87 : Colors.grey.shade500, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal))),
        ),
      ),
    );
  }
}