import 'dart:convert';
import 'dart:developer' as developer;
import '../models/partida_model.dart';
import '../services/api_service.dart';

class PartidaRepository {
  final ApiService _api;

  PartidaRepository(this._api);

  /// Obtiene la lista de partidas pausadas del usuario
  Future<List<PartidaModel>> obtenerPartidasPausadas() async {
    developer.log('Solicitando partidas pausadas', name: 'PartidaRepository');
    try {
      final response = await _api.get('/partidas/pausadas');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        developer.log(
          'Se encontraron ${data.length} partidas pausadas',
          name: 'PartidaRepository',
        );
        return data.map((json) => PartidaModel.fromJson(json)).toList();
      } else {
        developer.log(
          'Error al obtener partidas pausadas: ${response.statusCode}',
          name: 'PartidaRepository',
        );
        throw Exception('Error al obtener partidas pausadas');
      }
    } catch (e) {
      developer.log(
        'Excepción en obtenerPartidasPausadas: $e',
        name: 'PartidaRepository',
        error: e,
      );
      rethrow;
    }
  }

  Future<PartidaModel> crearPartida({
    required bool isPrivate,
    int maxJugadores = 4,
    bool modoCartasEspeciales = true,
    bool modoRoles = false,
  }) async {
    final response = await _api.post('/partidas', {
      'maxJugadores': maxJugadores,
      'privada': isPrivate,
      'modoCartasEspeciales': modoCartasEspeciales,
      'modoRoles': modoRoles,
      'numCartasInicio': 7,
      'timeoutTurno': 30,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return PartidaModel.fromJson(data);
    }

    throw Exception('Error al crear partida: ${response.body}');
  }

  Future<PartidaModel> unirsePartidaPublica({
    int maxJugadores = 4,
    String? mode,
  }) async {
    final response = await _api.post('/partidas/join', {
      'maxJugadores': maxJugadores,
      if (mode != null) 'mode': mode,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final gameId = data['gameId']?.toString();
      if (gameId != null && gameId.isNotEmpty) {
        return await obtenerPartida(gameId);
      }
      return PartidaModel.fromJson(data);
    }

    throw Exception('Error al unirse a partida pública: ${response.body}');
  }

  Future<PartidaModel> unirsePorCodigo(String code) async {
    final codigo = code.trim().toUpperCase();
    final response = await _api.post('/partidas/join-by-code', {
      'codigo': codigo,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final String gameId = data['gameId'];
      final partida = await obtenerPartida(gameId);
      return partida.copyWith(code: codigo, isPrivate: true);
    }

    throw Exception('Error al unirse por código: ${response.body}');
  }

  Future<PartidaModel> obtenerPartida(String gameId) async {
    final response = await _api.get('/partidas/$gameId');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PartidaModel.fromJson(data);
    }

    throw Exception('Error al obtener partida: ${response.body}');
  }

  Future<PartidaModel> obtenerEstadoPartida(String gameId) async {
    final response = await _api.get('/partidas/$gameId/state');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PartidaModel.fromJson(data);
    }

    throw Exception('Error al obtener estado de partida: ${response.body}');
  }

  Future<void> finalizarPartida(String gameId) async {
    final response = await _api.post('/partidas/$gameId/end', {});

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al finalizar partida: ${response.body}');
    }
  }

  Future<void> borrarPartida(String gameId) async {
    final response = await _api.delete('/partidas/$gameId');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al borrar la partida: ${response.body}');
    }
  }

  /// Reanudar una partida pausada
  Future<PartidaModel> reanudarPartida(String gameId) async {
    developer.log('Reanudando partida: $gameId', name: 'PartidaRepository');
    final response = await _api.post('/partidas/$gameId/resume', {});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PartidaModel.fromJson(data);
    }

    throw Exception('Error al reanudar partida: ${response.body}');
  }

  Future<void> solicitarPausa(String gameId) async {
    final response = await _api.post('/partidas/$gameId/pause', {});

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al solicitar la pausa: ${response.body}');
    }
  }

  Future<void> anyadirBot(String gameId) async {
    developer.log(
      'Llamando a POST /partidas/$gameId/add-bot',
      name: 'PartidaRepository',
    );
    final response = await _api
        .post('/partidas/$gameId/add-bot', {})
        .timeout(const Duration(seconds: 5));
    developer.log(
      'Respuesta add-bot: ${response.statusCode} - Body: ${response.body}',
      name: 'PartidaRepository',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        developer.log(
          'Bot añadido con éxito. ID del Bot: ${data['botId']}',
          name: 'PartidaRepository',
        );
        return;
      }
    }

    throw Exception(
      'Fallo al añadir bot. Código: ${response.statusCode}, Error: ${response.body}',
    );
  }
}
