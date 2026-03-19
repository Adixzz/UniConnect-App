import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../models/lecturer_model.dart'; // Ensure this import is correct

class AvailabilityScreen extends StatefulWidget {
  final LecturerModel currentLecturer; // Pass the whole model here
  const AvailabilityScreen({super.key, required this.currentLecturer});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final DatabaseService _dbService = DatabaseService();
  
  bool _isAvailable = true; 
  String _currentStatus = "Available";

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  final List<Map<String, String>> _mySlots = [
    {
      "time": "09:00 AM - 10:00 AM", 
      "note": "Available for Project Viva",
      "date": "19/03/2026"
    },
  ];

  final _noteController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _loadCurrentStatus() async {
    try {
      // Use the doc ID from the model
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

  void _toggleStatus(bool value) async {
    String newStatus = value ? "Available" : "Not Available";
    
    setState(() {
      _isAvailable = value;
      _currentStatus = newStatus;
    });

    try {
      // FIXED: Search by staffId using isEqualTo
      final query = await FirebaseFirestore.instance
          .collection('lecturers')
          .where('staffId', isEqualTo: widget.currentLecturer.staffId)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'availability': newStatus,
        });
        debugPrint("Status updated for ${widget.currentLecturer.staffId}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Manage Availability", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusHeader(),
            _buildCalendarSection(),
            const SizedBox(height: 20),
            _buildSlotsHeader(),
            _buildSlotsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSlotSheet,
        backgroundColor: const Color(0xFF1565C0),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Slot", style: TextStyle(color: Colors.white)),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), // Fixed deprecation
            blurRadius: 15, 
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: _isAvailable ? Colors.green.shade50 : Colors.red.shade50,
            child: Icon(
              _isAvailable ? Icons.check_circle : Icons.do_not_disturb_on,
              color: _isAvailable ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Global Status", 
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                Text(
                  _currentStatus,
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                    color: _isAvailable ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isAvailable,
            activeTrackColor: Colors.green, // Fixed deprecation
            onChanged: _toggleStatus,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
      ),
    );
  }

  Widget _buildSlotsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Your Slots", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            _selectedDay == null ? "" : DateFormat('EEEE, d MMM').format(_selectedDay!),
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsList() {
    if (_mySlots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Text("No slots added for this day.", style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _mySlots.length,
      itemBuilder: (context, index) => _buildSlotTile(index),
    );
  }

  Widget _buildSlotTile(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
          child: const Icon(Icons.access_time, color: Colors.blue, size: 20),
        ),
        title: Text(_mySlots[index]['time']!, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Date: ${_mySlots[index]['date']}", 
              style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(_mySlots[index]['note']!, 
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
          onPressed: () => setState(() => _mySlots.removeAt(index)),
        ),
      ),
    );
  }

  void _showAddSlotSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
            left: 24, right: 24, top: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Create Available Slot", 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _timePickerTile("Starts", _startTime, () async {
                      final time = await showTimePicker(context: context, initialTime: _startTime);
                      if (time != null) setModalState(() => _startTime = time);
                    }),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
                  ),
                  Expanded(
                    child: _timePickerTile("Ends", _endTime, () async {
                      final time = await showTimePicker(context: context, initialTime: _endTime);
                      if (time != null) setModalState(() => _endTime = time);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: "Purpose (Optional)",
                  hintText: "e.g., Project Viva",
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_selectedDay == null) return;
                    setState(() {
                      _mySlots.add({
                        "time": "${_startTime.format(context)} - ${_endTime.format(context)}",
                        "note": _noteController.text.isEmpty ? "Available" : _noteController.text,
                        "date": DateFormat('dd/MM/yyyy').format(_selectedDay!),
                      });
                    });
                    _noteController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("SAVE SLOT", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timePickerTile(String label, TimeOfDay time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(time.format(context), 
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}