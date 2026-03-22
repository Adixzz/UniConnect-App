import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/student_model.dart';
import '../models/lecturer_model.dart';
import '../models/club_model.dart';
import '../models/timetable_model.dart';
import '../models/admin_model.dart';

class MainDatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  // 1. Save FCM token to student's Firestore document
  Future<void> saveFcmToken(String uid, String token) async {
    try {
      await _db.collection('users').doc(uid).update({
        'fcmToken': token,
      });
    } catch (e) {
      print("Error saving FCM token: $e");
      rethrow;
    }
  }

  // 2. Save Student to Firestore
  Future<void> saveStudent(StudentModel student) async {
    try {
      await _db.collection('users').doc(student.uid).set(student.toMap());
    } catch (e) {
      print("Error saving student: $e");
      rethrow;
    }
  }

  // 1. Save Admin to Firestore
  Future<void> saveAdmin(AdminModel admin) async {
    try {
      await _db.collection('admins').doc(admin.uid).set(admin.toMap());
    } catch (e) {
      print("Error saving admin: $e");
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
}