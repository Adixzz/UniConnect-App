import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // REQUIRED
import '../../models/user_model.dart';           // Path to your model
import '../../services/database_service.dart';  // Path to your database service

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _studentIdController = TextEditingController(); 
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _registerStudent() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final studentId = _studentIdController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || studentId.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (!email.endsWith('@students.nsbm.ac.lk')) {
      _showSnackBar("Please use your @students.nsbm.ac.lk email");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Create the account in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Send the Firebase Verification Link
      await userCredential.user?.sendEmailVerification();

      // 3. Save profile to Firestore using your DatabaseService
      await DatabaseService().saveUser(UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        studentId: studentId,
        role: 'student',
      ));

      if (!mounted) return;

      _showSnackBar("Verification email sent! Check your inbox.");
      Navigator.pop(context); // Go back to login screen

    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Registration Failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Registration")),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: _studentIdController, decoration: const InputDecoration(labelText: "Student ID", border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: _emailController, decoration: const InputDecoration(labelText: "University Email", border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder())),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity, 
                    height: 50,
                    child: ElevatedButton(onPressed: _registerStudent, child: const Text("CREATE ACCOUNT")),
                  ),
                ],
              ),
            ),
    );
  }
}