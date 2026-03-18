import 'package:flutter/material.dart';

enum RequestStatus { pending, approved, declined }

class RequestItem {
  final String name;
  final String initials;
  final String id;
  final String date;
  final String time;
  final String description;
  final String requestedAgo;
  final RequestStatus status;

  RequestItem({
    required this.name,
    required this.initials,
    required this.id,
    required this.date,
    required this.time,
    required this.description,
    required this.requestedAgo,
    required this.status,
  });
}
