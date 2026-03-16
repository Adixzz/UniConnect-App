import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart'; // Required for better date formatting

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  // Updated list to store slots with specific dates
  final List<Map<String, String>> _mySlots = [
    {
      "time": "09:00 AM - 10:00 AM", 
      "note": "Available for Project Viva",
      "date": "19/3/2026"
    },
  ];

  final _noteController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // 1. Professional Time Picker Sheet
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: _timePickerTile("Starts", _startTime, () async {
                      final time = await showTimePicker(context: context, initialTime: _startTime);
                      if (time != null) setModalState(() => _startTime = time);
                    }),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.arrow_forward, color: Colors.grey),
                  ),
                  Expanded(
                    child: _timePickerTile("Ends", _endTime, () async {
                      final time = await showTimePicker(context: context, initialTime: _endTime);
                      if (time != null) setModalState(() => _endTime = time);
                    }),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: "Purpose (Optional)",
                  hintText: "e.g., Exam Prep",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0), // Consistent primary blue
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_selectedDay == null) return;
                    
                    setState(() {
                      _mySlots.add({
                        "time": "${_startTime.format(context)} - ${_endTime.format(context)}",
                        "note": _noteController.text.isEmpty ? "No notes" : _noteController.text,
                        "date": DateFormat('dd/MM/yyyy').format(_selectedDay!), // Save specific date
                      });
                    });
                    _noteController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("ADD TO CALENDAR", style: TextStyle(color: Colors.white)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(time.format(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Availability")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2025, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
          ),
          
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Your Slots", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_selectedDay == null ? "" : DateFormat('EEEE, d MMM').format(_selectedDay!)),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _mySlots.length,
              itemBuilder: (context, index) => _buildSlotTile(index),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSlotSheet,
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 2. Updated Slot Tile with Date Display
  Widget _buildSlotTile(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
          child: const Icon(Icons.access_time, color: Colors.blue),
        ),
        title: Text(_mySlots[index]['time']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            // THE FIX: Showing the date on the card
            Text("Date: ${_mySlots[index]['date']}", style: const TextStyle(color: Colors.blue, fontSize: 13)),
            Text(_mySlots[index]['note']!, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => setState(() => _mySlots.removeAt(index)),
            ),
          ],
        ),
      ),
    );
  }
}