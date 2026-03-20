import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uniconnect/screens/student/student_main_nav.dart';
import '../../models/lecturer_model.dart';
import '../../services/database_service.dart';
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
  
  // State for slots
  List<Map<String, dynamic>> availableSlots = [];
  Map<String, dynamic>? selectedSlot;
  bool isLoading = true;

  // The URL for the lecturer's timetable (Google Sheet CSV)
  final String sheetUrl =
      "https://docs.google.com/spreadsheets/d/1N-8ZbnpqlKt2bsdk4UnBYCKJM6slHK2aHyKNMYaHVQA/export?format=csv";

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots();
  }

  // --- LOGIC TO FETCH AND PARSE SLOTS ---
  Future<void> _fetchAvailableSlots() async {
    try {
      final response = await http.get(Uri.parse(sheetUrl));

      if (response.statusCode == 200) {
        final data = response.body;
        List<List<String>> sheet = data
            .split("\n")
            .map((row) => row.split(","))
            .toList();

        List<String> dates = sheet[0];
        List<Map<String, dynamic>> fetchedSlots = [];

        // Parsing logic from your demo
        for (int i = 1; i < sheet.length; i++) {
          List<String> row = sheet[i];
          if (row.length < 3) continue;

          String start = row[0].trim();
          String end = row[1].trim();

          for (int j = 2; j < row.length; j++) {
            // If the cell is empty, the lecturer is free
            if (row[j].trim().isEmpty) {
              fetchedSlots.add({
                "date": dates[j].trim(),
                "time": "$start - $end",
              });
            }
          }
        }

        setState(() {
          availableSlots = fetchedSlots;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching slots: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Meeting Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLecturerSummary(),
            const SizedBox(height: 32),

            const Text(
              "Select an Available Slot",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
              : _buildSlotSelector(),

            const SizedBox(height: 32),

            const Text("Reason for Meeting", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Explain briefly why you want to meet...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                // Button is only active if a slot is selected
                onPressed: selectedSlot == null ? null : _submitMeetingRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "Submit Request",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotSelector() {
    if (availableSlots.isEmpty) {
      return const Text("No available slots found in timetable.", style: TextStyle(color: Colors.red));
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableSlots.length,
        itemBuilder: (context, index) {
          final slot = availableSlots[index];
          bool isSelected = selectedSlot == slot;

          return GestureDetector(
            onTap: () => setState(() => selectedSlot = slot),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12, bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? primaryGreen : Colors.grey.shade200,
                  width: 2,
                ),
                boxShadow: isSelected 
                  ? [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                  : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slot['date'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slot['time'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitMeetingRequest() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    try {
      await DatabaseService().saveMeetingRequest(
        studentUid: currentUser.uid,
        lecturerUid: widget.lecturer.uid,
        lecturerName: widget.lecturer.name,
        moduleName: widget.selectedModuleName ?? "No specific module selected",
        date: selectedSlot!['date'],
        time: selectedSlot!['time'],
        reason: _reasonController.text,
        location: widget.lecturer.location,
      );

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send request: $e")),
      );
    }
  }

  Widget _buildLecturerSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: primaryGreen.withOpacity(0.1),
            child: Text(
              widget.lecturer.name[0], 
              style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.lecturer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(widget.lecturer.faculty, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      widget.lecturer.location, 
                      style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text("Meeting request sent successfully!", textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const StudentMainNavigation()), 
                (route) => false,
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}