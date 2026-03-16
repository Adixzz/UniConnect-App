class Faculty {
  final String name; // Matches LecturerModel.faculty (e.g., "FOC")
  final String fullName; // e.g., "Faculty of Computing"

  Faculty({required this.name, required this.fullName});
}

class Module {
  final String name; // Matches LecturerModel.modules list
  final String facultyName; // To filter by faculty

  Module({required this.name, required this.facultyName});
}