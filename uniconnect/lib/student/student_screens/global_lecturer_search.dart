import 'package:flutter/material.dart';
import '../../student/student_models/lecturer_model.dart';
import '../../services/student_database_service.dart';
import 'meeting_details_screen.dart';

class GlobalLecturerSearch extends StatefulWidget {
  const GlobalLecturerSearch({super.key});

  @override
  State<GlobalLecturerSearch> createState() => _GlobalLecturerSearchState();
}

class _GlobalLecturerSearchState extends State<GlobalLecturerSearch> {
  final Color primaryGreen = const Color(0xFF10B981);
  final TextEditingController _searchController = TextEditingController();
  
  List<LecturerModel> _allLecturers = [];
  List<LecturerModel> _filteredLecturers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLecturers();
  }

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

  void _runFilter(String enteredKeyword) {
    setState(() {
      _filteredLecturers = enteredKeyword.isEmpty 
          ? _allLecturers 
          : _allLecturers.where((l) => l.name.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
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
            TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search, color: primaryGreen),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _runFilter(''); }) 
                  : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                : _filteredLecturers.isNotEmpty
                    ? ListView.builder(
                        itemCount: _filteredLecturers.length,
                        itemBuilder: (context, index) => _buildLecturerCard(_filteredLecturers[index]),
                      )
                    : _buildNoResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLecturerCard(LecturerModel lecturer) {
    //STATUS
    String status = lecturer.availability;
    Color badgeColor = Colors.grey;
    IconData statusIcon = Icons.do_not_disturb_on;
    String displayStatus = status;

    if (status == "Available") {
      badgeColor = primaryGreen;
      statusIcon = Icons.check_circle;
    } else if (status.contains("Lecture")) {
      badgeColor = Colors.orange; 
      statusIcon = Icons.school;
      displayStatus = "In Lecture";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: badgeColor.withOpacity(0.1),
          child: Text(
            lecturer.name[0].toUpperCase(), 
            style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 20)
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(lecturer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            //DYNAMIC BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 12, color: badgeColor),
                  const SizedBox(width: 4),
                  Text(
                    displayStatus,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Text(lecturer.faculty, style: TextStyle(color: Colors.grey.shade600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingDetailsScreen(
                lecturer: lecturer,
                selectedModuleName: "No specific module selected",
              ),
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