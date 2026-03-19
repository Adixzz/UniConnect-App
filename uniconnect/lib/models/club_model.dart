class ClubModel {
  final String clubId;
  final String name;
  final String description;
  final String category;
  final String president;
  final String presidentID;
  final List<String> members;
  final List<String> pendingRequests;

  ClubModel({
    required this.clubId,
    required this.name,
    required this.description,
    required this.category,
    required this.president,
    required this.presidentID,
    required this.members,
    required this.pendingRequests,
  });

  Map<String, dynamic> toMap() {
    return {
      'clubId': clubId,
      'name': name,
      'description': description,
      'category': category,
      'president': president,
      'presidentID': presidentID,
      'members': members,
      'pendingRequests': pendingRequests,

      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory ClubModel.fromMap(String id, Map<String, dynamic> map) {
    return ClubModel(
      clubId: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      president: map['president'] ?? '',
      presidentID: map['presidentID'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      pendingRequests: List<String>.from(map['pendingRequests'] ?? []),

    );
  }
}