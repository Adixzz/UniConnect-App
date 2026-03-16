class TimetableModel {
  final String timetableId;
  final String pathway;
  final String degree;
  final String academicYear;
  final String semester;
  final String calendarYear;
  final String sheetUrl;

  TimetableModel({
    required this.timetableId,
    required this.pathway,
    required this.degree,
    required this.academicYear,
    required this.semester,
    required this.calendarYear,
    required this.sheetUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'timetableId': timetableId,
      'pathway': pathway,
      'degree': degree,
      'academicYear': academicYear,
      'semester': semester,
      'calendarYear': calendarYear,
      'sheetUrl': sheetUrl,
    };
  }

  factory TimetableModel.fromMap(String id, Map<String, dynamic> map) {
    return TimetableModel(
      timetableId: id,
      pathway: map['pathway'] ?? '',
      degree: map['degree'] ?? '',
      academicYear: map['academicYear'] ?? '',
      semester: map['semester'] ?? '',
      calendarYear: map['calendarYear'] ?? '',
      sheetUrl: map['sheetUrl'] ?? '',
    );
  }
}