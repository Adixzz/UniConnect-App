import 'package:flutter_test/flutter_test.dart';
import 'package:uniconnect/models/club_model.dart';

void main() {
  group('ClubModel', () {
    test('toMap() returns correct map', () {
      final club = ClubModel(
        clubId: 'club123',
        name: 'Leo Club',
        description: 'A service club',
        category: 'Social',
        president: 'John Doe',
        presidentID: 'uid123',
        members: ['uid1', 'uid2'],
        pendingRequests: ['uid3'],
        requestReasons: {'uid3': 'I want to join'},
      );

      final map = club.toMap();

      expect(map['clubId'], 'club123');
      expect(map['name'], 'Leo Club');
      expect(map['category'], 'Social');
      expect(map['members'], ['uid1', 'uid2']);
      expect(map['pendingRequests'], ['uid3']);
    });

    test('fromMap() creates correct ClubModel', () {
      final map = {
        'clubId': 'club123',
        'name': 'Leo Club',
        'description': 'A service club',
        'category': 'Social',
        'president': 'John Doe',
        'presidentID': 'uid123',
        'members': ['uid1', 'uid2'],
        'pendingRequests': ['uid3'],
        'requestReasons': {'uid3': 'I want to join'},
      };

      final club = ClubModel.fromMap('club123', map);

      expect(club.clubId, 'club123');
      expect(club.name, 'Leo Club');
      expect(club.members.length, 2);
      expect(club.pendingRequests.length, 1);
    });

    test('fromMap() handles empty members and requests', () {
      final map = {
        'name': 'Leo Club',
        'description': 'A service club',
        'category': 'Social',
        'president': 'John Doe',
        'presidentID': 'uid123',
      };

      final club = ClubModel.fromMap('club123', map);

      expect(club.members, []);
      expect(club.pendingRequests, []);
      expect(club.requestReasons, {});
    });
  });
}