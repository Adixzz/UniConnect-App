import 'package:firebase_auth/firebase_auth.dart';
import '../models/student_model.dart';
import '../models/lecturer_model.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Student Login
  Future<String?> loginStudent({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();
        return "Please verify your email first. Check your inbox.";
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login Failed";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // 2. Student Register
  Future<String?> registerStudent({
    required String name,
    required String email,
    required String password,
    required String studentId,
  }) async {
    if (!email.endsWith('@students.nsbm.ac.lk')) {
      return "Please use your @students.nsbm.ac.lk email";
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.sendEmailVerification();

      await DatabaseService().saveUser(StudentModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        studentId: studentId,
        role: 'student',
      ));

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Registration Failed";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // 3. Admin Register
  Future<String?> registerAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await DatabaseService().saveUser(StudentModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        studentId: '',
        role: 'admin',
      ));

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Failed to create admin";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  // 4. Lecturer Register
  Future<String?> registerLecturer(LecturerModel lecturer) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: lecturer.email,
        password: lecturer.pin,
      );

      await DatabaseService().saveLecturer(LecturerModel(
        uid: userCredential.user!.uid,
        name: lecturer.name,
        email: lecturer.email,
        staffId: lecturer.staffId,
        pin: lecturer.pin,
        faculty: lecturer.faculty,
        modules: lecturer.modules,
        role: 'lecturer',
        location: lecturer.location,
        timetableURL: lecturer.timetableURL,

      ));

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Failed to create lecturer";
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }
}