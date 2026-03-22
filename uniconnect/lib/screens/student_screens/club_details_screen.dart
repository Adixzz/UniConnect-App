import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/club_model.dart';
import 'club_management_screen.dart';
import 'create_announcement_screen.dart';
import 'package:intl/intl.dart';

class ClubDetailsScreen extends StatelessWidget {
  final ClubModel club;
  const ClubDetailsScreen({super.key, required this.club});

  // --- SHOW DIALOG TO GET REASON ---
  Future<void> _showJoinDialog(BuildContext context, String currentUid) async {
    final TextEditingController reasonController = TextEditingController();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Join Request", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Why would you like to join this club?",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                _requestToJoin(context, currentUid, reasonController.text);
                Navigator.pop(context); // Close dialog
              }
            },
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- BACKEND: REQUEST TO JOIN ---
  Future<void> _requestToJoin(BuildContext context, String currentUid, String reason) async {
    try {
      await FirebaseFirestore.instance.collection('clubs').doc(club.clubId).update({
        'pendingRequests': FieldValue.arrayUnion([currentUid]),
        'requestReasons.$currentUid': reason, // Maps the reason to the user's UID
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Join request sent successfully!")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // --- BACKEND: LEAVE CLUB ---
  Future<void> _leaveClub(BuildContext context, String currentUid) async {
    try {
      await FirebaseFirestore.instance.collection('clubs').doc(club.clubId).update({
        'members': FieldValue.arrayRemove([currentUid]),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You have left the club.")));
      }
    } catch (e) {
       if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error leaving club: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF10B981);
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('clubs').doc(club.clubId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final liveClub = ClubModel.fromMap(snapshot.data!.id, snapshot.data!.data() as Map<String, dynamic>);
        
        final bool isMember = liveClub.members.contains(currentUid);
        final bool isPresident = liveClub.presidentID == currentUid;
        final bool canSeeAlerts = isMember || isPresident; // ACCESS CONTROL

        return DefaultTabController(
          length: canSeeAlerts ? 2 : 1, // Dynamically hide the Alerts tab
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
                if (isPresident)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ClubManagementScreen(club: liveClub))),
                      icon: const Icon(Icons.security, size: 18, color: primaryGreen),
                      label: const Text("Manage", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
              bottom: TabBar(
                labelColor: primaryGreen,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryGreen,
                tabs: [
                  const Tab(text: "Info"),
                  if (canSeeAlerts) const Tab(text: "Alerts"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildInfoAndMembersTab(context, liveClub, currentUid, primaryGreen),
                if (canSeeAlerts) _buildAlertsTab(context, liveClub, isPresident, primaryGreen),
              ],
            ),
          ),
        );
      },
    );
  }

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

          // ACTION BUTTONS
          _buildActionButtons(context, liveClub, currentUid, themeColor),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ClubModel liveClub, String currentUid, Color themeColor) {
    final bool isMember = liveClub.members.contains(currentUid);
    final bool hasRequested = liveClub.pendingRequests.contains(currentUid);
    final bool isPresident = liveClub.presidentID == currentUid;

    if (isPresident) return const SizedBox(); // Presidents manage the club from the top right button

    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: isMember 
          ? OutlinedButton.icon(
              onPressed: () => _leaveClub(context, currentUid),
              icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
              label: const Text("Leave Club", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          : ElevatedButton(
              onPressed: hasRequested ? null : () => _showJoinDialog(context, currentUid),
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

Widget _buildAlertsTab(BuildContext context, ClubModel liveClub, bool isPresident, Color themeColor) {
  return Column(
    children: [
      if (isPresident)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => CreateAnnouncementScreen(clubId: liveClub.clubId))
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_alert, color: Colors.white),
              label: const Text("Create an Announcement", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          // Fetching from the new subcollection
          stream: FirebaseFirestore.instance
              .collection('clubs')
              .doc(liveClub.clubId)
              .collection('announcements')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No Alerts yet.", style: TextStyle(color: Colors.grey)));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                final bool isEvent = data['type'] == 'Event';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                  color: isEvent ? Colors.blue[50] : Colors.grey[100],
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: isEvent ? Colors.blue : themeColor,
                      child: Icon(isEvent ? Icons.event : Icons.campaign, color: Colors.white),
                    ),
                    title: Text(isEvent ? "Upcoming Event" : "Notice", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(data['message'] ?? ''),
                        if (isEvent) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text("${data['eventTime']} on ${DateFormat('MMM d').format((data['eventDate'] as Timestamp).toDate())}", 
                                   style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ],
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