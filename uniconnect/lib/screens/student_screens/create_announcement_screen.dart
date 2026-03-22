import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Required for DateFormat

class CreateAnnouncementScreen extends StatefulWidget {
  final String clubId;
  const CreateAnnouncementScreen({super.key, required this.clubId});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  
  String _selectedType = 'Notice'; // Dropdown state
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  final Color primaryGreen = const Color(0xFF10B981); //

  // --- SUBMIT TO FIRESTORE ---
  Future<void> _postAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    // If it's an event, make sure they actually picked a date/time
    if (_selectedType == 'Event' && (_selectedDate == null || _selectedTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both a date and time for the event.")),
      );
      return;
    }

    try {
      // Save to subcollection: clubs -> {clubId} -> announcements
      await FirebaseFirestore.instance
          .collection('clubs')
          .doc(widget.clubId)
          .collection('announcements')
          .add({
        'type': _selectedType,
        'message': _messageController.text.trim(),
        'eventDate': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
        'eventTime': _selectedTime?.format(context),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Announcement posted successfully!")),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Create Announcement", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TYPE SELECTION
              const Text("Announcement Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.layers, color: primaryGreen),
                ),
                items: ['Notice', 'Event'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),

              const SizedBox(height: 24),

              // DYNAMIC EVENT INFO (DATE/TIME)
              if (_selectedType == 'Event') ...[
                const Text("Event Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context, 
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(), 
                            lastDate: DateTime(2027)
                          );
                          if (date != null) setState(() => _selectedDate = date);
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text(_selectedDate == null ? "Pick Date" : DateFormat('MMM d, y').format(_selectedDate!)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (time != null) setState(() => _selectedTime = time);
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(_selectedTime == null ? "Pick Time" : _selectedTime!.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // MESSAGE AREA
              const Text("Message", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                maxLength: 100, // Hard limit of 100 characters as requested
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "What's the update, Prez?",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.isEmpty) ? "Please enter a message" : null,
              ),

              const SizedBox(height: 40),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _postAnnouncement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Post to Members", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}