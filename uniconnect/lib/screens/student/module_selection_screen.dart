import 'package:flutter/material.dart';
import 'filtered_lecturer_list_screen.dart'; // We'll build this nex

class ModuleSelectionScreen extends StatelessWidget {
  final String facultyCode;
  const ModuleSelectionScreen({super.key, required this.facultyCode});

  @override
  Widget build(BuildContext context) {
    // Mock data - In a real app, you'd fetch this from a DB filtered by facultyCode
    final Map<String, List<String>> modulesByFaculty = {
      'FOC': ['Data Structures', 'Algorithms', 'Mobile App Development', 'Cyber Security'],
      'FOB': ['Business Management', 'Accounting', 'Marketing Strategy', 'Economics'],
      'FOS': ['Organic Chemistry', 'Quantum Physics', 'Microbiology', 'Genetics'],
    };

    final List<String> modules = modulesByFaculty[facultyCode] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text('$facultyCode Modules', 
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text("Select the module you need help with", 
              style: TextStyle(color: Colors.grey, fontSize: 15)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade100),
                    ),
                    title: Text(modules[index], 
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilteredLecturerListScreen(
                            moduleName: modules[index],
                            facultyCode: facultyCode,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}