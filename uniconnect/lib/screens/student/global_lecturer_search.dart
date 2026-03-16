import 'package:flutter/material.dart';
import '../../models/lecturer_model.dart';
import '../../services/database_service.dart';
import 'meeting_details_screen.dart';

class GlobalLecturerSearch extends StatefulWidget {
  const GlobalLecturerSearch({super.key});

  @override
  State<GlobalLecturerSearch> createState() => _GlobalLecturerSearchState();
}

class _GlobalLecturerSearchState extends State<GlobalLecturerSearch> {
  final Color primaryGreen = const Color(0xFF10B981);
  final TextEditingController _searchController = TextEditingController();
  
  // State variables
  List<LecturerModel> _allLecturers = []; // Stores the full list from Firebase
  List<LecturerModel> _filteredLecturers = []; // Stores what is currently shown
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLecturers();
  }

  // Fetch real data from your DatabaseService
  Future<void> _fetchLecturers() async {
    try {
      final data = await DatabaseService().getAllLecturers();
      setState(() {
        _allLecturers = data;
        _filteredLecturers = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching lecturers: $e")),
      );
    }
  }

  // Local filtering logic (Instant search)
  void _runFilter(String enteredKeyword) {
    List<LecturerModel> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allLecturers;
    } else {
      results = _allLecturers
          .where((lecturer) =>
              lecturer.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
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
            // Professional Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search, color: primaryGreen),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () {
                        _searchController.clear();
                        _runFilter('');
                      }) 
                  : null,
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

            // Loading or Results
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                : _filteredLecturers.isNotEmpty
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
            lecturer.name[0].toUpperCase(),
            style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        title: Text(lecturer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(lecturer.faculty, style: TextStyle(color: Colors.grey.shade600)),
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

  Widget _buildNoResults() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_off_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text("No lecturers found", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
      ],
    );
  }
}