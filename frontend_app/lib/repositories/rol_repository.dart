import 'dart:convert';

import '../models/rol_model.dart';
import '../services/api_service.dart';

/// Acceso HTTP al módulo de roles del backend.
class RolRepository {
  final ApiService _api;

  RolRepository(this._api);

  /// GET `/roles/{gameId}/me` — info del rol asignado al jugador autenticado.
  /// Lanza si el backend devuelve 404 (rol no asignado) o error.
  Future<MiRolResponse> obtenerMiRol(String gameId) async {
    final response = await _api.get('/roles/$gameId/me');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return MiRolResponse.fromJson(data);
    }
    throw Exception(
      'Error al obtener mi rol (${response.statusCode}): ${response.body}',
    );
  }

  /// POST `/roles/{gameId}/use` — usa la habilidad del rol con el payload
  /// específico de cada tipo. El backend ya valida turno, usos restantes,
  /// si el rol está bloqueado, etc.
  Future<UsarRolResponse> usarRol(
    String gameId,
    UsarRolPayload payload,
  ) async {
    final response = await _api.post('/roles/$gameId/use', payload.toJson());
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return UsarRolResponse.fromJson(data);
    }
    throw Exception(
      'Error al usar rol (${response.statusCode}): ${response.body}',
    );
  }
}
