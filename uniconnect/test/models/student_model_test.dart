import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/models/student_model.dart';

void main() {
  group('StudentModel', () {
    test('toMap() returns correct map', () {
      final student = StudentModel(
        uid: 'uid123',
        name: 'John Doe',
        email: 'john@students.nsbm.ac.lk',
        studentId: 'S12345',
        role: 'student',
      );

      final map = student.toMap();

      expect(map['uid'], 'uid123');
      expect(map['name'], 'John Doe');
      expect(map['email'], 'john@students.nsbm.ac.lk');
      expect(map['studentId'], 'S12345');
      expect(map['role'], 'student');
    });

    test('toMap() includes createdAt field', () {
      final student = StudentModel(
        uid: 'uid123',
        name: 'John Doe',
        email: 'john@students.nsbm.ac.lk',
        studentId: 'S12345',
        role: 'student',
      );

      final map = student.toMap();

      expect(map.containsKey('createdAt'), true);
    });

    test('role defaults to student', () {
      final student = StudentModel(
        uid: 'uid123',
        name: 'John Doe',
        email: 'john@students.nsbm.ac.lk',
        studentId: 'S12345',
        role: 'student',
      );

      expect(student.role, 'student');
    });
  });
}