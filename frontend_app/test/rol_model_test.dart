import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_app/models/rol_model.dart';

void main() {
  group('RolInfo.fromJson', () {
    test('parsea snake_case del backend (nombre, descripcion, num_usos_max)',
        () {
      final r = RolInfo.fromJson({
        'id_rol': 3,
        'nombre': 'Espía',
        'descripcion': 'Ver la mano de otro jugador',
        'num_usos_max': 4,
        'imagen': 'espia.png',
      });
      expect(r.idRol, 3);
      expect(r.nombre, 'Espía');
      expect(r.descripcion, 'Ver la mano de otro jugador');
      expect(r.maxUsos, 4);
      expect(r.imagen, 'espia.png');
    });

    test(
      'tolera camelCase / inglés (name, description, maxUses) por si '
      'el backend evoluciona',
      () {
        final r = RolInfo.fromJson({
          'name': 'Thief',
          'description': 'Steal a card',
          'maxUses': 3,
        });
        expect(r.nombre, 'Thief');
        expect(r.descripcion, 'Steal a card');
        expect(r.maxUsos, 3);
      },
    );

    test('campos faltantes → defaults seguros (no lanza)', () {
      final r = RolInfo.fromJson({});
      expect(r.nombre, '');
      expect(r.descripcion, isNull);
      expect(r.maxUsos, isNull);
    });

    test('key normaliza acentos y espacios para los 6 roles canónicos', () {
      expect(RolInfo.fromJson({'nombre': 'Espía'}).key, 'espia');
      expect(RolInfo.fromJson({'nombre': 'Ladrón'}).key, 'ladron');
      expect(RolInfo.fromJson({'nombre': 'Anular cartas'}).key, 'anular_cartas');
      expect(
        RolInfo.fromJson({'nombre': 'Transformar carta'}).key,
        'transformar_carta',
      );
      expect(
        RolInfo.fromJson({'nombre': 'Mirar la siguiente carta del mazo'}).key,
        'mirar_siguiente_carta',
      );
      expect(
        RolInfo.fromJson({'nombre': 'Bloquear habilidades'}).key,
        'bloquear_habilidades',
      );
    });
  });

  group('MiRolResponse', () {
    test('parsea respuesta completa de /roles/{gameId}/me', () {
      final r = MiRolResponse.fromJson({
        'gameId': 'g42',
        'playerId': 'santiago',
        'role': {
          'id_rol': 1,
          'nombre': 'Espía',
          'num_usos_max': 4,
        },
        'uses': 1,
        'maxUses': 4,
        'lastUsedTurn': 3,
        'canUseNow': true,
      });
      expect(r.gameId, 'g42');
      expect(r.playerId, 'santiago');
      expect(r.rol?.nombre, 'Espía');
      expect(r.uses, 1);
      expect(r.maxUses, 4);
      expect(r.canUseNow, isTrue);
    });

    test('remainingUses = max - uses, clamp a 0', () {
      final r1 = MiRolResponse.fromJson({
        'gameId': 'g', 'playerId': 'p',
        'role': {'nombre': 'x', 'num_usos_max': 4},
        'uses': 1, 'maxUses': 4, 'canUseNow': false,
      });
      expect(r1.remainingUses, 3);

      final r2 = MiRolResponse.fromJson({
        'gameId': 'g', 'playerId': 'p',
        'role': {'nombre': 'x', 'num_usos_max': 4},
        'uses': 99, 'maxUses': 4, 'canUseNow': false,
      });
      expect(r2.remainingUses, 0, reason: 'nunca debe ser negativo');
    });

    test('si role es null, canUseNow=false y no rompe', () {
      final r = MiRolResponse.fromJson({
        'gameId': 'g', 'playerId': 'p',
        'role': null,
        'uses': 0, 'maxUses': null, 'canUseNow': false,
      });
      expect(r.rol, isNull);
      expect(r.canUseNow, isFalse);
      expect(r.remainingUses, 0);
    });
  });

  group('UsarRolPayload.toJson', () {
    test('manda solo los campos no-null (espía: solo targetPlayerId)', () {
      final body = const UsarRolPayload(targetPlayerId: 'alex').toJson();
      expect(body, {'targetPlayerId': 'alex'});
    });

    test(
      'transformar_carta: ownCardId + newColor + newNumber. ownCardId se '
      'duplica como `cardId` por compatibilidad con backends antiguos',
      () {
        final body = const UsarRolPayload(
          ownCardId: 'blue-3-1',
          newColor: 'red',
          newNumber: 7,
        ).toJson();
        expect(body['ownCardId'], 'blue-3-1');
        expect(body['cardId'], 'blue-3-1');
        expect(body['newColor'], 'red');
        expect(body['newNumber'], 7);
        expect(body.containsKey('targetPlayerId'), isFalse);
      },
    );

    test('payload vacío (mirar_siguiente o bloquear) → mapa vacío', () {
      expect(const UsarRolPayload().toJson(), <String, dynamic>{});
    });
  });

  group('UsarRolResponse', () {
    test('espía: result.targetHand → lista de cartas', () {
      final res = UsarRolResponse.fromJson({
        'success': true,
        'role': {'nombre': 'Espía'},
        'result': {
          'targetHand': [
            {'id': 'blue-1-0', 'value': '1', 'color': 'blue'},
            {'id': 'red-7-2', 'value': '7', 'color': 'red'},
          ],
        },
      });
      expect(res.success, isTrue);
      expect(res.targetHand.length, 2);
      expect(res.nextCard, isNull);
    });

    test('peek: result.nextCard → carta única', () {
      final res = UsarRolResponse.fromJson({
        'success': true,
        'role': {'nombre': 'Mirar la siguiente carta del mazo'},
        'result': {
          'nextCard': {'id': 'green-5-0', 'value': '5', 'color': 'green'},
        },
      });
      expect(res.nextCard, isA<Map>());
      expect((res.nextCard as Map)['value'], '5');
      expect(res.targetHand, isEmpty);
    });

    test('result vacío (anular, transformar, bloquear) → result={}', () {
      final res = UsarRolResponse.fromJson({
        'success': true,
        'role': {'nombre': 'Anular cartas'},
      });
      expect(res.result, isEmpty);
      expect(res.targetHand, isEmpty);
      expect(res.nextCard, isNull);
    });
  });
}
