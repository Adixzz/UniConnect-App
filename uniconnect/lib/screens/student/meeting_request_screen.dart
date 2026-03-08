import 'package:flutter/material.dart';

class MeetingRequestScreen extends StatelessWidget {
  const MeetingRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.handshake_rounded,
                size: 64,
                // Uses the primary color from your UniConnect theme
                color: Color(0xFF6C63FF),
              ),
              SizedBox(height: 16),
              Text(
                'New Meeting Request',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please provide the details for your request below.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              SizedBox(height: 32),
              MeetingReasonForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class MeetingReasonForm extends StatefulWidget {
  const MeetingReasonForm({super.key});

  @override
  State<MeetingReasonForm> createState() => _MeetingReasonFormState();
}

class _MeetingReasonFormState extends State<MeetingReasonForm> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reason for the meeting.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Meeting request submitted!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    _reasonController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Reason for meeting',
                hintText: 'e.g., COMP2001 project discussion, club proposal...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 48.0),
                  child: Icon(Icons.subject_rounded),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submitRequest,
              icon: const Icon(Icons.send_rounded),
              label: const Text(
                'Submit Request',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
