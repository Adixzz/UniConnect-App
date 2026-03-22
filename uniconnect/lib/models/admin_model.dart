class AdminModel {
  final String uid;
  final String name;
  final String adminId;
  final String createdAt;

  AdminModel({
    required this.uid,
    required this.name,
    required this.adminId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'adminId': adminId,
      'role': 'admin',
      'createdAt': createdAt,
    };
  }

  factory AdminModel.fromMap(String id, Map<String, dynamic> map) {
    return AdminModel(
      uid: id,
      name: map['name'] ?? '',
      adminId: map['adminId'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }
}