import 'package:flutter/material.dart';

class MeetingItem extends StatelessWidget {
  final String title;
  final String dateTime;
  final String statusText;
  final Color statusColor;
  final Color statusTextColor;

  const MeetingItem({
    super.key,
    required this.title,
    required this.dateTime,
    required this.statusText,
    required this.statusColor,
    this.statusTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFFEAF2FF),
          child: Icon(
            Icons.calendar_today_outlined,
            color: Colors.blue,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateTime,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: statusTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );
  }
}