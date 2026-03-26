import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../auth_screen/welcome_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

  // --- LOGOUT LOGIC (Identical to Lecturer) ---
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role'); // Wipe the role
    await FirebaseAuth.instance.signOut(); // Sign out of Firebase
    
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
    return PopScope(
      canPop: false, // Prevents back-button logout
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F9),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text('Admin Profile', 
            style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('admins').doc(_currentUid).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            final String name = data['name'] ?? "Admin User";
            final String email = data['email'] ?? "admin@uniconnect.com";

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(name, email),
                  const SizedBox(height: 32),
                  _buildSettingsSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard(String name, String email) {
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
                backgroundColor: const Color(0xFF1565C0), // Admin Blue theme
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : "A", 
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text("System Administrator", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
                      child: const Text("RANK: ROOT ADMIN", style: TextStyle(color: Color(0xFF1565C0), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),
          _buildContactRow(Icons.mail_outline, email),
          _buildContactRow(Icons.security, "Full System Access"),
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
      onTap: onTap,
    );
  }
}