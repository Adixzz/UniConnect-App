import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/club_model.dart'; //
import 'club_details_screen.dart'; //

class ClubListScreen extends StatefulWidget {
  const ClubListScreen({super.key});

  @override
  State<ClubListScreen> createState() => _ClubListScreenState();
}

class _ClubListScreenState extends State<ClubListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
  final Color primaryGreen = const Color(0xFF10B981); //

  @override
  void initState() {
    super.initState();
    // Initialize controller for the 3 tabs: Your Clubs, Joined, Explore
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        automaticallyImplyLeading: false, //
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "University Clubs",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryGreen,
          tabs: const [
            Tab(text: "Your Clubs", icon: Icon(Icons.stars)),
            Tab(text: "Joined", icon: Icon(Icons.group)),
            Tab(text: "Explore", icon: Icon(Icons.explore)),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clubs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState("No clubs available yet.");
          }

          // Map Firestore data to our ClubModel
          List<ClubModel> allClubs = snapshot.data!.docs.map((doc) {
            return ClubModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();

          // 1. Filter: Clubs you lead (President)
          List<ClubModel> ledClubs = allClubs
              .where((club) => club.presidentID == currentUid)
              .toList();

          // 2. Filter: Clubs you have joined
          List<ClubModel> joinedClubs = allClubs
              .where((club) => club.members.contains(currentUid) && club.presidentID != currentUid)
              .toList();

          // 3. Filter: Clubs you haven't joined yet (Explore)
          List<ClubModel> exploreClubs = allClubs
              .where((club) => !club.members.contains(currentUid) && club.presidentID != currentUid)
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildClubList(ledClubs, "You don't lead any clubs yet.", isPresident: true),
              _buildClubList(joinedClubs, "You haven't joined any clubs."),
              _buildClubList(exploreClubs, "No new clubs to explore."),
            ],
          );
        },
      ),
    );
  }

  // Helper to build the list for each tab
  Widget _buildClubList(List<ClubModel> clubs, String emptyMsg, {bool isPresident = false}) {
    if (clubs.isEmpty) return _buildEmptyState(emptyMsg);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: clubs.length,
      itemBuilder: (context, index) => _clubCard(clubs[index], isPresident),
    );
  }

  // Club Card UI
  Widget _clubCard(ClubModel club, bool isPresident) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: primaryGreen.withOpacity(0.1),
          child: Icon(_getCategoryIcon(club.category), color: primaryGreen),
        ),
        title: Text(
          club.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              club.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _tag(club.category, Colors.blue),
                const SizedBox(width: 8),
                _tag("${club.members.length} Members", primaryGreen),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClubDetailsScreen(club: club), //
            ),
          );
        },
      ),
    );
  }

  // Helper for Category and Member tags
  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper for dynamic icons based on category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'sports': return Icons.sports_basketball;
      case 'academic': return Icons.menu_book;
      case 'cultural': return Icons.music_note;
      case 'technology': return Icons.computer;
      default: return Icons.groups;
    }
  }

  // Empty state UI
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}