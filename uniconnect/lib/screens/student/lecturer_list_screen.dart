import 'package:flutter/material.dart';
import '/widgets/lecturer_card.dart';

class LecturerListPage extends StatefulWidget {
  const LecturerListPage({super.key});

  @override
  State<LecturerListPage> createState() => _LecturerListPageState();
}

class _LecturerListPageState extends State<LecturerListPage> {
  int selectedFacultyIndex = 0;

  final List<String> faculties = ['FOC', 'FOB', 'FOE'];

  final Map<String, List<Map<String, String>>> lecturersByFaculty = {
    'FOC': [
      {
        'name': 'Dr. Nimal Perera',
        'department': 'Computer Science',
        'email': 'nimal@university.edu',
      },
      {
        'name': 'Ms. Sanduni Silva',
        'department': 'Software Engineering',
        'email': 'sanduni@university.edu',
      },
      {
        'name': 'Mr. Kavindu Fernando',
        'department': 'Information Systems',
        'email': 'kavindu@university.edu',
      },
    ],
    'FOB': [
      {
        'name': 'Dr. Amanda Jayasuriya',
        'department': 'Business Management',
        'email': 'amanda@university.edu',
      },
      {
        'name': 'Mr. Charith De Silva',
        'department': 'Accounting & Finance',
        'email': 'charith@university.edu',
      },
    ],
    'FOE': [
      {
        'name': 'Prof. Dhanushka Weerasinghe',
        'department': 'Electrical Engineering',
        'email': 'dhanushka@university.edu',
      },
      {
        'name': 'Ms. Rashmi Peris',
        'department': 'Civil Engineering',
        'email': 'rashmi@university.edu',
      },
      {
        'name': 'Mr. Tharindu Senanayake',
        'department': 'Mechanical Engineering',
        'email': 'tharindu@university.edu',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final selectedFaculty = faculties[selectedFacultyIndex];
    final lecturers = lecturersByFaculty[selectedFaculty] ?? [];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Select a Lecturer',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D47A1),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // Faculty slider/nav bar
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFD9E7F5),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: List.generate(faculties.length, (index) {
                  final isSelected = selectedFacultyIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFacultyIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF1565C0),
                                    Color(0xFF26A69A),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            faculties[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: lecturers.isEmpty
                  ? const Center(
                      child: Text(
                        'No lecturers available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: lecturers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final lecturer = lecturers[index];

                        return LecturerCard(
                          name: lecturer['name'] ?? '',
                          department: lecturer['department'] ?? '',
                          email: lecturer['email'] ?? '',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${lecturer['name']} selected',
                                ),
                                backgroundColor: const Color(0xFF26A69A),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}