import 'package:flutter/material.dart';
import '../../models/admin_model.dart';
import '../../services/database_service.dart';

class EditAdminScreen extends StatefulWidget {
  final AdminModel admin;
  const EditAdminScreen({super.key, required this.admin});

  @override
  State<EditAdminScreen> createState() => _EditAdminScreenState();
}

class _EditAdminScreenState extends State<EditAdminScreen> {
  final _nameController = TextEditingController();
  final _adminIdController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.admin.name;
    _adminIdController.text = widget.admin.adminId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _adminIdController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    final adminId = _adminIdController.text.trim();

    if (name.isEmpty || adminId.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _dbService.updateAdmin(AdminModel(
        uid: widget.admin.uid,
        name: name,
        adminId: adminId,
        createdAt: widget.admin.createdAt,
      ));

      _showSnackBar("Admin updated successfully!");
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text("Edit Admin"),
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
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _adminIdController,
                    decoration: const InputDecoration(
                      labelText: "Admin ID",
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text("SAVE CHANGES"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}