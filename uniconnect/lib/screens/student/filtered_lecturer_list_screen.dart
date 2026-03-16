import 'package:flutter/material.dart';
import '../../models/lecturer_model.dart';
import '../../services/database_service.dart'; // Adjust path based on your project
import 'meeting_details_screen.dart';

class FilteredLecturerListScreen extends StatelessWidget {
  final String moduleName;
  final String facultyCode;

  const FilteredLecturerListScreen({
    super.key, 
    required this.moduleName, 
    required this.facultyCode
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text('Lecturers for $moduleName', 
          style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Use FutureBuilder to fetch real data from Firestore
      body: FutureBuilder<List<LecturerModel>>(
        future: DatabaseService().getFilteredLecturers(facultyCode, moduleName),
        builder: (context, snapshot) {
          // 1. Show loading spinner while waiting for Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            );
          }

          // 2. Handle errors
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. Handle empty results
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final List<LecturerModel> filteredList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final lecturer = filteredList[index];
              return _buildLecturerTile(context, lecturer);
            },
          );
        },
      ),
    );
  }

  Widget _buildLecturerTile(BuildContext context, LecturerModel lecturer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
          child: Text(
            lecturer.name[0].toUpperCase(), 
            style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)
          ),
        ),
        title: Text(lecturer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(lecturer.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingDetailsScreen(lecturer: lecturer),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No lecturers found for this module.",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}