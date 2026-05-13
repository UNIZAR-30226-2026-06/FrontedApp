import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:frontend_app/repositories/partida_repository.dart';
import 'package:frontend_app/services/api_service.dart';

/// Fake de ApiService: captura POST/GET y devuelve respuestas inyectables.
class _FakeApiService extends ApiService {
  http.Response Function(String endpoint, Map<String, dynamic> body)? onPost;
  http.Response Function(String endpoint)? onGet;
  final List<({String endpoint, Map<String, dynamic> body})> postCalls = [];
  final List<String> getCalls = [];

  @override
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    postCalls.add((endpoint: endpoint, body: body));
    return onPost?.call(endpoint, body) ?? http.Response('{}', 200);
  }

  @override
  Future<http.Response> get(String endpoint) async {
    getCalls.add(endpoint);
    return onGet?.call(endpoint) ?? http.Response('{}', 200);
  }
}

void main() {
  group('PartidaRepository · contrato HTTP', () {
    late _FakeApiService api;
    late PartidaRepository repo;

    setUp(() {
      api = _FakeApiService();
      repo = PartidaRepository(api);
    });

    test(
      'crearPartida envía exactamente los flags de personalización al backend',
      () async {
        api.onPost = (_, __) => http.Response(
              jsonEncode({
                'gameId': 'g1',
                'codigo': 'ABC123',
                'estado': 'esperando_jugadores',
                'maxJugadores': 4,
                'players': [],
              }),
              201,
            );

        await repo.crearPartida(
          isPrivate: true,
          maxJugadores: 4,
          modoRoles: true,
          modoCartasEspeciales: false,
          numCartasInicio: 10,
        );

        final call = api.postCalls.single;
        expect(call.endpoint, '/partidas');
        expect(call.body['maxJugadores'], 4);
        expect(call.body['privada'], true);
        expect(call.body['modoRoles'], true);
        expect(call.body['modoCartasEspeciales'], false);
        expect(call.body['numCartasInicio'], 10);
        expect(call.body['timeoutTurno'], 30);
      },
    );

    test(
      'crearPartida con valores por defecto: numCartasInicio=7, cartasEspeciales=true',
      () async {
        api.onPost = (_, __) => http.Response(
              jsonEncode({
                'gameId': 'g1',
                'codigo': 'DEF456',
                'estado': 'esperando_jugadores',
                'maxJugadores': 4,
                'players': [],
              }),
              201,
            );

        await repo.crearPartida(isPrivate: false);

        final body = api.postCalls.single.body;
        expect(body['numCartasInicio'], 7);
        expect(body['modoCartasEspeciales'], true);
        expect(body['modoRoles'], false);
        expect(body['privada'], false);
      },
    );

    test(
      'unirsePorCodigo normaliza el código (trim + UPPERCASE) y POSTea a /partidas/join-by-code',
      () async {
        api.onPost = (endpoint, body) {
          if (endpoint == '/partidas/join-by-code') {
            return http.Response(jsonEncode({'gameId': 'g42'}), 200);
          }
          return http.Response('{}', 404);
        };
        api.onGet = (endpoint) {
          if (endpoint == '/partidas/g42') {
            return http.Response(
              jsonEncode({
                'gameId': 'g42',
                'estado': 'esperando_jugadores',
                'maxJugadores': 4,
                'players': [
                  {'id': 'host'},
                ],
              }),
              200,
            );
          }
          return http.Response('{}', 404);
        };

        final partida = await repo.unirsePorCodigo('  abc123  ');

        final joinCall = api.postCalls.singleWhere(
          (c) => c.endpoint == '/partidas/join-by-code',
        );
        expect(joinCall.body['codigo'], 'ABC123',
            reason: 'el cliente debe limpiar (trim + uppercase) antes de enviar');

        expect(api.getCalls, contains('/partidas/g42'),
            reason: 'tras unirse, hidrata el lobby con un GET /partidas/:id');

        expect(partida.gameId, 'g42');
        expect(partida.code, 'ABC123');
        expect(partida.isPrivate, true);
      },
    );

    test('unirsePorCodigo lanza si el backend responde con error', () async {
      api.onPost = (_, __) => http.Response(
            jsonEncode({'message': 'Código inválido'}),
            404,
          );

      expect(
        () => repo.unirsePorCodigo('NOEXISTE'),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'obtenerPartida preserva `estado` tal cual lo manda el backend (no normaliza)',
      () async {
        api.onGet = (_) => http.Response(
              jsonEncode({
                'gameId': 'g99',
                'estado': 'en_curso',
                'maxJugadores': 4,
                'players': [
                  {'id': 'host'},
                  {'id': 'joiner'},
                ],
              }),
              200,
            );

        final p = await repo.obtenerPartida('g99');
        expect(p.gameId, 'g99');
        // SalaEsperaView compara con 'playing'; si llega 'en_curso' literal,
        // no debe navegar al tablero (sólo lo hace cuando el socket marca
        // phase='playing' explícitamente).
        expect(p.phase, isNot('playing'));
        expect(p.jugadores.length, 2);
      },
    );

    test(
      'PartidaModel.fromJson preserva "esperando_jugadores" → cliente NO navega al tablero',
      () async {
        api.onGet = (_) => http.Response(
              jsonEncode({
                'gameId': 'g50',
                'estado': 'esperando_jugadores',
                'maxJugadores': 4,
                'players': [
                  {'id': 'host'},
                ],
              }),
              200,
            );

        final p = await repo.obtenerPartida('g50');
        expect(p.phase, isNot('playing'),
            reason: 'el SalaEsperaView usa phase=="playing" como gatillo de '
                'navegación; "esperando_jugadores" debe NO matchear');
      },
    );

    test('obtenerEstadoPartida hace GET a /partidas/:id/state', () async {
      api.onGet = (endpoint) {
        if (endpoint == '/partidas/g1/state') {
          return http.Response(
            jsonEncode({
              'gameId': 'g1',
              'phase': 'playing',
              'players': [
                {'id': 'host', 'hand': []},
                {'id': 'joiner', 'hand': []},
              ],
            }),
            200,
          );
        }
        return http.Response('{}', 404);
      };

      final p = await repo.obtenerEstadoPartida('g1');
      expect(p.phase, 'playing');
      expect(p.jugadores.length, 2);
    });
  });
}
