import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/lecturer_model.dart';
import '../models/club_model.dart';

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

  // 3. Fetch all faculties from Firestore
  Future<List<String>> getFaculties() async {
    try {
      final snapshot = await _db.collection('faculties').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print("Error fetching faculties: $e");
      return [];
    }
  }

  // 4. Fetch all modules from Firestore
  Future<List<String>> getModules() async {
    try {
      final snapshot = await _db.collection('modules').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
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
  // I recommend creating a MeetingModel, but for now, we'll use a Map
  Future<void> saveMeetingRequest({
    required String studentUid,
    required String lecturerUid,
    required String lecturerName,
    required String moduleName,
    required String date,
    required String time,
    required String reason,
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
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving meeting request: $e");
      rethrow;
    }
  }

  // 12. Stream Meetings for the Student (Real-time updates for your UI)
  Stream<QuerySnapshot> getStudentMeetings(String studentUid) {
    return _db.collection('meetings')
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
