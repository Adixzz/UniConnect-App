import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/club_model.dart';

class ClubManagementScreen extends StatefulWidget {
  final ClubModel club;
  const ClubManagementScreen({super.key, required this.club});

  @override
  State<ClubManagementScreen> createState() => _ClubManagementScreenState();
}

class _ClubManagementScreenState extends State<ClubManagementScreen> {
  final Color primaryGreen = const Color(0xFF10B981);

  // --- BACKEND ACTIONS ---
  Future<void> _approveMember(String studentUid) async {
    try {
      await FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).update({
        'pendingRequests': FieldValue.arrayRemove([studentUid]),
        'members': FieldValue.arrayUnion([studentUid]),
        'requestReasons.$studentUid': FieldValue.delete(), // Clean up reason from DB
      });
      _showSnackBar("Member Approved!");
    } catch (e) {
      _showSnackBar("Error: $e");
    }
  }

  Future<void> _rejectRequest(String studentUid) async {
    await FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).update({
      'pendingRequests': FieldValue.arrayRemove([studentUid]),
      'requestReasons.$studentUid': FieldValue.delete(), // Clean up reason from DB
    });
    _showSnackBar("Request Rejected.");
  }

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

        if (requests.isEmpty) return _buildEmptyState("No pending join requests.");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) => _fetchUserCard(
            requests[index], 
            isRequest: true, 
            liveClub: ClubModel.fromMap(snapshot.data!.id, snapshot.data!.data() as Map<String, dynamic>)
          ),
        );
      },
    );
  }

  // 2. MEMBERS TAB
  Widget _buildMembersManagementTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('clubs').doc(widget.club.clubId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        List<String> members = List<String>.from(snapshot.data!.get('members') ?? []);
        members.remove(widget.club.presidentID); // Protect president from deletion

        if (members.isEmpty) return _buildEmptyState("No other members to manage.");

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) => _fetchUserCard(
            members[index], 
            isRequest: false,
            liveClub: ClubModel.fromMap(snapshot.data!.id, snapshot.data!.data() as Map<String, dynamic>)
          ),
        );
      },
    );
  }

  // USER LOOKUP CARD
  Widget _fetchUserCard(String uid, {required bool isRequest, required ClubModel liveClub}) {
    if (uid.trim().isEmpty) return const SizedBox(); // Prevent crash on empty strings

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const ListTile(title: Text("Loading..."));

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildGhostUserCard(uid); // Cleanup card for deleted users
        }

        String name = snapshot.data!.get('name') ?? "Unknown";
        String reason = liveClub.requestReasons[uid] ?? "No reason provided.";

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: isRequest 
            ? ExpansionTile( // ExpansionTile allows the President to click to read the reason cleanly
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Wants to join the club", style: TextStyle(color: Colors.grey)),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Reason: $reason", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87)),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _rejectRequest(uid), 
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        label: const Text("Reject", style: TextStyle(color: Colors.redAccent))
                      ),
                      TextButton.icon(
                        onPressed: () => _approveMember(uid), 
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        label: const Text("Approve", style: TextStyle(color: Colors.green))
                      ),
                    ],
                  )
                ],
              )
            : ListTile( // Standard view for already accepted members
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Current Member"),
                trailing: IconButton(
                  icon: const Icon(Icons.person_remove, color: Colors.redAccent),
                  onPressed: () => _removeMember(uid),
                ),
              ),
        );
      },
    );
  }

  Widget _buildGhostUserCard(String uid) {
    return Card(
      elevation: 0,
      color: Colors.orange[50],
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.orange),
        title: const Text("Invalid User"),
        subtitle: const Text("Account deleted or invalid UID."),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _rejectRequest(uid),
        ),
      ),
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