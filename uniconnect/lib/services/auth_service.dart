import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. THE LOGIN METHOD
  Future<String?> loginStudent({required String email, required String password}) async {
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

  // 2. THE REGISTER METHOD
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

      await DatabaseService().saveUser(UserModel(
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
}