import 'dart:convert';
import '../models/partida_model.dart';
import '../services/api_service.dart';

class PartidaRepository {
  final ApiService _api;

  PartidaRepository(this._api);

  Future<PartidaModel> crearPartida({
    required bool isPrivate,
    int maxJugadores = 4,
  }) async {
    final response = await _api.post('/partidas', {
      'maxJugadores': maxJugadores,
      'privada': isPrivate,
      'modoCartasEspeciales': true,
      'modoRoles': false,
      'numCartasInicio': 7,
      'timeoutTurno': 30
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
      'code': code,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return PartidaModel.fromJson(data);
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
}