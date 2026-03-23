import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;

class LecturerDatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

// --- UPDATED: Fetch basic user data using .where() ---
  Future<DocumentSnapshot> getUserData(String uid) async {
    final query = await _db
        .collection('lecturers')
        .where('uid', isEqualTo: uid)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first; // Returns the actual document (e.g. KbBRAvt...)
    } else {
      throw Exception("Lecturer document not found for this UID!");
    }
  }
  Future<void> updateMeetingStatus(String meetingId, String status) async {
    await _db.collection('meetings').doc(meetingId).update({'status': status});
  }

  // Update availability status in Firestore
  Future<void> updateFirestoreAvailability(
    String staffId,
    String status,
  ) async {
    try {
      final query = await _db
          .collection('lecturers')
          .where('staffId', isEqualTo: staffId)
          .get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({'availability': status});
      }
    } catch (e) {
      debugPrint("Firestore Update Error: $e");
    }
  }

  // Core logic to fetch spreadsheet and determine availability
  Future<Map<String, dynamic>> fetchAndParseAvailability(
    String timetableURL,
  ) async {
    // Convert view URL to export URL
    String exportUrl = timetableURL.contains('/edit')
        ? timetableURL.split('/edit')[0] + '/export?format=csv'
        : timetableURL;

    final response = await http.get(Uri.parse(exportUrl));
    if (response.statusCode != 200)
      throw Exception("Failed to fetch spreadsheet");

    final data = response.body;
    List<List<String>> sheet = data
        .split("\n")
        .map((row) => row.split(","))
        .toList();
    if (sheet.isEmpty || sheet[0].length < 2) return {};

    List<String> dates = sheet[0];
    List<Map<String, dynamic>> fetchedSlots = [];
    Set<String> dateSet = {"All"};
    DateTime now = DateTime.now();
    DateTime todayMidnight = DateTime(now.year, now.month, now.day);

    // Identify Weekend columns based on spreadsheet content
    Set<int> weekendIndices = {};
    for (var row in sheet) {
      for (int j = 0; j < row.length; j++) {
        if (row[j].toUpperCase().contains("WEEKEND")) weekendIndices.add(j);
      }
    }

    String todayStr = DateFormat("MMM d").format(now).replaceAll(' ', '');
    int todayCol = -1;
    for (int j = 0; j < dates.length; j++) {
      if (dates[j].trim().replaceAll(' ', '') == todayStr) {
        todayCol = j;
        break;
      }
    }

    bool isWeekend = (todayCol != -1 && weekendIndices.contains(todayCol));
    bool currentlyInLecture = false;
    String lectureName = "";

    // Check if the lecturer is currently in a session
    if (!isWeekend && todayCol != -1) {
      for (int i = 1; i < sheet.length; i++) {
        List<String> row = sheet[i];
        if (row.length < 2) continue;
        DateTime start = _parseTime(row[0], now);
        DateTime end = _parseTime(row[1], now);

        if (now.isAfter(start.subtract(const Duration(seconds: 1))) &&
            now.isBefore(end)) {
          String content = (todayCol < row.length) ? row[todayCol].trim() : "";
          if (content.isNotEmpty) {
            currentlyInLecture = true;
            lectureName = content;
          }
          break;
        }
      }
    }

    // Process all rows to find "Free" (empty) slots
    for (int i = 1; i < sheet.length; i++) {
      List<String> row = sheet[i];
      if (row.length < 2) continue;
      String startTime = row[0].trim();
      String endTime = row[1].trim();

      for (int j = 2; j < dates.length; j++) {
        String dateString = dates[j].trim();
        if (dateString.isEmpty) continue;

        bool isPastDay = false;
        try {
          String cleanDate = dateString.replaceAllMapped(
            RegExp(r'([a-zA-Z]+)(\d+)'),
            (match) => '${match.group(1)} ${match.group(2)}',
          );
          DateTime parsedDate = DateFormat("MMM d").parse(cleanDate);
          DateTime fullDate = DateTime(
            now.year,
            parsedDate.month,
            parsedDate.day,
          );
          if (fullDate.isBefore(todayMidnight)) isPastDay = true;
        } catch (e) {}

        if (isPastDay || weekendIndices.contains(j)) continue;

        String cellValue = (j < row.length) ? row[j].trim() : "";
        if (cellValue.isEmpty) {
          fetchedSlots.add({
            "date": dateString,
            "time": "$startTime - $endTime",
          });
          dateSet.add(dateString);
        }
      }
    }

    return {
      "slots": fetchedSlots,
      "dates": dateSet.toList()..sort(),
      "isWeekend": isWeekend,
      "inLecture": currentlyInLecture,
      "lectureName": lectureName,
    };
  }

  // Helper to parse "09.00 AM" style strings
  DateTime _parseTime(String timeStr, DateTime contextDate) {
    try {
      final parts = timeStr.trim().split(" ");
      final hm = parts[0].split(".");
      int hour = int.parse(hm[0]);
      int min = int.parse(hm[1]);
      if (parts[1].toUpperCase() == "PM" && hour != 12) hour += 12;
      if (parts[1].toUpperCase() == "AM" && hour == 12) hour = 0;
      return DateTime(
        contextDate.year,
        contextDate.month,
        contextDate.day,
        hour,
        min,
      );
    } catch (e) {
      return DateTime(
        contextDate.year,
        contextDate.month,
        contextDate.day,
        0,
        0,
      );
    }
  }

  Future<void> notifyStudent({
    required String studentUid,
    required String status,
    required String date,
    required String lecturerName,
  }) async {
    try {
      // 1. Save to History (Makes card appear in student's app)
      await _db.collection('users').doc(studentUid).collection('notifications').add({
        'title': 'Meeting $status!',
        'body': 'Your meeting for $date has been $status by $lecturerName.',
        'type': 'meeting',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Trigger Push Notification via HTTP v1
      DocumentSnapshot studentDoc = await _db.collection('users').doc(studentUid).get();
      String? token = studentDoc.get('fcmToken');

      if (token != null && token.isNotEmpty) {
        // A. Authenticate using the Service Account JSON
        final jsonString = await rootBundle.loadString('assets/service-account.json');
        final credentials = ServiceAccountCredentials.fromJson(jsonString);
        final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
        
        final client = await clientViaServiceAccount(credentials, scopes);
        final accessToken = client.credentials.accessToken.data;

        // B. Send the HTTP v1 Request (Using your specific Project ID)
        const String projectId = 'uniconnect-133ae'; 
        const String fcmUrl = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

        await http.post(
          Uri.parse(fcmUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'message': {  // The V1 API requires the payload to be wrapped in a 'message' object
              'token': token,
              'notification': {
                'title': 'Meeting $status!',
                'body': 'Meeting with $lecturerName on $date is $status.',
              },
            }
          }),
        );
        
        client.close(); // Clean up the connection
      }
    } catch (e) {
      debugPrint("Push Notification Error: $e");
    }
  }

 
}