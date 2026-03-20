import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 
import '../../services/database_service.dart';
import '../../models/lecturer_model.dart';

class AvailabilityScreen extends StatefulWidget {
  final LecturerModel currentLecturer;
  const AvailabilityScreen({super.key, required this.currentLecturer});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isAvailable = true;
  String _currentStatus = "Available";
  
  List<Map<String, dynamic>> availableSlots = [];
  List<String> uniqueDates = [];
  String _selectedDate = "All";
  bool _isLoadingSlots = true;

  final String exportUrl = "https://docs.google.com/spreadsheets/d/1N-8ZbnpqlKt2bsdk4UnBYCKJM6slHK2aHyKNMYaHVQA/export?format=csv";
  final Uri editUrl = Uri.parse("https://docs.google.com/spreadsheets/d/1N-8ZbnpqlKt2bsdk4UnBYCKJM6slHK2aHyKNMYaHVQA/edit");

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
    _fetchSpreadsheetSlots();
  }

  void _loadCurrentStatus() async {
    try {
      final doc = await _dbService.getUserData(widget.currentLecturer.uid);
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _currentStatus = data['availability'] ?? "Available";
          _isAvailable = _currentStatus == "Available";
        });
      }
    } catch (e) {
      debugPrint("Error loading status: $e");
    }
  }

  void _jumpToToday() {
    String todayStr = DateFormat("MMM d").format(DateTime.now()).replaceAll(' ', '');
    if (uniqueDates.contains(todayStr)) {
      setState(() => _selectedDate = todayStr);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No slots synced for today ($todayStr).")),
      );
    }
  }

  // --- UPDATED PARSING LOGIC TO HIDE PREVIOUS DAYS ---
  Future<void> _fetchSpreadsheetSlots() async {
    setState(() => _isLoadingSlots = true);
    try {
      final response = await http.get(Uri.parse(exportUrl));
      if (response.statusCode == 200) {
        final data = response.body;
        List<List<String>> sheet = data.split("\n").map((row) => row.split(",")).toList();
        
        if (sheet.isEmpty || sheet[0].length < 2) return;

        List<String> dates = sheet[0]; 
        List<Map<String, dynamic>> fetchedSlots = [];
        Set<String> dateSet = {"All"};

        // Current date for comparison (midnight)
        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);

        // 1. Identify Weekend Columns
        Set<int> weekendColumnIndices = {};
        for (var row in sheet) {
          for (int j = 0; j < row.length; j++) {
            if (row[j].toUpperCase().contains("WEEKEND")) {
              weekendColumnIndices.add(j);
            }
          }
        }

        for (int i = 1; i < sheet.length; i++) {
          List<String> row = sheet[i];
          if (row.length < 2) continue;
          
          String start = row[0].trim();
          String end = row[1].trim();

          for (int j = 2; j < dates.length; j++) {
            String dateString = dates[j].trim();
            if (dateString.isEmpty) continue; 

            // --- NEW: PREVIOUS DAY FILTER ---
            bool isPastDay = false;
            try {
              // Parse "Mar 20" format
              String cleanDate = dateString.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ');
              DateTime parsedDate = DateFormat("MMM d").parse(cleanDate);
              // Check against year 2026 context
              DateTime fullDate = DateTime(2026, parsedDate.month, parsedDate.day);
              
              if (fullDate.isBefore(today)) {
                isPastDay = true;
              }
            } catch (e) {
              // If date format is weird, we keep it to be safe
            }

            if (isPastDay) continue; // Skip if the day has already passed
            if (weekendColumnIndices.contains(j)) continue; // Skip if weekend

            String cellValue = (j < row.length) ? row[j].trim() : "";

            if (cellValue.isEmpty) {
              fetchedSlots.add({
                "date": dateString,
                "time": "$start - $end",
              });
              dateSet.add(dateString);
            }
          }
        }
        setState(() {
          availableSlots = fetchedSlots;
          uniqueDates = dateSet.toList()..sort();
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      debugPrint("Sync Error: $e");
      setState(() => _isLoadingSlots = false);
    }
  }

  // ... (ToggleStatus, OpenSpreadsheet, and build methods)

  void _toggleStatus(bool value) async {
    String newStatus = value ? "Available" : "Not Available";
    setState(() {
      _isAvailable = value;
      _currentStatus = newStatus;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('lecturers')
          .where('staffId', isEqualTo: widget.currentLecturer.staffId)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({'availability': newStatus});
      }
    } catch (e) {
      debugPrint("Status update failed: $e");
    }
  }

  Future<void> _openSpreadsheet() async {
    if (!await launchUrl(editUrl)) {
      throw Exception('Could not launch $editUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedDate == "All" 
        ? availableSlots 
        : availableSlots.where((s) => s['date'] == _selectedDate).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Availability Sync", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _jumpToToday, 
            child: const Text("TODAY", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _fetchSpreadsheetSlots,
          )
        ],
      ),
      body: Column(
        children: [
          _buildStatusHeader(),
          _buildSpreadsheetLink(),
          const SizedBox(height: 12),
          if (!_isLoadingSlots && uniqueDates.isNotEmpty) _buildFilterBar(),
          Expanded(
            child: _isLoadingSlots 
              ? const Center(child: CircularProgressIndicator()) 
              : _buildGroupedSlotList(filteredList),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: uniqueDates.length,
        itemBuilder: (context, index) {
          String dateLabel = uniqueDates[index];
          bool isSelected = _selectedDate == dateLabel;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(dateLabel),
              selected: isSelected,
              onSelected: (bool value) {
                setState(() => _selectedDate = dateLabel);
              },
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue.shade700 : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: _isAvailable ? Colors.green.shade50 : Colors.red.shade50,
            child: Icon(_isAvailable ? Icons.check_circle : Icons.do_not_disturb_on, color: _isAvailable ? Colors.green : Colors.red),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Global Visibility", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(_currentStatus, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isAvailable ? Colors.green : Colors.red)),
              ],
            ),
          ),
          Switch.adaptive(value: _isAvailable, activeTrackColor: Colors.green, onChanged: _toggleStatus),
        ],
      ),
    );
  }

  Widget _buildSpreadsheetLink() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: _openSpreadsheet,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: const Row(
            children: [
              Icon(Icons.table_chart, color: Colors.blue),
              SizedBox(width: 12),
              Expanded(child: Text("Edit Timetable (Google Sheets)", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
              Icon(Icons.open_in_new, color: Colors.blue, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedSlotList(List<Map<String, dynamic>> slots) {
    if (slots.isEmpty) {
      return const Center(child: Text("No upcoming free slots found."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: const Icon(Icons.access_time_filled, color: Colors.blue, size: 20),
            title: Text(slot['time'], style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(slot['date'], style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
        );
      },
    );
  }
}