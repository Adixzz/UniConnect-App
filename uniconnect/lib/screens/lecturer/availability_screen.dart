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
  bool _isAutoLocked = false; 
  
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

  DateTime _parseTime(String timeStr, DateTime contextDate) {
    try {
      final parts = timeStr.trim().split(" ");
      final hm = parts[0].split(".");
      int hour = int.parse(hm[0]);
      int min = int.parse(hm[1]);
      if (parts[1].toUpperCase() == "PM" && hour != 12) hour += 12;
      if (parts[1].toUpperCase() == "AM" && hour == 12) hour = 0;
      return DateTime(contextDate.year, contextDate.month, contextDate.day, hour, min);
    } catch (e) {
      return DateTime(contextDate.year, contextDate.month, contextDate.day, 0, 0);
    }
  }

  void _loadCurrentStatus() async {
    try {
      final doc = await _dbService.getUserData(widget.currentLecturer.uid);
      if (!mounted) return;
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          if (!_isAutoLocked) {
            _currentStatus = data['availability'] ?? "Available";
            _isAvailable = _currentStatus == "Available";
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading status: $e");
    }
  }

  void _jumpToToday() {
    String todayStr = DateFormat("MMM d").format(DateTime.now()).replaceAll(' ', '');
    if (uniqueDates.contains(todayStr)) {
      if (mounted) setState(() => _selectedDate = todayStr);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No slots synced for today ($todayStr).")),
      );
    }
  }

  Future<void> _fetchSpreadsheetSlots() async {
    if (!mounted) return;
    setState(() => _isLoadingSlots = true);
    
    try {
      final response = await http.get(Uri.parse(exportUrl));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = response.body;
        List<List<String>> sheet = data.split("\n").map((row) => row.split(",")).toList();
        if (sheet.isEmpty || sheet[0].length < 2) return;

        List<String> dates = sheet[0]; 
        List<Map<String, dynamic>> fetchedSlots = [];
        Set<String> dateSet = {"All"};

        DateTime now = DateTime.now();
        DateTime todayMidnight = DateTime(now.year, now.month, now.day);

        // --- 1. WEEKEND SCANNER ---
        Set<int> weekendColumnIndices = {};
        for (var row in sheet) {
          for (int j = 0; j < row.length; j++) {
            if (row[j].toUpperCase().contains("WEEKEND")) {
              weekendColumnIndices.add(j);
            }
          }
        }

        // --- 2. DETECT AUTO-STATUS (LECTURE OR WEEKEND) ---
        String todayStr = DateFormat("MMM d").format(now).replaceAll(' ', '');
        int todayCol = -1;
        for (int j = 0; j < dates.length; j++) {
          if (dates[j].trim().replaceAll(' ', '') == todayStr) {
            todayCol = j;
            break;
          }
        }

        bool isWeekend = (todayCol != -1 && weekendColumnIndices.contains(todayCol));
        bool currentlyInLecture = false;
        String lectureName = "";

        if (!isWeekend && todayCol != -1) {
          for (int i = 1; i < sheet.length; i++) {
            List<String> row = sheet[i];
            if (row.length < 2) continue;
            DateTime start = _parseTime(row[0], now);
            DateTime end = _parseTime(row[1], now);
            
            if (now.isAfter(start.subtract(const Duration(seconds: 1))) && now.isBefore(end)) {
              String content = (todayCol < row.length) ? row[todayCol].trim() : "";
              if (content.isNotEmpty) {
                currentlyInLecture = true;
                lectureName = content;
              }
              break;
            }
          }
        }

        // --- 3. PARSE UPCOMING FREE SLOTS ---
        for (int i = 1; i < sheet.length; i++) {
          List<String> row = sheet[i];
          if (row.length < 2) continue;
          String startTime = row[0].trim();
          String endTime = row[1].trim();

          for (int j = 2; j < dates.length; j++) {
            String dateString = dates[j].trim();
            if (dateString.isEmpty) continue; 

            bool isPastDay = false;
            try {
              String cleanDate = dateString.replaceAllMapped(
                RegExp(r'([a-zA-Z]+)(\d+)'), 
                (match) => '${match.group(1)} ${match.group(2)}'
              );
              DateTime parsedDate = DateFormat("MMM d").parse(cleanDate);
              DateTime fullDate = DateTime(now.year, parsedDate.month, parsedDate.day);
              if (fullDate.isBefore(todayMidnight)) isPastDay = true;
            } catch (e) {}

            if (isPastDay || weekendColumnIndices.contains(j)) continue;

            String cellValue = (j < row.length) ? row[j].trim() : "";
            if (cellValue.isEmpty) {
              fetchedSlots.add({"date": dateString, "time": "$startTime - $endTime"});
              dateSet.add(dateString);
            }
          }
        }

        if (mounted) {
          setState(() {
            availableSlots = fetchedSlots;
            uniqueDates = dateSet.toList()..sort();
            _isLoadingSlots = false;
            _isAutoLocked = isWeekend || currentlyInLecture;

            if (isWeekend) {
              _currentStatus = "Not Available (Weekend)";
              _isAvailable = false;
              _updateFirestoreAvailability(_currentStatus);
            } else if (currentlyInLecture) {
              _currentStatus = "In a Lecture ($lectureName)";
              _isAvailable = false;
              _updateFirestoreAvailability(_currentStatus);
            } else {
              _loadCurrentStatus(); 
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Sync Error: $e");
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  Future<void> _updateFirestoreAvailability(String status) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('lecturers')
          .where('staffId', isEqualTo: widget.currentLecturer.staffId)
          .get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({'availability': status});
      }
    } catch (e) {
      debugPrint("Firestore Error: $e");
    }
  }

  void _toggleStatus(bool value) async {
    if (_isAutoLocked) return;
    String newStatus = value ? "Available" : "Not Available";
    if (mounted) {
      setState(() {
        _isAvailable = value;
        _currentStatus = newStatus;
      });
    }
    _updateFirestoreAvailability(newStatus);
  }

  Future<void> _openSpreadsheet() async {
    if (!await launchUrl(editUrl)) throw Exception('Could not launch $editUrl');
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedDate == "All" 
        ? availableSlots 
        : availableSlots.where((s) => s['date'] == _selectedDate).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Availability Sync", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
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
                if (mounted) setState(() => _selectedDate = dateLabel);
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: _isAutoLocked ? Colors.orange.shade50 : (_isAvailable ? Colors.green.shade50 : Colors.red.shade50),
            child: Icon(
              _isAutoLocked ? Icons.lock : (_isAvailable ? Icons.check_circle : Icons.do_not_disturb_on), 
              color: _isAutoLocked ? Colors.orange : (_isAvailable ? Colors.green : Colors.red)
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_isAutoLocked ? "Auto-Status (Locked)" : "Global Visibility", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(_currentStatus, 
                  style: TextStyle(
                    fontSize: 15, 
                    fontWeight: FontWeight.bold, 
                    color: _isAutoLocked ? Colors.orange : (_isAvailable ? Colors.green : Colors.red)
                  )
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isAvailable, 
            activeTrackColor: Colors.green, 
            onChanged: _isAutoLocked ? null : _toggleStatus
          ),
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
    if (slots.isEmpty) return const Center(child: Text("No upcoming free slots found."));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
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