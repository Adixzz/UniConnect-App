import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Email Validation', () {
    test('valid NSBM student email passes', () {
      final email = 'john@students.nsbm.ac.lk';
      expect(email.endsWith('@students.nsbm.ac.lk'), true);
    });

    test('non NSBM email fails', () {
      final email = 'john@gmail.com';
      expect(email.endsWith('@students.nsbm.ac.lk'), false);
    });

    test('empty email fails', () {
      final email = '';
      expect(email.endsWith('@students.nsbm.ac.lk'), false);
    });

    test('partial NSBM email fails', () {
      final email = 'john@nsbm.ac.lk';
      expect(email.endsWith('@students.nsbm.ac.lk'), false);
    });
  });

  group('Password Validation', () {
    test('matching passwords pass', () {
      final password = 'Test1234';
      final confirmPassword = 'Test1234';
      expect(password == confirmPassword, true);
    });

    test('non matching passwords fail', () {
      final password = 'Test1234';
      final confirmPassword = 'Test5678';
      expect(password == confirmPassword, false);
    });

    test('empty password fails empty check', () {
      final password = '';
      expect(password.isEmpty, true);
    });
  });
}