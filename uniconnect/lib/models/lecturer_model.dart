class LecturerModel {
  final String uid;
  final String name;
  final String email;
  final String staffId;
  final String pin;
  final String faculty;
  final List<String> modules;
  final String availability;
  final String role;

  LecturerModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.staffId,
    required this.pin,
    required this.faculty,
    required this.modules,
    this.availability = 'Not in Lecture',
    this.role = 'lecturer',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'staffId': staffId,
      'pin': pin,
      'faculty': faculty,
      'modules': modules,
      'availability': availability,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}