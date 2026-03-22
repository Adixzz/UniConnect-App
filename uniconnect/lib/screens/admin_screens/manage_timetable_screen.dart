import 'package:flutter/material.dart';
import '../../models/timetable_model.dart';
import '../../services/admin_database_service.dart';
import '../../services/notification_service.dart';
import 'timetable_form_screen.dart';

class TimetableManageScreen extends StatefulWidget {
  const TimetableManageScreen({super.key});

  @override
  State<TimetableManageScreen> createState() => _TimetableManageScreenState();
}

class _TimetableManageScreenState extends State<TimetableManageScreen> {
  final AdminDatabaseService _dbService = AdminDatabaseService();
  final NotificationService _notificationService = NotificationService();
  List<TimetableModel> _timetables = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTimetables();
  }

  Future<void> _fetchTimetables() async {
    setState(() => _isLoading = true);
    final timetables = await _dbService.getTimetables();
    setState(() {
      _timetables = timetables;
      _isLoading = false;
    });
  }

  Future<void> _notifyStudents(TimetableModel timetable) async {
    final messageController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notify Students"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sending to: ${timetable.pathway} ${timetable.degree} "
              "Year ${timetable.academicYear} Sem ${timetable.semester} "
              "${timetable.calendarYear}",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Notification message",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Send"),
          ),
        ],
      ),
    );

    if (confirm != true || messageController.text.trim().isEmpty) return;

    try {
      await _notificationService.notifyStudents(
        timetableId: timetable.timetableId,
        pathway: timetable.pathway,
        degree: timetable.degree,
        academicYear: timetable.academicYear,
        semester: timetable.semester,
        calendarYear: timetable.calendarYear,
        message: messageController.text.trim(),
      );
      if (mounted) _showSnackBar("Notification sent successfully!");
    } catch (e) {
      if (mounted) _showSnackBar("Error sending notification: $e");
    }
  }

  Future<void> _deleteTimetable(String timetableId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Timetable"),
        content: const Text(
            "Are you sure you want to delete this timetable entry?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _dbService.deleteTimetable(timetableId);
    _showSnackBar("Timetable deleted");
    _fetchTimetables();
  }

  void _showSnackBar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Timetables"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFE0E0E0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const TimetableFormScreen()),
          );
          _fetchTimetables();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Timetable"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _timetables.isEmpty
              ? const Center(
                  child: Text(
                    "No timetables yet.\nTap 'Add Timetable' to create one.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: _timetables.length,
                  itemBuilder: (context, index) {
                    final timetable = _timetables[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // timetable title
                            Text(
                              "${timetable.pathway} - ${timetable.degree}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Year ${timetable.academicYear}  |  "
                              "Semester ${timetable.semester}  |  "
                              "${timetable.calendarYear}",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            // show sheet URL truncated
                            Text(
                              timetable.sheetUrl,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.blue,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Divider(height: 20),

                            // action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // notify button
                                TextButton.icon(
                                  onPressed: () =>
                                      _notifyStudents(timetable),
                                  icon: const Icon(
                                    Icons.notifications_active,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    "Notify",
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                                // edit button
                                TextButton.icon(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TimetableFormScreen(
                                          existingTimetable: timetable,
                                        ),
                                      ),
                                    );
                                    _fetchTimetables();
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    "Edit",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                                // delete button
                                TextButton.icon(
                                  onPressed: () => _deleteTimetable(
                                      timetable.timetableId),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}