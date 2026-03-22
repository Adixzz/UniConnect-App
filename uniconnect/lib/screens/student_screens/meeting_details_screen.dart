import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; 
import 'package:uniconnect/screens/student_screens/student_main_nav.dart';
import '../../models/lecturer_model.dart';
import '../../services/student_database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeetingDetailsScreen extends StatefulWidget {
  final LecturerModel lecturer;
  final String? selectedModuleName;

  const MeetingDetailsScreen({
    super.key, 
    required this.lecturer, 
    this.selectedModuleName
  });

  @override
  State<MeetingDetailsScreen> createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  final Color primaryGreen = const Color(0xFF10B981);
  final _reasonController = TextEditingController();
  
  List<Map<String, dynamic>> allAvailableSlots = [];
  List<String> uniqueDates = []; 
  String? selectedDateChip; 
  Map<String, dynamic>? selectedSlot; 
  
  bool isLoading = true;

  // DYNAMIC URL CONVERTER
 
  String get _dynamicSheetUrl {
    String baseUrl = widget.lecturer.timetableURL;
    if (baseUrl.contains('/edit')) {
      return baseUrl.split('/edit')[0] + '/export?format=csv';
    }
    return baseUrl;
  }

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots();
  }

  //TIME PARSER HELPER
  DateTime _parseSlotTime(String timeStr, DateTime dateContext) {
    try {
      final parts = timeStr.trim().split(" ");
      final hm = parts[0].split(".");
      int hour = int.parse(hm[0]);
      int min = int.parse(hm[1]);
      
      if (parts[1].toUpperCase() == "PM" && hour != 12) hour += 12;
      if (parts[1].toUpperCase() == "AM" && hour == 12) hour = 0;
      
      return DateTime(dateContext.year, dateContext.month, dateContext.day, hour, min);
    } catch (e) {
      return dateContext; 
    }
  }

  // MAIN FETCH & FILTER LOGIC 
  Future<void> _fetchAvailableSlots() async {
    if (widget.lecturer.timetableURL.isEmpty) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(Uri.parse(_dynamicSheetUrl));

      if (response.statusCode == 200) {
        final data = response.body;
        List<List<String>> sheet = data.split("\n").map((row) => row.split(",")).toList();

        if (sheet.isEmpty || sheet[0].length < 2) return;

        List<String> dates = sheet[0];
        List<Map<String, dynamic>> fetchedSlots = [];
        Set<String> dateSet = {};
        
        DateTime now = DateTime.now(); 
        DateTime todayMidnight = DateTime(now.year, now.month, now.day);
        DateTime rangeLimit = todayMidnight.add(const Duration(days: 5));

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
          
          String startStr = row[0].trim();
          String endStr = row[1].trim();

          for (int j = 2; j < dates.length; j++) {
            String dateString = dates[j].trim();
            if (dateString.isEmpty || weekendColumnIndices.contains(j)) continue;

            try {
              String cleanDate = dateString.replaceAllMapped(
                RegExp(r'([a-zA-Z]+)(\d+)'), 
                (match) => '${match.group(1)} ${match.group(2)}'
              );
              
              DateTime parsedDate = DateFormat("MMM d").parse(cleanDate);
              DateTime fullDate = DateTime(now.year, parsedDate.month, parsedDate.day);
              
              if (fullDate.isAtSameMomentAs(todayMidnight) || 
                 (fullDate.isAfter(todayMidnight) && fullDate.isBefore(rangeLimit.add(const Duration(seconds: 1))))) {
                
                String cellValue = (j < row.length) ? row[j].trim() : "";
                
                if (cellValue.isEmpty) {
                  DateTime slotStartTime = _parseSlotTime(startStr, fullDate);

                  if (slotStartTime.isAfter(now)) {
                    fetchedSlots.add({
                      "date": dateString,
                      "time": "$startStr - $endStr",
                    });
                    dateSet.add(dateString);
                  }
                }
              }
            } catch (e) {
              debugPrint("Date error: $e for $dateString");
              continue; 
            }
          }
        }

        if (mounted) {
          setState(() {
            allAvailableSlots = fetchedSlots;
            uniqueDates = dateSet.toList()..sort((a, b) => a.compareTo(b));
            if (uniqueDates.isNotEmpty) selectedDateChip = uniqueDates[0];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSlots = allAvailableSlots.where((s) => s['date'] == selectedDateChip).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Meeting Details', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLecturerSummary(),
            const SizedBox(height: 32),

            const Text("Select Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            isLoading ? const SizedBox() : _buildDateFilterBar(),

            const SizedBox(height: 24),
            const Text("Available Times", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (widget.lecturer.timetableURL.isEmpty)
              const Center(child: Text("This lecturer hasn't linked a timetable yet.", style: TextStyle(color: Colors.red)))
            else
              isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                : _buildTimeSlotList(filteredSlots),

            const SizedBox(height: 32),
            const Text("Reason for Meeting", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Briefly explain the purpose...",
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: selectedSlot == null ? null : _submitMeetingRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen, disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Submit Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

 //Widgets

  Widget _buildDateFilterBar() {
    if (uniqueDates.isEmpty) {
      return const Text("No available dates found for this lecturer.", style: TextStyle(color: Colors.grey));
    }
    String todayMarker = DateFormat("MMM d").format(DateTime.now()).replaceAll(' ', '');
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: uniqueDates.length,
        itemBuilder: (context, index) {
          String date = uniqueDates[index];
          bool isSelected = selectedDateChip == date;
          bool isToday = date.replaceAll(' ', '') == todayMarker;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(isToday ? "Today ($date)" : date),
              selected: isSelected,
              onSelected: (val) => setState(() { selectedDateChip = date; selectedSlot = null; }),
              selectedColor: primaryGreen.withOpacity(0.2),
              checkmarkColor: primaryGreen,
              labelStyle: TextStyle(color: isSelected ? primaryGreen : Colors.black87, fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? primaryGreen : Colors.grey.shade300)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotList(List<Map<String, dynamic>> slots) {
    if (slots.isEmpty && !isLoading) return const Text("No available times for this day.");
    return Column(
      children: slots.map((slot) {
        bool isSelected = selectedSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => selectedSlot = slot),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: isSelected ? primaryGreen : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? primaryGreen : Colors.grey.shade200)),
            child: Row(
              children: [
                Icon(Icons.access_time, color: isSelected ? Colors.white : primaryGreen, size: 20),
                const SizedBox(width: 12),
                Text(slot['time'], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _submitMeetingRequest() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    try {
      await StudentDatabaseService().saveMeetingRequest(
        studentUid: currentUser.uid,
        lecturerUid: widget.lecturer.uid,
        lecturerName: widget.lecturer.name,
        moduleName: widget.selectedModuleName ?? "General Consultation",
        date: selectedSlot!['date'],
        time: selectedSlot!['time'],
        reason: _reasonController.text,
        location: widget.lecturer.location,
      );
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send request: $e")));
    }
  }

  Widget _buildLecturerSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Row(
        children: [
          CircleAvatar(radius: 30, backgroundColor: primaryGreen.withOpacity(0.1), child: Text(widget.lecturer.name[0], style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 24))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.lecturer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(widget.lecturer.faculty, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(widget.lecturer.location, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500))]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text("Meeting request sent successfully!", textAlign: TextAlign.center),
        actions: [TextButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const StudentMainNavigation()), (route) => false), child: const Text("OK"))],
      ),
    );
  }
}