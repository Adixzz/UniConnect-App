import 'package:flutter/material.dart';
import '../../models/lecturer_model.dart';
import '../../models/admin_model.dart';
import '../../services/admin_database_service.dart';
import 'add_user_screen.dart';
import 'edit_lecturer_screen.dart';
import 'edit_admin_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _dbService = DatabaseService();
  late TabController _tabController;

  List<LecturerModel> _lecturers = [];
  List<AdminModel> _admins = [];
  bool _isLoadingLecturers = true;
  bool _isLoadingAdmins = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchLecturers();
    _fetchAdmins();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchLecturers() async {
    setState(() => _isLoadingLecturers = true);
    final lecturers = await _dbService.getLecturers();
    setState(() {
      _lecturers = lecturers;
      _isLoadingLecturers = false;
    });
  }

  Future<void> _fetchAdmins() async {
    setState(() => _isLoadingAdmins = true);
    final admins = await _dbService.getAdmins();
    setState(() {
      _admins = admins;
      _isLoadingAdmins = false;
    });
  }

  Future<void> _deleteUser({
    required String uid,
    required String name,
    required String collection,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: Text(
            "Are you sure you want to delete $name? This cannot be undone."),
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

    try {
      await _dbService.deleteUserCompletely(
        uid: uid,
        collection: collection,
      );
      _showSnackBar("$name deleted successfully");
      // refresh whichever list was affected
      if (collection == 'lecturers') {
        _fetchLecturers();
      } else {
        _fetchAdmins();
      }
    } catch (e) {
      _showSnackBar("Error deleting user: $e");
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
        title: const Text("Manage Users"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1565C0),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1565C0),
          tabs: const [
            Tab(text: "Lecturers"),
            Tab(text: "Admins"),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFE0E0E0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddUserScreen()),
          );
          // refresh both lists after adding
          _fetchLecturers();
          _fetchAdmins();
        },
        icon: const Icon(Icons.person_add),
        label: const Text("Add User"),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // lecturers tab
          _isLoadingLecturers
              ? const Center(child: CircularProgressIndicator())
              : _lecturers.isEmpty
                  ? const Center(
                      child: Text(
                        "No lecturers yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _lecturers.length,
                      itemBuilder: (context, index) {
                        final lecturer = _lecturers[index];
                        return _buildUserCard(
                          name: lecturer.name,
                          email: lecturer.email,
                          id: lecturer.staffId,
                          idLabel: "Staff ID",
                          role: "Lecturer",
                          roleColor: Colors.blue,
                          onEdit: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditLecturerScreen(
                                  lecturer: lecturer,
                                ),
                              ),
                            );
                            _fetchLecturers();
                          },
                          onDelete: () => _deleteUser(
                            uid: lecturer.uid,
                            name: lecturer.name,
                            collection: 'lecturers',
                          ),
                        );
                      },
                    ),

          // admins tab
          _isLoadingAdmins
              ? const Center(child: CircularProgressIndicator())
              : _admins.isEmpty
                  ? const Center(
                      child: Text(
                        "No admins yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _admins.length,
                      itemBuilder: (context, index) {
                        final admin = _admins[index];
                        return _buildUserCard(
                          name: admin.name,
                          email: '',
                          id: admin.uid,
                          idLabel: "Admin ID",
                          role: "Admin",
                          roleColor: Colors.purple,
                          onEdit: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditAdminScreen(
                                  admin: admin,
                                ),
                              ),
                            );
                            _fetchAdmins();
                          },
                          onDelete: () => _deleteUser(
                            uid: admin.uid,
                            name: admin.name,
                            collection: 'admins',
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required String name,
    required String email,
    required String id,
    required String idLabel,
    required String role,
    required Color roleColor,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                // role chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                        fontSize: 12, color: roleColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              "$idLabel: $id",
              style: TextStyle(
                  fontSize: 13, color: Colors.grey[600]),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit,
                      color: Colors.blue, size: 18),
                  label: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete,
                      color: Colors.red, size: 18),
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
  }
}