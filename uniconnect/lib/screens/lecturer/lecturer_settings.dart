import 'package:flutter/material.dart';

class LecturerSettingsScreen extends StatelessWidget {
  const LecturerSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9), // Light background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. PROFILE INFORMATION CARD
            // ==========================================
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // --- Avatar, Name, Department, and Badge ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 36,
                        backgroundColor: Color(0xFFD81B60), // Cherry Red/Pink
                        child: Text(
                          'DU',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Demo User',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Computer Science Department',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Lecturer Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007BFF), // Blue
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Lecturer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 24),

                  // --- Contact Information ---
                  _buildContactRow(Icons.mail_outline, 'demo@university.edu'),
                  _buildContactRow(Icons.phone_outlined, '+1 234 567 8900'),
                  _buildContactRow(
                    Icons.business_outlined,
                    'Building A, Room 201',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ==========================================
            // 2. SETTINGS SECTION
            // ==========================================
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
              child: Text(
                'SETTINGS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.settings_outlined,
                    title: 'Account Settings',
                    onTap: () {
                      // Add navigation or logic here
                    },
                  ),
                  Divider(color: Colors.grey.shade100, height: 1),
                  _buildSettingsTile(
                    icon: Icons.location_on_outlined,
                    title: 'Update Office Location',
                    onTap: () {
                      // Add navigation or logic here
                    },
                  ),
                  Divider(color: Colors.grey.shade100, height: 1),
                  _buildSettingsTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    isDestructive: true,
                    onTap: () {
                      // Add logout logic here
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  // Builds the rows for email, phone, and building location
  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade500),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // Builds the clickable options in the Settings menu
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    // Red color for logout, standard colors for the rest
    final Color itemColor = isDestructive
        ? const Color(0xFFE74C3C)
        : Colors.black87;
    final Color iconColor = isDestructive
        ? const Color(0xFFE74C3C)
        : Colors.grey.shade600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          16,
        ), // Match container bounds for splash
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: itemColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!isDestructive)
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
