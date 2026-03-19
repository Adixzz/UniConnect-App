import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint("Error saving user: $e");
      rethrow;
    }
  }

  // 2. Save Lecturer to Firestore
  Future<void> saveLecturer(LecturerModel lecturer) async {
    try {
      await _db.collection('lecturers').doc(lecturer.uid).set(lecturer.toMap());
    } catch (e) {
      debugPrint("Error saving lecturer: $e");
      rethrow;
    }
  }

  // 3. Fetch all faculties from Firestore
  Future<List<String>> getFaculties() async {
    try {
      final snapshot = await _db.collection('faculties').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      debugPrint("Error fetching faculties: $e");
      return [];
    }
  }

  // 4. Fetch all modules from Firestore
  Future<List<String>> getModules() async {
    try {
      final snapshot = await _db.collection('modules').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      debugPrint("Error fetching modules: $e");
      return [];
    }
  }

  // 5. Save a new club to Firestore
  Future<void> saveClub(ClubModel club) async {
    try {
      await _db.collection('clubs').doc(club.clubId).set(club.toMap());
    } catch (e) {
      debugPrint("Error saving club: $e");
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
      debugPrint("Error updating club: $e");
      rethrow;
    }
  }

  // 7. Delete club from Firestore
  Future<void> deleteClub(String clubId) async {
    try {
      await _db.collection('clubs').doc(clubId).delete();
    } catch (e) {
      debugPrint("Error deleting club: $e");
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
      debugPrint("Error fetching clubs: $e");
      return [];
    }
  }

  // Update master availability status
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

  // Fetch lecturer or user data by UID
  Future<DocumentSnapshot> getUserData(String uid) {
    return _db.collection('lecturers').doc(uid).get();
  }

  // FIXED: Using 'isEqualTo:' instead of positional arguments
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
}
