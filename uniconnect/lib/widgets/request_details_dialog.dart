import 'package:flutter/material.dart';
import '../models/meeting_request.dart'; // Adjust path if needed

class RequestDetailsDialog extends StatelessWidget {
  final RequestItem request;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  const RequestDetailsDialog({
    Key? key,
    required this.request,
    required this.onApprove,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      backgroundColor: Colors.white,
      surfaceTintColor:
          Colors.transparent, // Removes slight color tint on Android
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meeting Request Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.black54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- DETAILS ---
            _buildDetailSection('Student(s)', request.name),
            const SizedBox(height: 20),

            // Replacing 'Type' with 'Student ID' as requested
            _buildDetailSection('Student ID', request.id),
            const SizedBox(height: 20),

            _buildDetailSection(
              'Requested Date & Time',
              '${request.date}\n${request.time}',
            ),
            const SizedBox(height: 20),

            _buildDetailSection('Purpose', request.description),
            const SizedBox(height: 32),

            // --- ACTION BUTTONS ---
            // Only show buttons if the request is still pending
            if (request.status == RequestStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        onApprove();
                        Navigator.of(context).pop(); // Close dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text(
                        'Approve',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        onDecline();
                        Navigator.of(context).pop(); // Close dialog
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE74C3C),
                        side: const BorderSide(color: Color(0xFFE74C3C)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: const Icon(Icons.cancel_outlined, size: 20),
                      label: const Text(
                        'Decline',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Helper to build the gray label + black text pairs
  Widget _buildDetailSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
