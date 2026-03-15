import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';
import '../models/lecturer_model.dart';

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
}