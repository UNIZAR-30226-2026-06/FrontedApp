import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:frontend_app/models/jugador_partida_model.dart';
import 'package:frontend_app/repositories/partida_repository.dart';
import 'package:frontend_app/services/api_service.dart';
import 'package:frontend_app/services/socket_service.dart';
import 'package:frontend_app/viewmodels/partida_actual_viewmodel.dart';

/// Devuelve la misma respuesta para todas las peticiones — basta para
/// instanciar el VM y probar el estado de banderas internas (no estamos
/// validando contrato HTTP aquí, eso lo hace partida_repository_test.dart).
class _StubApi extends ApiService {
  @override
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    if (endpoint == '/partidas') {
      return http.Response(
        jsonEncode({
          'gameId': 'g-host',
          'codigo': 'HOST01',
          'estado': 'esperando_jugadores',
          'maxJugadores': 4,
          'players': [
            {'id': 'santiago'},
          ],
        }),
        201,
      );
    }
    if (endpoint == '/partidas/join-by-code') {
      return http.Response(jsonEncode({'gameId': 'g-join'}), 200);
    }
    if (endpoint == '/partidas/join') {
      return http.Response(jsonEncode({'gameId': 'g-pub'}), 200);
    }
    return http.Response('{}', 200);
  }

  @override
  Future<http.Response> get(String endpoint) async {
    return http.Response(
      jsonEncode({
        'gameId': endpoint.split('/').last,
        'estado': 'esperando_jugadores',
        'maxJugadores': 4,
        'players': [
          {'id': 'host'},
          {'id': 'joiner'},
        ],
      }),
      200,
    );
  }

  @override
  Future<http.Response> delete(String endpoint) async {
    return http.Response('{}', 200);
  }
}

/// SocketService falso: nunca conecta, así `socket` queda en `null` y todos
/// los listeners del VM (que protegen con `if (socket == null) return`) se
/// quedan inertes. Suficiente para validar la lógica de estado del VM sin
/// montar un servidor Socket.IO real en los tests.
class _NoOpSocketService extends SocketService {}

void main() {
  group('PartidaActualViewModel · flag soyHost', () {
    late _NoOpSocketService socket;
    late PartidaActualViewModel vm;

    setUp(() {
      socket = _NoOpSocketService();
      vm = PartidaActualViewModel(PartidaRepository(_StubApi()), socket);
    });

    test('al instanciar, soyHost = false', () {
      expect(vm.soyHost, isFalse);
      expect(vm.partidaActual, isNull);
    });

    test('crearPartida marca soyHost = true', () async {
      await vm.crearPartida(isPrivate: true, jugadorLocal: 'santiago');
      expect(vm.soyHost, isTrue);
      expect(vm.partidaActual?.gameId, 'g-host');
    });

    test('unirsePorCodigo marca soyHost = false', () async {
      await vm.unirsePorCodigo('HOST01', jugadorLocal: 'alex');
      expect(vm.soyHost, isFalse);
      expect(vm.partidaActual?.gameId, 'g-join');
    });

    test('unirsePartidaPublica marca soyHost = false', () async {
      await vm.unirsePartidaPublica(jugadorLocal: 'alex');
      expect(vm.soyHost, isFalse);
    });

    test(
      'limpiarPartida resetea soyHost, partida y estado de pausa/votos',
      () async {
        await vm.crearPartida(isPrivate: true, jugadorLocal: 'santiago');
        expect(vm.soyHost, isTrue);

        vm.limpiarPartida();

        expect(vm.soyHost, isFalse);
        expect(vm.partidaActual, isNull);
        expect(vm.partidaEstaPausada, isFalse);
        expect(vm.votosPausa, 0);
        expect(vm.yoHeVotadoPausa, isFalse);
        expect(vm.votosReanudar, 0);
        expect(vm.yoHeVotadoReanudar, isFalse);
      },
    );

    test(
      'crear → limpiar → unirsePorCodigo: soyHost vuelve a false (no se queda pegado)',
      () async {
        await vm.crearPartida(isPrivate: true, jugadorLocal: 'santiago');
        expect(vm.soyHost, isTrue);

        vm.limpiarPartida();
        expect(vm.soyHost, isFalse);

        await vm.unirsePorCodigo('OTRA01', jugadorLocal: 'santiago');
        expect(vm.soyHost, isFalse,
            reason:
                'tras unirse a otra partida, no puedo ser host por accidente');
      },
    );

    test(
      'esperarHastaQueHayaJugadores resuelve true inmediato si ya hay suficientes',
      () async {
        await vm.crearPartida(isPrivate: true, jugadorLocal: 'santiago');
        expect(vm.partidaActual?.jugadores.length, greaterThanOrEqualTo(1));
        final ok = await vm.esperarHastaQueHayaJugadores(
          1,
          timeout: const Duration(milliseconds: 100),
        );
        expect(ok, isTrue);
      },
    );

    test(
      'esperarHastaQueHayaJugadores devuelve false al expirar el timeout '
      '(sin bloquear el test)',
      () async {
        await vm.crearPartida(isPrivate: true, jugadorLocal: 'santiago');
        final stopwatch = Stopwatch()..start();
        final ok = await vm.esperarHastaQueHayaJugadores(
          10,
          timeout: const Duration(milliseconds: 200),
        );
        stopwatch.stop();
        expect(ok, isFalse);
        // El método NO debe quedarse colgado más allá del timeout. Margen
        // generoso (700 ms) para evitar flakiness en CI.
        expect(stopwatch.elapsedMilliseconds, lessThan(700));
      },
    );

    test(
      'esperarHastaQueHayaJugadores resuelve true cuando los bots llegan '
      'durante la espera (event-driven, sin polling)',
      () async {
        await vm.crearPartida(isPrivate: true, jugadorLocal: 'santiago');
        // Lanzamos la espera (necesita 3 jugadores: el host + 2 bots).
        final futureEspera = vm.esperarHastaQueHayaJugadores(
          3,
          timeout: const Duration(seconds: 2),
        );

        // A los 50 ms simulamos que llegan los bots actualizando la lista
        // vía setPartidaActual. Esto dispara notifyListeners y la espera
        // debería resolver inmediatamente.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final partidaConBots = vm.partidaActual!.copyWith(
          jugadores: [
            ...vm.partidaActual!.jugadores,
            JugadorPartidaModel(id: 'Bot_1111'),
            JugadorPartidaModel(id: 'Bot_2222'),
          ],
        );
        vm.setPartidaActual(
          partidaConBots,
          jugadorLocal: vm.partidaActual!.jugadorLocal,
        );

        expect(await futureEspera, isTrue);
        expect(vm.partidaActual!.jugadores.length, 3);
      },
    );

    test('maxJugadores se setea en crear y persiste hasta limpiar', () async {
      expect(vm.maxJugadores, 4); // default
      await vm.crearPartida(isPrivate: true, maxJugadores: 3);
      expect(vm.maxJugadores, 3);
      vm.limpiarPartida();
      // limpiarPartida NO resetea maxJugadores (se conserva por si vuelves
      // a entrar al mismo lobby). Lo dejamos documentado por si cambia.
      expect(vm.maxJugadores, 3);
    });
  });
}
