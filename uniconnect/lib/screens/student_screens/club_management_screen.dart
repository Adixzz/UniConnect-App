import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/club_model.dart';
import '../../services/student_database_service.dart';

class ClubManagementScreen extends StatefulWidget {
  final ClubModel club;
  const ClubManagementScreen({super.key, required this.club});

  @override
  State<ClubManagementScreen> createState() => _ClubManagementScreenState();
}

class _ClubManagementScreenState extends State<ClubManagementScreen> {
  final Color primaryGreen = const Color(0xFF10B981); // Consistent Green Theme


  // Move student from pendingRequests to members
  Future<void> _approveMember(String studentUid) async {
    try {
      await FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).update({
        'pendingRequests': FieldValue.arrayRemove([studentUid]),
        'members': FieldValue.arrayUnion([studentUid]),
      });
      _showSnackBar("Member Approved!");
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  // Remove student from pendingRequests
  Future<void> _rejectRequest(String studentUid) async {
    await FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).update({
      'pendingRequests': FieldValue.arrayRemove([studentUid]),
    });
    _showSnackBar("Request Rejected.");
  }

  // Remove current member
  Future<void> _removeMember(String studentUid) async {
    await FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).update({
      'members': FieldValue.arrayRemove([studentUid]),
    });
    _showSnackBar("Member Removed.");
  }

  void _showSnackBar(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("Management", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            labelColor: primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryGreen,
            tabs: const [
              Tab(text: "Requests", icon: Icon(Icons.pending_actions)),
              Tab(text: "Members", icon: Icon(Icons.manage_accounts)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestsTab(),
            _buildMembersManagementTab(),
          ],
        ),
      ),
    );
  }

  // 1. REQUESTS TAB
  Widget _buildRequestsTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        List<String> requests = List<String>.from(snapshot.data!.get('pendingRequests') ?? []);

        if (requests.isEmpty) {
          return _buildEmptyState("No pending join requests.");
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) => _fetchUserCard(requests[index], isRequest: true),
        );
      },
    );
  }

  // 2. MEMBERS MANAGEMENT TAB
  Widget _buildMembersManagementTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        List<String> members = List<String>.from(snapshot.data!.get('members') ?? []);
        // Don't show the president in the "remove" list
        members.remove(widget.club.presidentID);

        if (members.isEmpty) {
          return _buildEmptyState("No other members to manage.");
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) => _fetchUserCard(members[index], isRequest: false),
        );
      },
    );
  }

 Widget _fetchUserCard(String uid, {required bool isRequest}) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
    builder: (context, snapshot) {
      // 1. Show a loading state while fetching the user
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const ListTile(title: Text("Loading user data..."));
      }

      // 2. CRITICAL FIX: Verify the document actually exists
      if (!snapshot.hasData || !snapshot.data!.exists) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.orange[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            title: Text("Invalid User ID: $uid", style: const TextStyle(fontSize: 14)),
            subtitle: const Text("This ID does not exist in the users collection."),
            trailing: IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () => _rejectRequest(uid), // Allows admin to clean up bad IDs
            ),
          ),
        );
      }

      // 3. If it exists, proceed with your original design
      String name = snapshot.data!.get('name') ?? "Unknown";

      return Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.grey[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: isRequest 
            ? const Text("Wants to join the club")
            : const Text("Current Member"),
          trailing: isRequest 
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _approveMember(uid),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.redAccent),
                    onPressed: () => _rejectRequest(uid),
                  ),
                ],
              )
            : IconButton(
                icon: const Icon(Icons.person_remove, color: Colors.redAccent),
                onPressed: () => _removeMember(uid),
              ),
        ),
      );
    },
  );
}

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}