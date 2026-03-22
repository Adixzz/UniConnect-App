class ClubModel {
  final String clubId;
  final String name;
  final String description;
  final String category;
  final String president;

  ClubModel({
    required this.clubId,
    required this.name,
    required this.description,
    required this.category,
    required this.president,
  });

  Map<String, dynamic> toMap() {
    return {
      'clubId': clubId,
      'name': name,
      'description': description,
      'category': category,
      'president': president,
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
    );
  }
}