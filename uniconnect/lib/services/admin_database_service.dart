import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/student_model.dart';
import '../models/lecturer_model.dart';
import '../models/club_model.dart';
import '../models/timetable_model.dart';
import '../models/admin_model.dart';

class AdminDatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


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

  // 9. Search student by their student ID
  Future<Map<String, dynamic>?> getStudentById(String studentId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('studentId', isEqualTo: studentId)
          .where('role', isEqualTo: 'student')
          .get();
      if (snapshot.docs.isNotEmpty) {
        return {
          'uid': snapshot.docs.first.id,
          'name': snapshot.docs.first.data()['name'],
          'studentId': snapshot.docs.first.data()['studentId'],
        };
      }
      return null;
    } catch (e) {
      print("Error searching student: $e");
      return null;
    }
  }

  // 10. Save new timetable entry to Firestore
  Future<void> saveTimetable(TimetableModel timetable) async {
    try {
      await _db
          .collection('timetables')
          .doc(timetable.timetableId)
          .set(timetable.toMap());
    } catch (e) {
      print("Error saving timetable: $e");
      rethrow;
    }
  }

  // 11. Fetch all timetables from Firestore
  Future<List<TimetableModel>> getTimetables() async {
    try {
      final snapshot = await _db.collection('timetables').get();
      return snapshot.docs
          .map((doc) => TimetableModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching timetables: $e");
      return [];
    }
  }

  // 12. Fetch a specific timetable by its ID
  Future<TimetableModel?> getTimetableById(String timetableId) async {
  try {
    final doc =
        await _db.collection('timetables').doc(timetableId).get();
    if (doc.exists) {
      return TimetableModel.fromMap(doc.id, doc.data()!);
    }
    return null;
    } catch (e) {
      print("Error fetching timetable: $e");
      return null;
    }
  }

  // 13. Delete timetable from Firestore
  Future<void> deleteTimetable(String timetableId) async {
    try {
      await _db.collection('timetables').doc(timetableId).delete();
    } catch (e) {
      print("Error deleting timetable: $e");
      rethrow;
    }
  }

  // 14. Fetch all pathways from Firestore
  Future<List<String>> getPathways() async {
    try {
      final snapshot = await _db.collection('pathways').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print("Error fetching pathways: $e");
      return [];
    }
  }

  // 15. Fetch all degrees from Firestore
  Future<List<String>> getDegrees() async {
    try {
      final snapshot = await _db.collection('degrees').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print("Error fetching degrees: $e");
      return [];
    }
  }

  // 16. Save student timetable selection to their profile
  Future<void> saveStudentTimetableSelection({
    required String uid,
    required String pathway,
    required String degree,
    required String academicYear,
    required String semester,
    required String calendarYear,
  }) async {
    try {
      await _db.collection('users').doc(uid).update({
        'pathway': pathway,
        'degree': degree,
        'academicYear': academicYear,
        'semester': semester,
        'calendarYear': calendarYear,
      });
    } catch (e) {
      print("Error saving timetable selection: $e");
      rethrow;
    }
  }

  // 17. Fetch student's saved timetable selection
  Future<Map<String, dynamic>?> getStudentTimetableSelection(
      String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null && data.containsKey('pathway')) {
        return {
          'pathway': data['pathway'],
          'degree': data['degree'],
          'academicYear': data['academicYear'],
          'semester': data['semester'],
          'calendarYear': data['calendarYear'],
        };
      }
      return null;
    } catch (e) {
      print("Error fetching student timetable selection: $e");
      return null;
    }
  }

  // 19. Fetch all lecturers
  Future<List<LecturerModel>> getLecturers() async {
    try {
      final snapshot = await _db
          .collection('lecturers')
          .get();
      return snapshot.docs
          .map((doc) => LecturerModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching lecturers: $e");
      return [];
    }
  }

  // 20. Fetch all admins
  Future<List<AdminModel>> getAdmins() async {
  try {
    final snapshot = await _db.collection('admins').get();
    return snapshot.docs
        .map((doc) => AdminModel.fromMap(doc.id, doc.data()))
        .toList();
    } catch (e) {
      print("Error fetching admins: $e");
      return [];
    }
  }

  // 21. Delete user from both Firebase Auth and Firestore
  Future<void> deleteUserCompletely({
    required String uid,
    required String collection,
  }) async {
    try {
      // delete from Firestore first
      await _db.collection(collection).doc(uid).delete();

      // then delete from Firebase Auth via Cloud Function
      final callable = FirebaseFunctions.instance
          .httpsCallable('deleteUser');
      await callable.call({'uid': uid});
    } catch (e) {
      print("Error deleting user: $e");
      rethrow;
    }
  }

  // 22. Update lecturer in Firestore
  Future<void> updateLecturer(LecturerModel lecturer) async {
    try {
      await _db
          .collection('lecturers')
          .doc(lecturer.uid)
          .update(lecturer.toMap());
    } catch (e) {
      print("Error updating lecturer: $e");
      rethrow;
    }
  }

  // 23. Update admin in Firestore
  Future<void> updateAdmin(AdminModel admin) async {
  try {
    await _db
        .collection('admins')
        .doc(admin.uid)
        .update(admin.toMap());
    } catch (e) {
      print("Error updating admin: $e");
      rethrow;
    }
  }
}
