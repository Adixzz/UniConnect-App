import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/student_database_service.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final StudentDatabaseService _dbService = StudentDatabaseService();
  final Color primaryGreen = const Color(0xFF10B981);

  String? _selectedPathway;
  String? _selectedDegree;
  String? _selectedAcademicYear;
  String? _selectedSemester;
  String? _selectedCalendarYear;

  List<String> _pathways = [];
  List<String> _degrees = [];

  bool _isLoading = true;
  bool _isFetchingDropdowns = false;
  bool _showForm = false;
  bool _isLaunching = false;
  String? _errorMessage;
  String? _timetableUrl; // just store the URL

  final List<String> _academicYears = ['1', '2', '3', '4'];
  final List<String> _semesters = ['1', '2'];
  final List<String> _calendarYears = ['2024', '2025', '2026', '2027'];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    final saved = await _dbService.getStudentTimetableSelection(uid);

    if (saved != null) {
      // already saved — fetch the URL directly
      await _fetchTimetableUrl(
        pathway: saved['pathway'],
        degree: saved['degree'],
        academicYear: saved['academicYear'],
        semester: saved['semester'],
        calendarYear: saved['calendarYear'],
      );
    } else {
      await _fetchDropdowns();
      setState(() {
        _showForm = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDropdowns() async {
    setState(() => _isFetchingDropdowns = true);
    final pathways = await _dbService.getPathways();
    final degrees = await _dbService.getDegrees();
    setState(() {
      _pathways = pathways;
      _degrees = degrees;
      _isFetchingDropdowns = false;
    });
  }

  Future<void> _fetchTimetableUrl({
    required String pathway,
    required String degree,
    required String academicYear,
    required String semester,
    required String calendarYear,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedPathway = pathway;
      _selectedDegree = degree;
      _selectedAcademicYear = academicYear;
      _selectedSemester = semester;
      _selectedCalendarYear = calendarYear;
    });

    final timetableId =
        "${pathway}_${degree}_Y${academicYear}_S${semester}_${calendarYear}";

    final timetable = await _dbService.getTimetableByGroupId(timetableId);

    if (timetable == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            "No timetable found for your selection.\nPlease contact your administrator.";
      });
      return;
    }

    setState(() {
      _timetableUrl = timetable['sheetUrl'] as String;
      _isLoading = false;
      _showForm = false;
    });
  }

  Future<void> _submitForm() async {
    if (_selectedPathway == null ||
        _selectedDegree == null ||
        _selectedAcademicYear == null ||
        _selectedSemester == null ||
        _selectedCalendarYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _dbService.saveStudentTimetableSelection(
      uid: uid,
      pathway: _selectedPathway!,
      degree: _selectedDegree!,
      academicYear: _selectedAcademicYear!,
      semester: _selectedSemester!,
      calendarYear: _selectedCalendarYear!,
    );

    await _fetchTimetableUrl(
      pathway: _selectedPathway!,
      degree: _selectedDegree!,
      academicYear: _selectedAcademicYear!,
      semester: _selectedSemester!,
      calendarYear: _selectedCalendarYear!,
    );
  }

  Future<void> _openTimetable() async {
    if (_timetableUrl == null) return;

    setState(() => _isLaunching = true);

    try {
      final uri = Uri.parse(_timetableUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not open timetable")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLaunching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'My Timetable',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_showForm && !_isLoading)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.black87),
              tooltip: "Change timetable group",
              onPressed: () async {
                await _fetchDropdowns();
                setState(() => _showForm = true);
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : _showForm
              ? _buildForm()
              : _errorMessage != null
                  ? _buildError()
                  : _buildTimetableCard(),
    );
  }

  // form shown on first visit
  Widget _buildForm() {
    if (_isFetchingDropdowns) {
      return Center(
          child: CircularProgressIndicator(color: primaryGreen));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10)
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryGreen.withOpacity(0.1),
                  child: Icon(Icons.calendar_today, color: primaryGreen),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Set Up Your Timetable",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "This is a one-time setup. You can change it later.",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildDropdown(
            hint: "Select Pathway",
            value: _selectedPathway,
            items: _pathways,
            icon: Icons.school_outlined,
            onChanged: (value) =>
                setState(() => _selectedPathway = value),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            hint: "Select Degree",
            value: _selectedDegree,
            items: _degrees,
            icon: Icons.book_outlined,
            onChanged: (value) =>
                setState(() => _selectedDegree = value),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            hint: "Select Academic Year",
            value: _selectedAcademicYear,
            items: _academicYears,
            icon: Icons.looks_one_outlined,
            onChanged: (value) =>
                setState(() => _selectedAcademicYear = value),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            hint: "Select Semester",
            value: _selectedSemester,
            items: _semesters,
            icon: Icons.splitscreen_outlined,
            onChanged: (value) =>
                setState(() => _selectedSemester = value),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            hint: "Select Calendar Year",
            value: _selectedCalendarYear,
            items: _calendarYears,
            icon: Icons.calendar_month_outlined,
            onChanged: (value) =>
                setState(() => _selectedCalendarYear = value),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                "VIEW MY TIMETABLE",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // timetable card with open button
  Widget _buildTimetableCard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // info card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: primaryGreen.withOpacity(0.1),
                      child: Icon(Icons.calendar_today,
                          color: primaryGreen),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Your Timetable",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _infoRow(Icons.school_outlined, "Pathway",
                    _selectedPathway ?? ''),
                const SizedBox(height: 8),
                _infoRow(Icons.book_outlined, "Degree",
                    _selectedDegree ?? ''),
                const SizedBox(height: 8),
                _infoRow(Icons.looks_one_outlined, "Academic Year",
                    "Year $_selectedAcademicYear"),
                const SizedBox(height: 8),
                _infoRow(Icons.splitscreen_outlined, "Semester",
                    "Semester $_selectedSemester"),
                const SizedBox(height: 8),
                _infoRow(Icons.calendar_month_outlined, "Calendar Year",
                    _selectedCalendarYear ?? ''),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // open timetable button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLaunching ? null : _openTimetable,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isLaunching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.open_in_browser,
                      color: Colors.white),
              label: Text(
                _isLaunching ? "Opening..." : "OPEN TIMETABLE",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // note about browser
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.orange.shade700, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Your timetable will open in your browser. "
                    "You may need to sign in with your university account.",
                    style:
                        TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // error state
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await _fetchDropdowns();
                setState(() {
                  _showForm = true;
                  _errorMessage = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Try Again",
                style: TextStyle(color: Colors.white),
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
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(hint,
                    style: const TextStyle(color: Colors.grey)),
                value: value,
                items: items.map((item) {
                  return DropdownMenuItem(
                      value: item, child: Text(item));
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}