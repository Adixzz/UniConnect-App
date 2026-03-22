import 'package:flutter/material.dart';
import '../models/student_models/meeting_models.dart';

class MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback? onCancel;

  const MeetingCard({super.key, required this.meeting, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE53935),
            child: Text(meeting.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(meeting.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87), overflow: TextOverflow.ellipsis),
                    ),
                    _buildStatusBadge(),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                  ],
                ),
                Text(meeting.subject, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.calendar_today_outlined, meeting.date),
                _buildInfoRow(Icons.access_time_outlined, meeting.time),
                _buildInfoRow(Icons.location_on_outlined, meeting.location),
                if (meeting.showCancelButton) _buildCancelButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Inside your MeetingCard widget...

Widget _buildStatusBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      // USE THE DYNAMIC COLOR FROM THE MODEL
      color: meeting.statusColor, 
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      // USE THE DYNAMIC STATUS STRING FROM THE MODEL
      meeting.status, 
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: OutlinedButton(
        onPressed: onCancel,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text('Cancel Meeting', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}