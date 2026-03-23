import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationHistoryScreen extends StatelessWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
    const Color primaryGreen = Color(0xFF10B981); // Consistent theme

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Option to clear history
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.grey),
            onPressed: () => _clearAllNotifications(currentUid),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Assuming you save notifications to users/{uid}/notifications
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _notificationCard(data);
            },
          );
        },
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _notificationCard(Map<String, dynamic> data) {
    final DateTime time = (data['timestamp'] as Timestamp).toDate();
    final String type = data['type'] ?? 'general'; // e.g., 'meeting', 'club', 'alert'

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getIconColor(type).withOpacity(0.1),
          child: Icon(_getIcon(type), color: _getIconColor(type), size: 20),
        ),
        title: Text(
          data['title'] ?? 'Notification',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              data['body'] ?? '',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM d, h:mm a').format(time),
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          const Text(
            "All caught up!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black54),
          ),
          const Text(
            "You don't have any notifications yet.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  IconData _getIcon(String type) {
    switch (type) {
      case 'meeting': return Icons.calendar_today_rounded;
      case 'club': return Icons.groups_rounded;
      case 'alert': return Icons.warning_amber_rounded;
      default: return Icons.notifications_active_outlined;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'meeting': return Colors.blue;
      case 'club': return const Color(0xFF10B981);
      case 'alert': return Colors.orange;
      default: return Colors.purple;
    }
  }

  Future<void> _clearAllNotifications(String uid) async {
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications');
    final snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}