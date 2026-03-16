import 'package:flutter/material.dart';
import '../../models/lecturer_model.dart'; // Ensure the path is correct

class GlobalLecturerSearch extends StatefulWidget {
  const GlobalLecturerSearch({super.key});

  @override
  State<GlobalLecturerSearch> createState() => _GlobalLecturerSearchState();
}

class _GlobalLecturerSearchState extends State<GlobalLecturerSearch> {
  final Color primaryGreen = const Color(0xFF10B981);
  final TextEditingController _searchController = TextEditingController();
  
  // This would typically come from your Database/Provider
  final List<LecturerModel> _allLecturers = [
    LecturerModel(
      uid: '1',
      name: 'Dr. Sarah Johnson',
      email: 'sarah.j@university.com',
      staffId: 'L001',
      pin: '1234',
      faculty: 'FOC',
      modules: ['Data Structures', 'Algorithms'],
      availability: 'Available',
    ),
    LecturerModel(
      uid: '2',
      name: 'Prof. Michael Chen',
      email: 'm.chen@university.com',
      staffId: 'L002',
      pin: '5678',
      faculty: 'FOB',
      modules: ['Business Analytics'],
      availability: 'In Meeting',
    ),
  ];

  List<LecturerModel> _filteredLecturers = [];

  @override
  void initState() {
    _filteredLecturers = _allLecturers;
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    List<LecturerModel> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allLecturers;
    } else {
      results = _allLecturers
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredLecturers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Search Lecturers', 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search, color: primaryGreen),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results List
            Expanded(
              child: _filteredLecturers.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredLecturers.length,
                      itemBuilder: (context, index) {
                        final lecturer = _filteredLecturers[index];
                        return _buildLecturerCard(lecturer);
                      },
                    )
                  : _buildNoResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLecturerCard(LecturerModel lecturer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: primaryGreen.withOpacity(0.1),
          child: Text(
            lecturer.name[0], // First letter of name
            style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        title: Text(lecturer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(lecturer.faculty, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: lecturer.availability == 'Available' 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                lecturer.availability,
                style: TextStyle(
                  fontSize: 11, 
                  fontWeight: FontWeight.bold,
                  color: lecturer.availability == 'Available' ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // NEXT STEP: Navigate to Request Details Input Screen
          print("Selected: ${lecturer.name}");
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_off_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text("No lecturers found", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
      ],
    );}}