import 'package:flutter/material.dart';
import '../models/meeting_request.dart'; // Adjust path if your model is named differently

// ==========================================
// 1. THE CLICKABLE REQUEST CARD
// ==========================================
class RequestCard extends StatelessWidget {
  final RequestItem request;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;
  final VoidCallback? onTap; // Added the onTap property

  const RequestCard({
    Key? key,
    required this.request,
    this.onApprove,
    this.onDecline,
    this.onTap, // Initialize it here
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      // Wrap with Material and InkWell to get that nice ripple effect when clicked
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap, // Triggers the tap action
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: Avatar, Name, ID, Badge ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _getAvatarColor(),
                      child: Text(
                        request.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request.id,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
                const SizedBox(height: 16),

                // --- DETAILS: Date, Time, Description ---
                _buildDetailRow(Icons.calendar_today_outlined, request.date),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.access_time_outlined, request.time),
                const SizedBox(height: 16),
                Text(
                  request.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  request.requestedAgo,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),

                // --- CONDITIONAL ACTION BUTTONS (Only for Pending) ---
                if (request.status == RequestStatus.pending) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onApprove ?? () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71), // Green
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 20,
                          ),
                          label: const Text(
                            'Approve',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDecline ?? () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE74C3C), // Red
                            side: const BorderSide(color: Color(0xFFE74C3C)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for Date/Time rows
  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      ],
    );
  }

  // Helper for the dynamic status badge
  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor = Colors.white;
    String text;

    switch (request.status) {
      case RequestStatus.pending:
        bgColor = const Color(0xFFF39C12); // Orange
        text = 'Pending';
        break;
      case RequestStatus.approved:
        bgColor = const Color(0xFF2ECC71); // Green
        text = 'Approved';
        break;
      case RequestStatus.declined:
        bgColor = const Color(0xFFE74C3C); // Red
        text = 'Declined';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper for mock avatar colors based on initials
  Color _getAvatarColor() {
    if (request.status == RequestStatus.pending) {
      return request.initials == 'LA'
          ? const Color(0xFF00B4D8)
          : const Color(0xFFD90429);
    } else if (request.status == RequestStatus.approved) {
      return const Color(0xFF5A189A);
    }
    return const Color(0xFFD90429);
  }
}

// ==========================================
// 2. THE POPUP DIALOG
// ==========================================
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
      surfaceTintColor: Colors.transparent,
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

            // Replaced "Type" with "Student ID"
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
