import 'package:flutter/material.dart';
import 'faculty_selection_screen.dart'; 
import 'global_lecturer_search.dart';  

class RequestChoiceScreen extends StatelessWidget {
  const RequestChoiceScreen({super.key});

  final Color primaryGreen = const Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('New Request', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChoiceCard(
              context,
              title: "Academic Path",
              subtitle: "Filter by Faculty and Modules to find your lecturer.",
              icon: Icons.account_balance_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FacultySelectionScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildChoiceCard(
              context,
              title: "Direct Search",
              subtitle: "Quickly find any lecturer across campus by their name.",
              icon: Icons.person_search_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GlobalLecturerSearch()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCard(BuildContext context, 
      {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: primaryGreen.withOpacity(0.1),
              child: Icon(icon, color: primaryGreen, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.3)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }}