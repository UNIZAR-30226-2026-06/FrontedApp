import 'dart:convert';
import 'dart:developer' as developer;
import '../models/partida_model.dart';
import '../services/api_service.dart';

class PartidaNoEncontradaException implements Exception {
  final String message;
  PartidaNoEncontradaException([this.message = 'Partida no encontrada']);
  @override
  String toString() => message;
}


class ResumeVoteResult {
  final String action;
  final List<String> voters;
  final int votosActuales;

  const ResumeVoteResult({
    required this.action,
    required this.voters,
    required this.votosActuales,
  });

  bool get partidaReanudada => action == 'reanudada';
}

class PartidaRepository {
  final ApiService _api;

  PartidaRepository(this._api);

  /// Obtiene la lista de partidas pausadas del usuario
  Future<List<PartidaModel>> obtenerPartidasPausadas() async {
    developer.log('Solicitando partidas pausadas', name: 'PartidaRepository');
    try {
      final response = await _api.get('/partidas/pausadas');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List<dynamic> data = decoded is List
            ? decoded
            : (decoded['data'] as List<dynamic>? ?? []);
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
    bool modoRoles = false,
  }) async {
    final response = await _api.post('/partidas', {
      'maxJugadores': maxJugadores,
      'privada': isPrivate,
      'modoCartasEspeciales': true,
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

  Future<PartidaModel> unirsePartidaPublica() async {
    final response = await _api.post('/partidas/join', {});

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return PartidaModel.fromJson(data);
    }

    throw Exception('Error al unirse a partida pública: ${response.body}');
  }

  Future<PartidaModel> unirsePorCodigo(String code) async {
    final response = await _api.post('/partidas/join-by-code', {
      'codigo': code.trim(),
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final String gameId = data['gameId'];
      return await obtenerPartida(gameId);
    }

    throw Exception('Error al unirse por código: ${response.body}');
  }

  Future<PartidaModel> obtenerPartida(String gameId) async {
    final response = await _api.get('/partidas/$gameId');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PartidaModel.fromJson(data);
    }

    if (response.statusCode == 404) {
      throw PartidaNoEncontradaException();
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

  /// Resultado de votar reanudación. El backend devuelve uno de dos formatos:
  ///   { action: 'reanudada', ... }
  ///   { action: 'voto_reanudar_registrado', voters: [...], votosActuales: N }
  /// Este método NO devuelve un PartidaModel: es solo el ack del voto.
  Future<ResumeVoteResult> votarReanudarPartida(String gameId) async {
    developer.log('Votando reanudar partida: $gameId', name: 'PartidaRepository');
    final response = await _api.post('/partidas/$gameId/resume', {});

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al reanudar partida: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final action = data is Map ? data['action']?.toString() ?? '' : '';
    final voters = data is Map && data['voters'] is List
        ? (data['voters'] as List).map((v) => v.toString()).toList()
        : <String>[];
    final votosActuales = data is Map ? (data['votosActuales'] as int? ?? 0) : 0;

    return ResumeVoteResult(
      action: action,
      voters: voters,
      votosActuales: votosActuales,
    );
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

  // ==========================================
  // ENDPOINTS DE ROLES
  // ==========================================

  /// 1. Obtiene la información del rol asignado al jugador local
  Future<Map<String, dynamic>> obtenerMiRol(String gameId) async {
    final response = await _api.get('/roles/$gameId/me');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener el rol: ${response.body}');
  }

  /// 2. Obtiene solo el número de usos (útil para refrescar rápido)
  Future<Map<String, dynamic>> obtenerUsosRol(String gameId) async {
    final response = await _api.get('/roles/$gameId/me/uses');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al obtener usos del rol: ${response.body}');
  }

  /// 3. Usa la habilidad del rol. Los parámetros son opcionales porque
  /// dependen de la habilidad específica de cada rol.
  Future<Map<String, dynamic>> usarRol(
      String gameId, {
        String? targetPlayerId,
        String? ownCardId,
        String? cardId,
        String? newColor,
        int? newNumber,
      }) async {
    final payload = <String, dynamic>{};

    if (targetPlayerId != null) payload['targetPlayerId'] = targetPlayerId;
    if (ownCardId != null) payload['ownCardId'] = ownCardId;
    if (cardId != null) payload['cardId'] = cardId;
    if (newColor != null) payload['newColor'] = newColor;
    if (newNumber != null) payload['newNumber'] = newNumber;

    final response = await _api.post('/roles/$gameId/use', payload);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al usar el rol: ${response.body}');
  }
}
