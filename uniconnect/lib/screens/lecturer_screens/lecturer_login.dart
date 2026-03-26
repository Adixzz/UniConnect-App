import 'package:flutter/material.dart';
import 'package:uniconnect/screens/lecturer_screens/lecturer_main_nav.dart';
import 'package:uniconnect/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniconnect/models/lecturer_model.dart';

class LecturerLoginScreen extends StatefulWidget {
  const LecturerLoginScreen({super.key});

  @override
  State<LecturerLoginScreen> createState() => _LecturerLoginScreenState();
}

class _LecturerLoginScreenState extends State<LecturerLoginScreen> {
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _staffIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validate inputs
    String staffId = _staffIdController.text.trim();
    String pin = _pinController.text.trim();

    if (staffId.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both Staff ID and Access Pin'),
        ),
      );
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    var result = await _authService.loginLecturer(staffId: staffId, pin: pin);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    // Handle the result
    if (result is LecturerModel) {
      // Login successful!
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'lecturer');
      if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login Successful!'))
    );

    // 2. Navigate to Lecturer Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LecturerMainNavigation(lecturerUid: result.uid),
      ),
    );
  }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1565C0);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        // Added to prevent overflow when keyboard appears
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.badge_rounded, size: 80, color: primaryColor),
            const SizedBox(height: 20),
            const Text(
              "Lecturer Portal",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _staffIdController,
              decoration: InputDecoration(
                labelText: 'Staff ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number, 
              decoration: InputDecoration(
                labelText: 'Access Pin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Disable button while loading
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: primaryColor,
                        ),
                      )
                    : const Text(
                        "VERIFY & ENTER",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
