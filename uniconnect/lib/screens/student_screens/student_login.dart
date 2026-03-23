import 'package:flutter/material.dart';
import 'package:uniconnect/screens/student_screens/student_main_nav.dart';
import 'student_register.dart';
import '../../services/auth_service.dart';
import 'student_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';          // ADD
import 'package:firebase_messaging/firebase_messaging.dart'; // ADD
import '../../services/student_database_service.dart';       // ADD

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  // ADD THIS METHOD
  Future<void> _initializeNotifications() async {
    try {
      NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            await StudentDatabaseService().saveFcmToken(uid, token);
            print("FCM token saved successfully");
          }
        }
      }
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    String? errorMessage = await _authService.loginStudent(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted) setState(() => _isLoading = false);

    if (errorMessage == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'student');

      await _initializeNotifications(); // ADD THIS

      _showSnackBar("Login Successful!");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const StudentMainNavigation()),
        );
      }
    } else {
      _showSnackBar(errorMessage);
    }
  }

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1565C0);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 80, color: primaryColor),
                  const SizedBox(height: 20),
                  const Text(
                    "Student Login",
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      onPressed: _login,
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentRegisterScreen(),
                      ),
                    ),
                    child: const Text("Don't have an account? Register"),
                  ),
                ],
              ),
            ),
    );
  }
}