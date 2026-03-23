import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/models/timetable_model.dart';

void main() {
  group('TimetableModel', () {
    test('toMap() returns correct map', () {
      final timetable = TimetableModel(
        timetableId: 'Plymouth_SE_Y2_S1_2026',
        pathway: 'Plymouth',
        degree: 'SE',
        academicYear: '2',
        semester: '1',
        calendarYear: '2026',
        sheetUrl: 'https://docs.google.com/spreadsheets/test',
      );

      final map = timetable.toMap();

      expect(map['timetableId'], 'Plymouth_SE_Y2_S1_2026');
      expect(map['pathway'], 'Plymouth');
      expect(map['degree'], 'SE');
      expect(map['academicYear'], '2');
      expect(map['semester'], '1');
      expect(map['calendarYear'], '2026');
    });

    test('fromMap() creates correct TimetableModel', () {
      final map = {
        'timetableId': 'Plymouth_SE_Y2_S1_2026',
        'pathway': 'Plymouth',
        'degree': 'SE',
        'academicYear': '2',
        'semester': '1',
        'calendarYear': '2026',
        'sheetUrl': 'https://docs.google.com/spreadsheets/test',
      };

      final timetable = TimetableModel.fromMap('Plymouth_SE_Y2_S1_2026', map);

      expect(timetable.pathway, 'Plymouth');
      expect(timetable.degree, 'SE');
      expect(timetable.academicYear, '2');
      expect(timetable.semester, '1');
      expect(timetable.calendarYear, '2026');
    });

    test('fromMap() handles missing fields gracefully', () {
      final timetable = TimetableModel.fromMap('id', {});

      expect(timetable.pathway, '');
      expect(timetable.degree, '');
      expect(timetable.sheetUrl, '');
    });

    test('timetable ID format is correct', () {
      final pathway = 'Plymouth';
      final degree = 'SE';
      final academicYear = '2';
      final semester = '1';
      final calendarYear = '2026';

      final timetableId =
          '${pathway}_${degree}_Y${academicYear}_S${semester}_${calendarYear}';

      expect(timetableId, 'Plymouth_SE_Y2_S1_2026');
    });
  });
}