import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lecturer_models/lecturer_model.dart';
import '../../screens/auth/welcome_screen.dart';

class LecturerSettingsScreen extends StatefulWidget {
  final LecturerModel currentLecturer;

  const LecturerSettingsScreen({super.key, required this.currentLecturer});

  @override
  State<LecturerSettingsScreen> createState() => _LecturerSettingsScreenState();
}

class _LecturerSettingsScreenState extends State<LecturerSettingsScreen> {
  Future<void> _showUpdateLocationDialog() async {
    final TextEditingController locationController = 
        TextEditingController(text: widget.currentLecturer.location);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Office Location"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: locationController,
          decoration: const InputDecoration(
            hintText: "e.g., Building B, Room 102",
            labelText: "Room Number / Office",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              String newLocation = locationController.text.trim();
              if (newLocation.isNotEmpty) {
                await _updateLocationInFirestore(newLocation);
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0)),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateLocationInFirestore(String newLocation) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('lecturers')
          .where('staffId', isEqualTo: widget.currentLecturer.staffId)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({'location': newLocation});
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Office location updated successfully!")),
          );
          // Refreshing the UI locally
          setState(() {}); 
        }
      }
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
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
        title: const Text('Profile', style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 32),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFD81B60),
                child: Text(widget.currentLecturer.name[0].toUpperCase(), 
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.currentLecturer.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(widget.currentLecturer.faculty, style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                      child: Text("ID: ${widget.currentLecturer.staffId}", style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          _buildContactRow(Icons.mail_outline, widget.currentLecturer.email),
          // We stream this or use StreamBuilder if we want instant local updates without setState
          _buildContactRow(Icons.location_on_outlined, widget.currentLecturer.location),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // REPLACED ACCOUNT SETTINGS WITH UPDATE LOCATION
          _buildSettingsTile(
            icon: Icons.location_on_outlined,
            title: 'Change Office Location',
            onTap: _showUpdateLocationDialog,
          ),
          Divider(color: Colors.grey.shade100, height: 1),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            isDestructive: true,
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap, bool isDestructive = false}) {
    final Color color = isDestructive ? Colors.red : Colors.black87;
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.grey.shade600),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: isDestructive ? null : const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}