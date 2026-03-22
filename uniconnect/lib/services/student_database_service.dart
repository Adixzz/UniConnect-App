import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/lecturer_model.dart';
import '../models/club_model.dart';
import '../models/faculty_module_model.dart';


class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Save Student to Firestore
  Future<void> saveUser(StudentModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print("Error saving user: $e");
      rethrow;
    }
  }

  // 2. Fetch faculties for Student
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
  // Fetch specific user data by UID
  Future<DocumentSnapshot> getUserData(String uid) {
    return _db.collection('users').doc(uid).get();
  }
}
