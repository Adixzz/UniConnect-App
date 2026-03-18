import 'package:flutter/material.dart';

class RequestActionCard extends StatelessWidget {
  final String name;
  final String reason;
  // 1. Add the callback functions
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;

  const RequestActionCard({
    super.key,
    required this.name,
    required this.reason,
    this.onApprove, // 2. Add them to the constructor
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        // Added a subtle shadow so the white card pops off the grey background
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                EdgeInsets.zero, // Removes default padding so it aligns nicely
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person, color: Colors.blue),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(reason),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    // Rounded edges for the buttons to match your UI
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: onApprove, // 3. Hook up Approve
                  child: const Text(
                    "Approve",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: onDecline, // 4. Hook up Decline
                  child: const Text(
                    "Decline",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
