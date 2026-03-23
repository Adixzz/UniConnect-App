import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/models/lecturer_model.dart';

void main() {
  group('LecturerModel', () {
    final testMap = {
      'uid': 'uid456',
      'name': 'Dr. Smith',
      'email': 'smith@nsbm.ac.lk',
      'staffId': 'ST001',
      'pin': '1234',
      'faculty': 'Faculty of Computing',
      'modules': ['PUSL2021', 'PUSL2052'],
      'availability': 'Available',
      'role': 'lecturer',
      'location': 'Block A, Room 101',
      'timetableURL': 'https://docs.google.com/spreadsheets/test',
    };

    test('fromMap() creates correct LecturerModel', () {
      final lecturer = LecturerModel.fromMap(testMap);

      expect(lecturer.uid, 'uid456');
      expect(lecturer.name, 'Dr. Smith');
      expect(lecturer.email, 'smith@nsbm.ac.lk');
      expect(lecturer.staffId, 'ST001');
      expect(lecturer.faculty, 'Faculty of Computing');
      expect(lecturer.modules, ['PUSL2021', 'PUSL2052']);
      expect(lecturer.location, 'Block A, Room 101');
    });

    test('toMap() returns correct map', () {
      final lecturer = LecturerModel.fromMap(testMap);
      final map = lecturer.toMap();

      expect(map['name'], 'Dr. Smith');
      expect(map['email'], 'smith@nsbm.ac.lk');
      expect(map['staffId'], 'ST001');
      expect(map['role'], 'lecturer');
    });

    test('availability defaults to Not in Lecture', () {
      final lecturer = LecturerModel(
        uid: 'uid456',
        name: 'Dr. Smith',
        email: 'smith@nsbm.ac.lk',
        staffId: 'ST001',
        pin: '1234',
        faculty: 'Faculty of Computing',
        modules: ['PUSL2021'],
        location: 'Block A',
        timetableURL: '',
      );

      expect(lecturer.availability, 'Not in Lecture');
    });

    test('fromMap() handles missing optional fields gracefully', () {
      final incompleteMap = {
        'uid': 'uid456',
        'name': 'Dr. Smith',
        'email': 'smith@nsbm.ac.lk',
        'staffId': 'ST001',
        'pin': '1234',
        'faculty': 'Faculty of Computing',
        'modules': <String>[],
      };

      final lecturer = LecturerModel.fromMap(incompleteMap);

      expect(lecturer.location, 'Not Specified');
      expect(lecturer.timetableURL, '');
      expect(lecturer.availability, 'Not in Lecture');
    });
  });
}