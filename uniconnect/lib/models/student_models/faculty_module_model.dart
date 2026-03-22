class FacultyModel {
  final String name;
  final String code;

  FacultyModel({required this.name, required this.code});

  factory FacultyModel.fromMap(Map<String, dynamic> map) {
    return FacultyModel(
      name: map['name'] ?? '',
      code: map['code'] ?? '',
    );
  }
}

class ModuleModel {
  final String name;
  final String facultyCode;

  ModuleModel({required this.name, required this.facultyCode});

  factory ModuleModel.fromMap(Map<String, dynamic> map) {
    return ModuleModel(
      name: map['name'] ?? '',
      facultyCode: map['facultyCode'] ?? '',
    );
  }
}