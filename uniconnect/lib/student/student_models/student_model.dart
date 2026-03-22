class StudentModel {
  final String uid;
  final String name;
  final String email;
  final String studentId;
  final String role;

  StudentModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.studentId,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'studentId': studentId,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}