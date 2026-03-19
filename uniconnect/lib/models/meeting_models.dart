import 'package:flutter/material.dart';

class Meeting {
  final String initials;
  final String name;
  final String subject;
  final String date;
  final String time;
  final String location;
  final String status;
  final bool showCancelButton;

  Meeting({
    required this.initials,
    required this.name,
    required this.subject,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
    this.showCancelButton = false,
  });

  // This helper ensures the UI shows the correct color for every status
  Color get statusColor {
    switch (status) {
      case 'Confirmed':
      case 'Accepted':
        return const Color(0xFF22C55E); // Green
      case 'Pending':
        return const Color(0xFFF59E0B); // Orange/Amber
      case 'Cancelled':
        return Colors.redAccent;        // Red
      case 'Completed':
        return Colors.blueAccent;       // Blue
      default:
        return Colors.grey;
    }
  }
}