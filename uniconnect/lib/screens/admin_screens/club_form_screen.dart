import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/club_model.dart';
import '../../services/admin_database_service.dart';

class ClubFormScreen extends StatefulWidget {
  final ClubModel? existingClub;

  const ClubFormScreen({super.key, this.existingClub});

  @override
  State<ClubFormScreen> createState() => _ClubFormScreenState();
}

class _ClubFormScreenState extends State<ClubFormScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _studentIdSearchController = TextEditingController(); // for searching
  final AdminDatabaseService _dbService = AdminDatabaseService();

  String? _selectedCategory;
  String? _presidentUid;    // set after search, not typed manually
  String? _presidentName;   // set after search, not typed manually
  bool _isLoading = false;
  bool _isSearching = false;

  final List<String> _categories = [
    'Academic', 'Sports', 'Arts', 'Religious', 'Social', 'Technology', 'Other',
  ];

  bool get _isEditing => widget.existingClub != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingClub!.name;
      _descriptionController.text = widget.existingClub!.description;
      _selectedCategory = widget.existingClub!.category;
      // pre-fill president info from existing club
      _presidentUid = widget.existingClub!.presidentID;
      _presidentName = widget.existingClub!.president;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _studentIdSearchController.dispose();
    super.dispose();
  }

  Future<void> _searchStudent() async {
    final studentId = _studentIdSearchController.text.trim();
    if (studentId.isEmpty) {
      _showSnackBar("Please enter a student ID");
      return;
    }

    setState(() => _isSearching = true);
    final student = await _dbService.getStudentById(studentId);
    setState(() => _isSearching = false);

    if (student == null) {
      _showSnackBar("No student found with ID: $studentId");
      return;
    }

    // store the found student's uid and name
    setState(() {
      _presidentUid = student['uid'];
      _presidentName = student['name'];
    });
    _showSnackBar("Found: ${student['name']}");
  }

  Future<void> _saveClub() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (_selectedCategory == null) {
      _showSnackBar("Please select a category");
      return;
    }

    if (_presidentUid == null) {
      _showSnackBar("Please search and select a president");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        await _dbService.updateClub(ClubModel(
          clubId: widget.existingClub!.clubId,
          name: name,
          description: description,
          category: _selectedCategory!,
          president: _presidentName!,
          presidentID: _presidentUid!,
          members: widget.existingClub!.members,
          pendingRequests: widget.existingClub!.pendingRequests,
          requestReasons: widget.existingClub!.requestReasons,
        ));
        _showSnackBar("Club updated successfully!");
      } else {
        final newId =
            FirebaseFirestore.instance.collection('clubs').doc().id;
        await _dbService.saveClub(ClubModel(
          clubId: newId,
          name: name,
          description: description,
          category: _selectedCategory!,
          president: _presidentName!,
          presidentID: _presidentUid!,
          members: [],
          pendingRequests: [],
          requestReasons: {},
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 16),
                  const Text(
                    "Club President",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _studentIdSearchController,
                          decoration: const InputDecoration(
                            labelText: "Search by Student ID",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _isSearching
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _searchStudent,
                              child: const Text("Search"),
                            ),
                    ],
                  ),

                  if (_presidentUid != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            "President: $_presidentName",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveClub,
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