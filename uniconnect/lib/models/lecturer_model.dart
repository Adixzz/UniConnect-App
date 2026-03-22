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
  final String location;

  LecturerModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.staffId,
    required this.pin,
    required this.faculty,
    required this.modules,
    this.availability = 'Available',
    this.role = 'lecturer',
    required this.location,
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
      'location': location,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory LecturerModel.fromMap(Map<String, dynamic> map) {
    return LecturerModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      staffId: map['staffId'] ?? '',
      pin: map['pin'] ?? '',
      faculty: map['faculty'] ?? '',
      location: map['location'] ?? 'Not Specified', 
      modules: List<String>.from(map['modules'] ?? []),
      availability: map['availability'] ?? 'Not in Lecture',
      role: map['role'] ?? 'lecturer',
    );
  }
}