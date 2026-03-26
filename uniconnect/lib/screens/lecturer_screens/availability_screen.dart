import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; 
import '../../services/lecturer_database_service.dart';
import '../../models/lecturer_model.dart';

class AvailabilityScreen extends StatefulWidget {
  final LecturerModel currentLecturer;
  const AvailabilityScreen({super.key, required this.currentLecturer});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final LecturerDatabaseService _dbService = LecturerDatabaseService();
  
  bool _isAvailable = true;
  String _currentStatus = "Available";
  bool _isAutoLocked = false; 
  bool _isLoadingSlots = true;
  
  List<Map<String, dynamic>> availableSlots = [];
  List<String> uniqueDates = [];
  String _selectedDate = "All";

  @override
  void initState() {
    super.initState();
    _initialSync();
  }

  // Initial data load combining spreadsheet and firestore
  Future<void> _initialSync() async {
    await _fetchDataFromSpreadsheet();
    if (!_isAutoLocked) {
      _loadManualStatusFromFirestore();
    }
  }

  Future<void> _fetchDataFromSpreadsheet() async {
    if (widget.currentLecturer.timetableURL.isEmpty) {
      if (mounted) setState(() => _isLoadingSlots = false);
      return;
    }

    if (mounted) setState(() => _isLoadingSlots = true);
    
    try {
      final result = await _dbService.fetchAndParseAvailability(widget.currentLecturer.timetableURL);
      
      if (!mounted) return;

      setState(() {
        availableSlots = result['slots'];
        uniqueDates = result['dates'];
        _isLoadingSlots = false;
        
        // Handle Auto-locking logic based on spreadsheet
        bool isWeekend = result['isWeekend'];
        bool currentlyInLecture = result['inLecture'];
        String lectureName = result['lectureName'];

        _isAutoLocked = isWeekend || currentlyInLecture;

        if (isWeekend) {
          _currentStatus = "Not Available (Weekend)";
          _isAvailable = false;
          _dbService.updateFirestoreAvailability(widget.currentLecturer.staffId, _currentStatus);
        } else if (currentlyInLecture) {
          _currentStatus = "In a Lecture ($lectureName)";
          _isAvailable = false;
          _dbService.updateFirestoreAvailability(widget.currentLecturer.staffId, _currentStatus);
        }
      });
    } catch (e) {
      debugPrint("Sync Error: $e");
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  void _loadManualStatusFromFirestore() async {
    try {
      final doc = await _dbService.getUserData(widget.currentLecturer.uid);
      if (!mounted) return;
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _currentStatus = data['availability'] ?? "Available";
          _isAvailable = _currentStatus == "Available";
        });
      }
    } catch (e) {
      debugPrint("Firestore Load Error: $e");
    }
  }

  void _toggleStatus(bool value) {
    if (_isAutoLocked) return;
    String newStatus = value ? "Available" : "Not Available";
    setState(() {
      _isAvailable = value;
      _currentStatus = newStatus;
    });
    _dbService.updateFirestoreAvailability(widget.currentLecturer.staffId, newStatus);
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

  Future<void> _openSpreadsheet() async {
    final uri = Uri.parse(widget.currentLecturer.timetableURL);
    if (!await launchUrl(uri)) throw Exception('Could not launch $uri');
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedDate == "All" 
        ? availableSlots 
        : availableSlots.where((s) => s['date'] == _selectedDate).toList();

   return PopScope(
    canPop: false,
    child: Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Availability Sync", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
        actions: [
          TextButton(onPressed: _jumpToToday, child: const Text("TODAY", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.blue), onPressed: _fetchDataFromSpreadsheet)
        ],
      ),
      body: Column(
        children: [
          _buildStatusHeader(),
          _buildSpreadsheetLink(),
          const SizedBox(height: 12),
          if (!_isLoadingSlots && uniqueDates.isNotEmpty) _buildFilterBar(),
          Expanded(
            child: widget.currentLecturer.timetableURL.isEmpty 
              ? const Center(child: Text("No timetable URL linked."))
              : (_isLoadingSlots 
                  ? const Center(child: CircularProgressIndicator()) 
                  : _buildGroupedSlotList(filteredList)),
          ),
        ],
      ),
    ));
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
              onSelected: (bool value) => setState(() => _selectedDate = dateLabel),
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
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
                Text(_currentStatus, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _isAutoLocked ? Colors.orange : (_isAvailable ? Colors.green : Colors.red))),
              ],
            ),
          ),
          Switch.adaptive(value: _isAvailable, activeTrackColor: Colors.green, onChanged: _isAutoLocked ? null : _toggleStatus),
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
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.blue.shade100)),
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