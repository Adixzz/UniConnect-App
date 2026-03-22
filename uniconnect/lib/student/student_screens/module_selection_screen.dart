import 'package:flutter/material.dart';
import '../../services/student_database_service.dart';
import 'filtered_lecturer_list_screen.dart';
import '../../student/student_models/faculty_module_model.dart';


class ModuleSelectionScreen extends StatelessWidget {
  final String facultyCode;
  const ModuleSelectionScreen({super.key, required this.facultyCode});

  @override
  Widget build(BuildContext context) {
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
            child: FutureBuilder<List<ModuleModel>>(
              future: DatabaseService().getModulesByFaculty(facultyCode),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No modules found for this faculty."));
                }

                final modules = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade100),
                        ),
                        title: Text(module.name, // From ModuleModel
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: const Icon(Icons.chevron_right, size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FilteredLecturerListScreen(
                                moduleName: module.name,
                                facultyCode: facultyCode,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}