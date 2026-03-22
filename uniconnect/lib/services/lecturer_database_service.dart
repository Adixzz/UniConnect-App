import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../student/student_models/student_model.dart';
import '../../models/lecturer_model.dart';
import '../../student/student_models/club_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  // Fetch lecturer or user data by UID
  Future<DocumentSnapshot> getUserData(String uid) {
    return _db.collection('lecturers').doc(uid).get();
  }
}
