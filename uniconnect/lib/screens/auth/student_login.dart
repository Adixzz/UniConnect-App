import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'student_register.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // THE CHECK: Only let them in if they verified their email
      if (!userCredential.user!.emailVerified) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        _showSnackBar("Please verify your email first. Check your inbox.");
        return;
      }

      // If verified, navigate to your Dashboard/Home here
      _showSnackBar("Login Successful!");
      
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Login Failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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
                const Text("Student Login", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    onPressed: _login,
                    child: const Text("LOGIN", style: TextStyle(color: Colors.white)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentRegisterScreen())),
                  child: const Text("Don't have an account? Register"),
                ),
              ],
            ),
          ),
    );
  }
}