class UserModel {
  final String uid;
  final String name;
  final String email;
  final String studentId;
  final String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.studentId,
    required this.role,
  });

  // Convert a UserModel into a Map to save to Firestore
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