import 'package:flutter/material.dart';
import 'module_selection_screen.dart';

class FacultySelectionScreen extends StatelessWidget {
  const FacultySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faculties = [
      {'code': 'FOC', 'name': 'Faculty of Computing'},
      {'code': 'FOB', 'name': 'Faculty of Business'},
      {'code': 'FOS', 'name': 'Faculty of Science'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Select Faculty',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: faculties.length,
        itemBuilder: (context, index) {
          final f = faculties[index];

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  f['code']!,
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                f['name']!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ModuleSelectionScreen(facultyCode: f['code']!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}