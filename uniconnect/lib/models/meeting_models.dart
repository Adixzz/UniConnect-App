import 'package:flutter/material.dart';

class Meeting {
  final String initials;
  final String name;
  final String subject;
  final String date;
  final String time;
  final String location;
  final String status; // 'Confirmed' or 'Pending'
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

  // Helper to get status color
  Color get statusColor => status == 'Confirmed' ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);
}