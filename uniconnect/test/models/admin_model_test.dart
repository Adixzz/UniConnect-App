import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/models/admin_model.dart';

void main() {
  group('AdminModel', () {
    test('toMap() returns correct map', () {
      final admin = AdminModel(
        uid: 'uid789',
        name: 'Admin User',
        adminId: 'ADM001',
        createdAt: '2026-01-01T00:00:00.000',
      );

      final map = admin.toMap();

      expect(map['uid'], 'uid789');
      expect(map['name'], 'Admin User');
      expect(map['adminId'], 'ADM001');
      expect(map['role'], 'admin');
    });

    test('fromMap() creates correct AdminModel', () {
      final map = {
        'uid': 'uid789',
        'name': 'Admin User',
        'adminId': 'ADM001',
        'createdAt': '2026-01-01T00:00:00.000',
      };

      final admin = AdminModel.fromMap('uid789', map);

      expect(admin.uid, 'uid789');
      expect(admin.name, 'Admin User');
      expect(admin.adminId, 'ADM001');
    });

    test('fromMap() handles missing fields gracefully', () {
      final admin = AdminModel.fromMap('uid789', {});

      expect(admin.name, '');
      expect(admin.adminId, '');
      expect(admin.createdAt, '');
    });
  });
}