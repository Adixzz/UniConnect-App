import 'package:cloud_firestore/cloud_firestore.dart';
import '../../student/student_models/student_model.dart';
import '../../student/student_models/lecturer_model.dart';
import '../../student/student_models/club_model.dart';
import '../../student/student_models/faculty_module_model.dart';


class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Save Student/Admin to Firestore
  Future<void> saveUser(StudentModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print("Error saving user: $e");
      rethrow;
    }
  }

  // 2. Save Lecturer to Firestore
  Future<void> saveLecturer(LecturerModel lecturer) async {
    try {
      await _db.collection('lecturers').doc(lecturer.uid).set(lecturer.toMap());
    } catch (e) {
      print("Error saving lecturer: $e");
      rethrow;
    }
  }

  Future<List<FacultyModel>> getFaculties() async {
    try {
      final snapshot = await _db.collection('faculties').get();
      return snapshot.docs.map((doc) => FacultyModel.fromMap(doc.data())).toList();
    } catch (e) {
      print("Error fetching faculties: $e");
      return [];
    }
  }

  // 4. Fetch modules linked to a specific faculty
  Future<List<ModuleModel>> getModulesByFaculty(String facultyCode) async {
    try {
      final snapshot = await _db.collection('modules')
          .where('facultyCode', isEqualTo: facultyCode)
          .get();
      return snapshot.docs.map((doc) => ModuleModel.fromMap(doc.data())).toList();
    } catch (e) {
      print("Error fetching modules: $e");
      return [];
    }
  }

  // 5. Save a new club to Firestore
  Future<void> saveClub(ClubModel club) async {
    try {
      await _db.collection('clubs').doc(club.clubId).set(club.toMap());
    } catch (e) {
      print("Error saving club: $e");
      rethrow;  
    }
  }

  // 6. Update existing club in Firestore
  Future<void> updateClub(ClubModel club) async {
    try {
      await _db.collection('clubs').doc(club.clubId).update({
        'name': club.name,
        'description': club.description,
        'category': club.category,
        'president': club.president,
      });
    } catch (e) {
      print("Error updating club: $e");
      rethrow;
    }
  }

  // 7. Delete club from Firestore
  Future<void> deleteClub(String clubId) async {
    try {
      await _db.collection('clubs').doc(clubId).delete();
    } catch (e) {
      print("Error deleting club: $e");
      rethrow;
    }
  }

  // 8. Fetch all clubs from Firestore
  Future<List<ClubModel>> getClubs() async {
    try {
      final snapshot = await _db.collection('clubs').get();
      return snapshot.docs
          .map((doc) => ClubModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching clubs: $e");
      return [];
    }
  }

  // 9. Fetch ALL Lecturers (For Global Search)
  Future<List<LecturerModel>> getAllLecturers() async {
    try {
      final snapshot = await _db.collection('lecturers').get();
      return snapshot.docs
          .map((doc) => LecturerModel.fromMap(doc.data())) // Ensure you have a fromMap in LecturerModel
          .toList();
    } catch (e) {
      print("Error fetching all lecturers: $e");
      return [];
    }
  }

  // 10. Fetch Lecturers Filtered by Faculty & Module (Academic Path)
  Future<List<LecturerModel>> getFilteredLecturers(String facultyCode, String moduleName) async {
    try {
      final snapshot = await _db.collection('lecturers')
          .where('faculty', isEqualTo: facultyCode)
          .where('modules', arrayContains: moduleName) // This works because your model uses a List<String>
          .get();
      
      return snapshot.docs
          .map((doc) => LecturerModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching filtered lecturers: $e");
      return [];
    }
  }

// 11. Save Meeting Request
  // We've added the 'location' parameter to make it dynamic
  Future<void> saveMeetingRequest({
    required String studentUid,
    required String lecturerUid,
    required String lecturerName,
    required String moduleName,
    required String date,
    required String time,
    required String reason,
    required String location, // <--- Add this new parameter
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
        'location': location, // <--- Save the dynamic location here
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving meeting request: $e");
      rethrow;
    }
  }
  // 12. Stream Meetings for the Student
  Stream<QuerySnapshot> getStudentMeetings(String studentUid) {
    return _db.collection('meetings')
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 13. Cancel a meeting request (Student Side)
  Future<void> cancelMeeting(String meetingId) async {
    try {
      await _db.collection('meetings').doc(meetingId).update({
        'status': 'Cancelled',
      });
    } catch (e) {
      print("Error cancelling meeting: $e");
      rethrow;
    }
  }

  // 14. NEW: Stream Meetings for the Lecturer
  // This will show the lecturer all requests sent to them
  Stream<QuerySnapshot> getLecturerMeetings(String lecturerUid) {
    return _db.collection('meetings')
        .where('lecturerUid', isEqualTo: lecturerUid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 15. NEW: Update Meeting Status (Lecturer Side)
  // Used for 'Accepted', 'Declined', or 'Completed'
  Future<void> updateMeetingStatus(String meetingId, String newStatus) async {
    try {
      await _db.collection('meetings').doc(meetingId).update({
        'status': newStatus,
      });
    } catch (e) {
      print("Error updating meeting status: $e");
      rethrow;
    }
  }

  // Fetch specific user data by UID
Future<DocumentSnapshot> getUserData(String uid) {
  return _db.collection('users').doc(uid).get();
}
}
