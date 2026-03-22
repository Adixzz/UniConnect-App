import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

// IMPORTANT: Adjust these paths based on your merged folder structure!
import '../student/student_models/student_model.dart';
import '../student/student_models/lecturer_model.dart';
import '../student/student_models/club_model.dart';
import '../student/student_models/faculty_module_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // 1. USER & LECTURER REGISTRATION
  // ==========================================

  Future<void> saveUser(StudentModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      debugPrint("Error saving user: $e");
      rethrow;
    }
  }

  Future<void> saveLecturer(LecturerModel lecturer) async {
    try {
      await _db.collection('lecturers').doc(lecturer.uid).set(lecturer.toMap());
    } catch (e) {
      debugPrint("Error saving lecturer: $e");
      rethrow;
    }
  }

  // ==========================================
  // 2. SMART USER DATA FETCHING
  // ==========================================

  // Automatically checks if the UID belongs to a student or a lecturer!
  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      // Check students/admins first
      var userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) return userDoc;

      // If not a student, check lecturers
      return await _db.collection('lecturers').doc(uid).get();
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      rethrow;
    }
  }

  // ==========================================
  // 3. FACULTIES & MODULES
  // ==========================================

  // Used by Student Portal (Returns Models)
  Future<List<FacultyModel>> getFaculties() async {
    try {
      final snapshot = await _db.collection('faculties').get();
      return snapshot.docs.map((doc) => FacultyModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint("Error fetching faculties: $e");
      return [];
    }
  }

  // Used by Lecturer Portal (Returns Strings)
  Future<List<String>> getFacultyNames() async {
    try {
      final snapshot = await _db.collection('faculties').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      debugPrint("Error fetching faculty names: $e");
      return [];
    }
  }

  // Used by Student Portal (Returns Models)
  Future<List<ModuleModel>> getModulesByFaculty(String facultyCode) async {
    try {
      final snapshot = await _db.collection('modules')
          .where('facultyCode', isEqualTo: facultyCode)
          .get();
      return snapshot.docs.map((doc) => ModuleModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint("Error fetching modules: $e");
      return [];
    }
  }

  // Used by Lecturer Portal (Returns Strings)
  Future<List<String>> getModuleNames() async {
    try {
      final snapshot = await _db.collection('modules').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      debugPrint("Error fetching module names: $e");
      return [];
    }
  }

  // ==========================================
  // 4. CLUBS MANAGEMENT
  // ==========================================

  Future<void> saveClub(ClubModel club) async {
    try {
      await _db.collection('clubs').doc(club.clubId).set(club.toMap());
    } catch (e) {
      debugPrint("Error saving club: $e");
      rethrow;  
    }
  }

  Future<void> updateClub(ClubModel club) async {
    try {
      await _db.collection('clubs').doc(club.clubId).update({
        'name': club.name,
        'description': club.description,
        'category': club.category,
        'president': club.president,
      });
    } catch (e) {
      debugPrint("Error updating club: $e");
      rethrow;
    }
  }

  Future<void> deleteClub(String clubId) async {
    try {
      await _db.collection('clubs').doc(clubId).delete();
    } catch (e) {
      debugPrint("Error deleting club: $e");
      rethrow;
    }
  }

  Future<List<ClubModel>> getClubs() async {
    try {
      final snapshot = await _db.collection('clubs').get();
      return snapshot.docs
          .map((doc) => ClubModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint("Error fetching clubs: $e");
      return [];
    }
  }

  // ==========================================
  // 5. LECTURER SEARCH & STATUS
  // ==========================================

  // Fetch ALL Lecturers (For Global Search)
  Future<List<LecturerModel>> getAllLecturers() async {
    try {
      final snapshot = await _db.collection('lecturers').get();
      return snapshot.docs
          .map((doc) => LecturerModel.fromMap(doc.data())) 
          .toList();
    } catch (e) {
      debugPrint("Error fetching all lecturers: $e");
      return [];
    }
  }

  // Fetch Lecturers Filtered by Faculty & Module
  Future<List<LecturerModel>> getFilteredLecturers(String facultyCode, String moduleName) async {
    try {
      final snapshot = await _db.collection('lecturers')
          .where('faculty', isEqualTo: facultyCode)
          .where('modules', arrayContains: moduleName) 
          .get();
      
      return snapshot.docs
          .map((doc) => LecturerModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("Error fetching filtered lecturers: $e");
      return [];
    }
  }

  Future<String?> getLecturerDocId(String staffId) async {
    try {
      final querySnapshot = await _db
          .collection('lecturers')
          .where('staffId', isEqualTo: staffId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      debugPrint("Error finding lecturer: $e");
      return null;
    }
  }

  Future<void> updateLecturerStatus(String uid, String status) async {
    try {
      await _db.collection('lecturers').doc(uid).update({
        'availability': status,
      });
    } catch (e) {
      debugPrint("Error updating status: $e");
      rethrow;
    }
  }

  // ==========================================
  // 6. MEETING REQUESTS & SCHEDULING
  // ==========================================

  Future<void> saveMeetingRequest({
    required String studentUid,
    required String lecturerUid,
    required String lecturerName,
    required String moduleName,
    required String date,
    required String time,
    required String reason,
    required String location, 
  }) async {
    try {
      await _db.collection('meetings').add({
        'studentUid': studentUid,
        'lecturerUid': lecturerUid,
        'lecturerName': lecturerName,
        'moduleName': moduleName,
        'date': date,
        'time': time,
        'reason': reason,
        'location': location,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error saving meeting request: $e");
      rethrow;
    }
  }

  Stream<QuerySnapshot> getStudentMeetings(String studentUid) {
    return _db.collection('meetings')
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getLecturerMeetings(String lecturerUid) {
    return _db.collection('meetings')
        .where('lecturerUid', isEqualTo: lecturerUid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> cancelMeeting(String meetingId) async {
    try {
      await _db.collection('meetings').doc(meetingId).update({
        'status': 'Cancelled',
      });
    } catch (e) {
      debugPrint("Error cancelling meeting: $e");
      rethrow;
    }
  }

  Future<void> updateMeetingStatus(String meetingId, String newStatus) async {
    try {
      await _db.collection('meetings').doc(meetingId).update({
        'status': newStatus,
      });
    } catch (e) {
      debugPrint("Error updating meeting status: $e");
      rethrow;
    }
  }
}