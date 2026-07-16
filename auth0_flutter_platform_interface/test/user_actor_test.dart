import 'package:auth0_flutter_platform_interface/auth0_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserActor', () {
    test('fromMap returns null for a null map', () {
      expect(UserActor.fromMap(null), isNull);
    });

    test('fromMap returns null when sub is missing', () {
      expect(UserActor.fromMap({'org': 'auth0'}), isNull);
    });

    test('fromMap parses sub and extra claims', () {
      final actor = UserActor.fromMap({
        'sub': 'actor-agent-123',
        'org': 'auth0',
        'role': 'support',
      });

      expect(actor, isNotNull);
      expect(actor!.sub, 'actor-agent-123');
      expect(actor.actor, isNull);
      expect(actor.extraClaims, {'org': 'auth0', 'role': 'support'});
    });

    test('fromMap preserves nested delegation chains', () {
      final actor = UserActor.fromMap({
        'sub': 'actor-agent-123',
        'act': {
          'sub': 'original-actor-456',
          'role': 'admin',
        },
      });

      expect(actor!.sub, 'actor-agent-123');
      expect(actor.actor, isNotNull);
      expect(actor.actor!.sub, 'original-actor-456');
      expect(actor.actor!.extraClaims, {'role': 'admin'});
    });

    test('fromMap drops a nested act without a sub', () {
      final actor = UserActor.fromMap({
        'sub': 'actor-agent-123',
        'act': {'role': 'admin'},
      });

      expect(actor!.actor, isNull);
    });

    test('toMap round-trips sub, nested actor, and extra claims', () {
      const actor = UserActor(
        sub: 'actor-agent-123',
        actor: UserActor(sub: 'original-actor-456'),
        extraClaims: {'org': 'auth0'},
      );

      expect(actor.toMap(), {
        'sub': 'actor-agent-123',
        'act': {'sub': 'original-actor-456'},
        'org': 'auth0',
      });
    });

    test('toMap does not let extraClaims overwrite sub or act', () {
      const actor = UserActor(
        sub: 'actor-agent-123',
        actor: UserActor(sub: 'original-actor-456'),
        extraClaims: {'sub': 'spoofed', 'act': 'spoofed'},
      );

      final map = actor.toMap();

      expect(map['sub'], 'actor-agent-123');
      expect(map['act'], {'sub': 'original-actor-456'});
    });
  });
}
