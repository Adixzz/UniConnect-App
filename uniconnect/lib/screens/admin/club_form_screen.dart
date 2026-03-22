import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/student_models/club_model.dart';
import '../../services/database_service.dart';

class ClubFormScreen extends StatefulWidget {
  final ClubModel? existingClub;

  const ClubFormScreen({super.key, this.existingClub});

  @override
  State<ClubFormScreen> createState() => _ClubFormScreenState();
}

class _ClubFormScreenState extends State<ClubFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _presidentController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = [
    'Academic',
    'Sports',
    'Arts',
    'Religious',
    'Social',
    'Technology',
    'Other',
  ];

  bool get _isEditing => widget.existingClub != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingClub!.name;
      _descriptionController.text = widget.existingClub!.description;
      _presidentController.text = widget.existingClub!.president;
      _selectedCategory = widget.existingClub!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _presidentController.dispose();
    super.dispose();
  }

  Future<void> _saveClub() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final president = _presidentController.text.trim();

    if (name.isEmpty || description.isEmpty || president.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (_selectedCategory == null) {
      _showSnackBar("Please select a category");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        // update existing club — keep the same clubId
        await _dbService.updateClub(ClubModel(
          clubId: widget.existingClub!.clubId,
          name: name,
          description: description,
          category: _selectedCategory!,
          president: president,
        ));
        _showSnackBar("Club updated successfully!");
      } else {
        // add new club — generate a new Firestore document ID
        final newId = FirebaseFirestore.instance.collection('clubs').doc().id;
        await _dbService.saveClub(ClubModel(
          clubId: newId,
          name: name,
          description: description,
          category: _selectedCategory!,
          president: president,
        ));
        _showSnackBar("Club added successfully!");
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title changes depending on whether adding or editing
        title: Text(_isEditing ? "Edit Club" : "Add Club"),
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
                  _buildTextField(_nameController, "Club Name", Icons.group),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _descriptionController,
                    "Description",
                    Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                      _presidentController, "President / Contact", Icons.person),
                  const SizedBox(height: 16),

                  // category dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text("Select Category"),
                        value: _selectedCategory,
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedCategory = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveClub,
                      // button label changes depending on adding or editing
                      child: Text(_isEditing ? "SAVE CHANGES" : "ADD CLUB"),
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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