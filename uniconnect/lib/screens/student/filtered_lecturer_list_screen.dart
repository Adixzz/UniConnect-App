import 'package:flutter/material.dart';
import '../../models/lecturer_model.dart';

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
    // This list would usually be filtered from your global list or a Provider
    final List<LecturerModel> allLecturers = [
      LecturerModel(
        uid: '1', name: 'Dr. Sarah Johnson', email: 's@u.com', staffId: 'L1', 
        pin: '1', faculty: 'FOC', modules: ['Data Structures', 'Algorithms']
      ),
      LecturerModel(
        uid: '2', name: 'Prof. Michael Chen', email: 'm@u.com', staffId: 'L2', 
        pin: '2', faculty: 'FOC', modules: ['Mobile App Development']
      ),
    ];

    // FILTER LOGIC: Match the selected module
    final List<LecturerModel> filteredList = allLecturers
        .where((l) => l.modules.contains(moduleName))
        .toList();

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
      body: filteredList.isEmpty 
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final lecturer = filteredList[index];
              return _buildLecturerTile(context, lecturer);
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
          child: Text(lecturer.name[0], style: const TextStyle(color: Color(0xFF10B981))),
        ),
        title: Text(lecturer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(lecturer.email),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // NEXT: The final "Meeting Details" Input page
          print("Requesting meeting with ${lecturer.name}");
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("No lecturers found for this module."));
  }
}