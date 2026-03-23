import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  Future<void> notifyStudents({
    required String timetableId,
    required String pathway,
    required String degree,
    required String academicYear,
    required String semester,
    required String calendarYear,
    required String message,
  }) async {
    try {
      await _db.collection('notifications').add({
        'timetableId': timetableId,
        'pathway': pathway,
        'degree': degree,
        'academicYear': academicYear,
        'semester': semester,
        'calendarYear': calendarYear,
        'message': message,
        'sentAt': DateTime.now().toIso8601String(),
        'type': 'timetable_update',
      });
    } catch (e) {
      throw Exception("Error sending notification: $e");
    }
  }
}