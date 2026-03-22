import 'package:flutter/material.dart';
import '../../models/timetable_model.dart';
import '../../services/database_service.dart';

class TimetableFormScreen extends StatefulWidget {
  final TimetableModel? existingTimetable;

  const TimetableFormScreen({super.key, this.existingTimetable});

  @override
  State<TimetableFormScreen> createState() => _TimetableFormScreenState();
}

class _TimetableFormScreenState extends State<TimetableFormScreen> {
  final _sheetUrlController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  String? _selectedPathway;
  String? _selectedDegree;
  String? _selectedAcademicYear;
  String? _selectedSemester;
  String? _selectedCalendarYear;

  List<String> _pathways = [];
  List<String> _degrees = [];
  bool _isLoading = false;
  bool _isFetchingData = true;

  final List<String> _academicYears = ['1', '2', '3', '4'];
  final List<String> _semesters = ['1', '2'];
  final List<String> _calendarYears = ['2024', '2025', '2026', '2027'];

  bool get _isEditing => widget.existingTimetable != null;

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
    if (_isEditing) {
      _sheetUrlController.text = widget.existingTimetable!.sheetUrl;
      _selectedPathway = widget.existingTimetable!.pathway;
      _selectedDegree = widget.existingTimetable!.degree;
      _selectedAcademicYear = widget.existingTimetable!.academicYear;
      _selectedSemester = widget.existingTimetable!.semester;
      _selectedCalendarYear = widget.existingTimetable!.calendarYear;
    }
  }

  Future<void> _fetchDropdownData() async {
    final pathways = await _dbService.getPathways();
    final degrees = await _dbService.getDegrees();
    setState(() {
      _pathways = pathways;
      _degrees = degrees;
      _isFetchingData = false;
    });
  }

  String get _timetableId =>
      "${_selectedPathway}_${_selectedDegree}_Y${_selectedAcademicYear}"
      "_S${_selectedSemester}_${_selectedCalendarYear}";

  Future<void> _saveTimetable() async {
    final sheetUrl = _sheetUrlController.text.trim();

    if (_selectedPathway == null ||
        _selectedDegree == null ||
        _selectedAcademicYear == null ||
        _selectedSemester == null ||
        _selectedCalendarYear == null) {
      _showSnackBar("Please select all fields");
      return;
    }

    if (sheetUrl.isEmpty) {
      _showSnackBar("Please enter the Google Sheet URL");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final timetable = TimetableModel(
        timetableId: _isEditing
            ? widget.existingTimetable!.timetableId
            : _timetableId,
        pathway: _selectedPathway!,
        degree: _selectedDegree!,
        academicYear: _selectedAcademicYear!,
        semester: _selectedSemester!,
        calendarYear: _selectedCalendarYear!,
        sheetUrl: sheetUrl,
      );

      await _dbService.saveTimetable(timetable);

      if (mounted) {
        _showSnackBar(_isEditing
            ? "Timetable updated successfully!"
            : "Timetable added successfully!");
        Navigator.pop(context);
      }
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
  void dispose() {
    _sheetUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Timetable" : "Add Timetable"),
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
                  _buildDropdown(
                    hint: "Select Pathway",
                    value: _selectedPathway,
                    items: _pathways,
                    onChanged: (value) =>
                        setState(() => _selectedPathway = value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    hint: "Select Degree",
                    value: _selectedDegree,
                    items: _degrees,
                    onChanged: (value) =>
                        setState(() => _selectedDegree = value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    hint: "Select Academic Year",
                    value: _selectedAcademicYear,
                    items: _academicYears,
                    onChanged: (value) =>
                        setState(() => _selectedAcademicYear = value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    hint: "Select Semester",
                    value: _selectedSemester,
                    items: _semesters,
                    onChanged: (value) =>
                        setState(() => _selectedSemester = value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    hint: "Select Calendar Year",
                    value: _selectedCalendarYear,
                    items: _calendarYears,
                    onChanged: (value) =>
                        setState(() => _selectedCalendarYear = value),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _sheetUrlController,
                    decoration: const InputDecoration(
                      labelText: "Google Sheet URL",
                      prefixIcon: Icon(Icons.link),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "https://docs.google.com/spreadsheets/...",
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Make sure the Google Sheet is set to "
                            "'Anyone with the link can view'",
                            style: TextStyle(
                                fontSize: 12, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveTimetable,
                      child: Text(
                          _isEditing ? "SAVE CHANGES" : "ADD TIMETABLE"),
                    ),
                  ),
                ],
              ),
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