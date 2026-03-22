import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String type; 
  final String message;
  final DateTime? eventDate;
  final String? eventTime;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.type,
    required this.message,
    this.eventDate,
    this.eventTime,
    required this.createdAt,
  });

  factory AnnouncementModel.fromMap(String id, Map<String, dynamic> map) {
    return AnnouncementModel(
      id: id,
      type: map['type'] ?? 'Notice',
      message: map['message'] ?? '',
      eventDate: map['eventDate'] != null ? (map['eventDate'] as Timestamp).toDate() : null,
      eventTime: map['eventTime'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'message': message,
      'eventDate': eventDate != null ? Timestamp.fromDate(eventDate!) : null,
      'eventTime': eventTime,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}