import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AddAdminScreen extends StatefulWidget {
  const AddAdminScreen({super.key});

  @override
  State<AddAdminScreen> createState() => _AddAdminScreenState();
}

class _AddAdminScreenState extends State<AddAdminScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _adminIdController = TextEditingController(); // ADDED
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _adminIdController.dispose(); // ADDED
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _addAdmin() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final adminId = _adminIdController.text.trim(); // ADDED
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty ||
        adminId.isEmpty || password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    String? errorMessage = await _authService.registerAdmin(
      name: name,
      email: email,
      password: password,
      adminId: adminId, // ADDED
    );

    if (mounted) setState(() => _isLoading = false);

    if (errorMessage == null) {
      _showSnackBar("Admin created successfully!");
      if (mounted) Navigator.pop(context);
    } else {
      _showSnackBar(errorMessage);
    }
  }

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Admin"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFE0E0E0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildTextField(
                      _nameController, "Full Name", Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(
                      _emailController, "Email", Icons.email),
                  const SizedBox(height: 16),
                  _buildTextField(
                      _adminIdController, "Admin ID", Icons.badge), // ADDED
                  const SizedBox(height: 16),
                  _buildTextField(
                    _passwordController,
                    "Password",
                    Icons.lock,
                    obscure: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _confirmPasswordController,
                    "Confirm Password",
                    Icons.lock_outline,
                    obscure: true,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _addAdmin,
                      child: const Text("CREATE ADMIN"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}