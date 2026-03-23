import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/admin_database_service.dart';
import '../../models/lecturer_model.dart';

class AddLecturerScreen extends StatefulWidget {
  const AddLecturerScreen({super.key});

  @override
  State<AddLecturerScreen> createState() => _AddLecturerScreenState();
}

class _AddLecturerScreenState extends State<AddLecturerScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _staffIdController = TextEditingController();
  final _pinController = TextEditingController();
  final _locationController = TextEditingController();
  final AuthService _authService = AuthService();
  final AdminDatabaseService _dbService = AdminDatabaseService();

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
    _fetchDropdownData();
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

  Future<void> _addLecturer() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final staffId = _staffIdController.text.trim();
    final pin = _pinController.text.trim();
    final location = _locationController.text.trim();

    if (name.isEmpty || email.isEmpty || staffId.isEmpty || 
        pin.isEmpty || location.isEmpty) {
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

    final lecturer = LecturerModel(
      uid: '',
      name: name,
      email: email,
      staffId: staffId,
      pin: pin,
      faculty: _selectedFaculty!,
      modules: _selectedModules,
      location: location,
      timetableURL: '',
    );

    String? errorMessage = await _authService.registerLecturer(lecturer);

    if (mounted) setState(() => _isLoading = false);

    if (errorMessage == null) {
      _showSnackBar("Lecturer added successfully!");
      if (mounted) Navigator.pop(context);
    } else {
      _showSnackBar(errorMessage);
    }
  }

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _staffIdController.dispose();
    _pinController.dispose();
    _locationController.dispose(); // ADDED
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Lecturer"),
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
                  _buildTextField(_nameController, "Full Name", Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(_staffIdController, "Staff ID", Icons.badge),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, "Email", Icons.email),
                  const SizedBox(height: 16),
                  _buildTextField(_pinController, "Access Pin", Icons.lock,
                      obscure: true),
                  const SizedBox(height: 16),
                  // ADDED — location field
                  _buildTextField(
                    _locationController,
                    "Location (e.g. Block A, Room 201)",
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
                      "Added Modules:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedModules.map((module) {
                        return Chip(
                          label: Text(module),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          deleteIcon: const Icon(Icons.close, size: 18),
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
                      onPressed: _addLecturer,
                      child: const Text("ADD LECTURER"),
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
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}