import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/lecturer_model.dart'; 

class LecturerNotificationsScreen extends StatelessWidget {
  final LecturerModel currentLecturer;

  const LecturerNotificationsScreen({super.key, required this.currentLecturer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9), // Matches lecturer theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // This completely removes the back button
        automaticallyImplyLeading: false, 
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black, 
            fontSize: 32, 
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          // Clear History Button
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.grey),
            tooltip: 'Clear All',
            onPressed: () => _clearAllNotifications(context, currentLecturer.uid),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Lecturers also use the 'users' collection for their notification history
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentLecturer.uid)
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    final DateTime time = data['timestamp'] != null 
        ? (data['timestamp'] as Timestamp).toDate() 
        : DateTime.now();
        
    final String type = data['type'] ?? 'general'; 

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
          child: Icon(_getIcon(type), color: _getIconColor(type), size: 24),
        ),
        title: Text(
          data['title'] ?? 'New Notification',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              data['body'] ?? '',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.3),
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('MMM d, h:mm a').format(time),
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w500),
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
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "No Notifications",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            "When students request meetings,\nthey will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  IconData _getIcon(String type) {
    switch (type) {
      case 'meeting': return Icons.event_available_rounded;
      case 'alert': return Icons.warning_amber_rounded;
      default: return Icons.notifications_active_outlined;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'meeting': return const Color(0xFF1565C0); // Matches Lecturer Blue theme
      case 'alert': return Colors.orange;
      default: return Colors.blueGrey;
    }
  }

  Future<void> _clearAllNotifications(BuildContext context, String uid) async {
    // Show a confirmation dialog before deleting
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Notifications?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Clear All", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
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
}