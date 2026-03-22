import 'package:flutter/material.dart';
import '../../models/lecturer_model.dart';
import '../../services/admin_database_service.dart';

class EditLecturerScreen extends StatefulWidget {
  final LecturerModel lecturer;
  const EditLecturerScreen({super.key, required this.lecturer});

  @override
  State<EditLecturerScreen> createState() => _EditLecturerScreenState();
}

class _EditLecturerScreenState extends State<EditLecturerScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _staffIdController = TextEditingController();
  final _locationController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  String? _selectedFaculty;
  List<String> _faculties = [];
  List<String> _allModules = [];
  List<String> _selectedModules = [];
  String? _selectedModule;
  bool _isLoading = false;
  bool _isFetchingData = true;

  @override
  void initState() {
    super.initState();
    // pre-fill fields with existing lecturer data
    _nameController.text = widget.lecturer.name;
    _emailController.text = widget.lecturer.email;
    _staffIdController.text = widget.lecturer.staffId;
    _locationController.text = widget.lecturer.location;
    _selectedFaculty = widget.lecturer.faculty;
    _selectedModules = List.from(widget.lecturer.modules);
    _fetchDropdownData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _staffIdController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _fetchDropdownData() async {
    final faculties = await _dbService.getFaculties();
    final modules = await _dbService.getModules();
    setState(() {
      _faculties = faculties;
      _allModules = modules;
      _isFetchingData = false;
    });
  }

  void _addModule() {
    if (_selectedModule == null) return;
    if (_selectedModules.contains(_selectedModule)) {
      _showSnackBar("Module already added");
      return;
    }
    setState(() {
      _selectedModules.add(_selectedModule!);
      _selectedModule = null;
    });
  }

  void _removeModule(String module) {
    setState(() => _selectedModules.remove(module));
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final staffId = _staffIdController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty || email.isEmpty ||
        staffId.isEmpty || location.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (_selectedFaculty == null) {
      _showSnackBar("Please select a faculty");
      return;
    }

    if (_selectedModules.isEmpty) {
      _showSnackBar("Please add at least one module");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _dbService.updateLecturer(LecturerModel(
        uid: widget.lecturer.uid,
        name: name,
        email: email,
        staffId: staffId,
        pin: widget.lecturer.pin,
        faculty: _selectedFaculty!,
        modules: _selectedModules,
        location: location,
        availability: widget.lecturer.availability,
        timetableURL: widget.lecturer.timetableURL,
      ));

      _showSnackBar("Lecturer updated successfully!");
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
        title: const Text("Edit Lecturer"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFE0E0E0),
      body: _isLoading || _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                      _nameController, "Full Name", Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(
                      _staffIdController, "Staff ID", Icons.badge),
                  const SizedBox(height: 16),
                  _buildTextField(
                      _emailController, "Email", Icons.email),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _locationController,
                    "Location",
                    Icons.location_on,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    hint: "Select Faculty",
                    value: _selectedFaculty,
                    items: _faculties,
                    onChanged: (value) =>
                        setState(() => _selectedFaculty = value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          hint: "Select Module",
                          value: _selectedModule,
                          items: _allModules,
                          onChanged: (value) =>
                              setState(() => _selectedModule = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _addModule,
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedModules.isNotEmpty) ...[
                    const Text(
                      "Modules:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedModules.map((module) {
                        return Chip(
                          label: Text(module),
                          backgroundColor:
                              Colors.blue.withOpacity(0.1),
                          deleteIcon:
                              const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeModule(module),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SizedBox(height: 16),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint),
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
                value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}