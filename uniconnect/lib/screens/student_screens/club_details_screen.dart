import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/club_model.dart'; // Adjust paths as needed
import 'club_management_screen.dart';

class ClubDetailsScreen extends StatelessWidget {
  final ClubModel club;
  const ClubDetailsScreen({super.key, required this.club});

  // --- BACKEND: REQUEST TO JOIN ---
  Future<void> _requestToJoin(BuildContext context, String currentUid) async {
    try {
      await FirebaseFirestore.instance.collection('clubs').doc(club.clubId).update({
        'pendingRequests': FieldValue.arrayUnion([currentUid]),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Join request sent successfully!")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF10B981); //
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    // Use StreamBuilder so data stays "Live" when buttons are clicked
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('clubs').doc(club.clubId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        // Update local club data with live data from Firestore
        final liveClub = ClubModel.fromMap(snapshot.data!.id, snapshot.data!.data() as Map<String, dynamic>);
        final bool isPresident = liveClub.presidentID == currentUid;

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
              title: Text(liveClub.name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              actions: [
                // Manage button only for President
                if (isPresident)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton.icon(
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => ClubManagementScreen(club: liveClub))
                      ),
                      icon: const Icon(Icons.security, size: 18, color: primaryGreen),
                      label: const Text("Manage", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
              bottom: const TabBar(
                labelColor: primaryGreen,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryGreen,
                tabs: [Tab(text: "Info"), Tab(text: "Alerts")],
              ),
            ),
            body: TabBarView(
              children: [
                _buildInfoAndMembersTab(context, liveClub, currentUid, primaryGreen),
                _buildAlertsTab(liveClub, isPresident, primaryGreen),
              ],
            ),
          ),
        );
      },
    );
  }

  // 1. CONSOLIDATED INFO & MEMBERS TAB
  Widget _buildInfoAndMembersTab(BuildContext context, ClubModel liveClub, String currentUid, Color themeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: themeColor.withOpacity(0.1),
            child: Icon(_getCategoryIcon(liveClub.category), size: 50, color: themeColor),
          ),
          const SizedBox(height: 20),
          Text(liveClub.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(liveClub.description, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          
          const SizedBox(height: 40),
          _sectionHeader("President"),
          const SizedBox(height: 12),
          _memberTile(liveClub.president, "Club Leader", isLeader: true),

          const SizedBox(height: 32),
          _sectionHeader("Members"),
          const SizedBox(height: 12),
          
          if (liveClub.members.isEmpty)
            const Text("No members yet.", style: TextStyle(color: Colors.grey))
          else
            ...liveClub.members.map((uid) {
              if (uid.trim().isEmpty) return const SizedBox(); // Crash fix
              return _fetchMemberTile(uid);
            }).toList(),

          // DYNAMIC JOIN BUTTON
          _buildJoinButton(context, liveClub, currentUid, themeColor),
        ],
      ),
    );
  }

  // 2. JOIN BUTTON LOGIC
  Widget _buildJoinButton(BuildContext context, ClubModel liveClub, String currentUid, Color themeColor) {
    final bool isMember = liveClub.members.contains(currentUid);
    final bool hasRequested = liveClub.pendingRequests.contains(currentUid);
    final bool isPresident = liveClub.presidentID == currentUid;

    if (isPresident || isMember) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: hasRequested ? null : () => _requestToJoin(context, currentUid),
          style: ElevatedButton.styleFrom(
            backgroundColor: hasRequested ? Colors.grey : themeColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            hasRequested ? "Request Pending" : "Request to Join Club",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // 3. ALERTS TAB
  Widget _buildAlertsTab(ClubModel liveClub, bool isPresident, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          if (isPresident)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () { /* Logic for announcement */ },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_alert, color: Colors.white),
                label: const Text("Create an Announcement", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          const Expanded(child: Center(child: Text("No Alerts yet.", style: TextStyle(color: Colors.grey)))),
        ],
      ),
    );
  }

  // --- HELPERS ---
  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(width: 40, height: 3, color: const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _memberTile(String name, String sub, {bool isLeader = false}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isLeader ? Colors.amber[100] : Colors.grey[200],
          child: Icon(Icons.person, color: isLeader ? Colors.amber[800] : Colors.grey[600]),
        ),
        title: Text(name, style: TextStyle(fontWeight: isLeader ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text(sub),
        trailing: isLeader ? const Icon(Icons.star, color: Colors.amber) : null,
      ),
    );
  }

  Widget _fetchMemberTile(String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          return _memberTile(snapshot.data!.get('name'), "Member");
        }
        return const SizedBox(); 
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technology': return Icons.computer;
      case 'sports': return Icons.sports_basketball;
      default: return Icons.groups;
    }
  }
}