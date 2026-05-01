import 'dart:convert';
import '../models/jugador_model.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';

class AmigosRepository {
  final ApiService _api;
  AmigosRepository(this._api);


  Future<List<Jugador>> fetchAmigos() async {
    try {
      final resp = await _api.get('/friends');

      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body);

        return data.map((item) {
          final Map<String, dynamic> amigo = item as Map<String, dynamic>;

          final String nombre = amigo['nombre_usuario'] ?? 'Desconocido';
          final int monedas = amigo['monedas'] ?? 0;

          return Jugador(
              nombre: nombre,
              coins: monedas,
              avatarId: ''
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error al cargar amigos: $e");
      return [];
    }
  }

  // GET /friends/request/pending
  Future<List<Map<String, dynamic>>> fetchSolicitudes() async {
    final resp = await _api.get('/friends/request/pending');

    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);

      return data.map((item) {
        final Map<String, dynamic> request = item as Map<String, dynamic>;
        final String nombreAmigo = request['id_usuario_origen'] ?? 'Desconocido';
        return {
          'id': nombreAmigo,
          'nombre': nombreAmigo,
        };
      }).toList();
    }
    return [];
  }

  Future<void> enviarSolicitud(String username) async {
    final resp = await _api.post('/friends/request/$username', {});
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Error al enviar solicitud: ${resp.statusCode}');
    }
  }

  Future<void> responderSolicitud(String solicitudId, bool aceptar) async {
    final accion = aceptar ? 'accept' : 'reject';
    final resp = await _api.put('/friends/request/$solicitudId/$accion');
    if (resp.statusCode != 200) {
      throw Exception('Error al responder: ${resp.statusCode}');
    }
  }

  Future<void> eliminarAmigo(String amigoId) async {
    final resp = await _api.delete('/friends/$amigoId');
    if (resp.statusCode != 200) {
      throw Exception('Error al eliminar: ${resp.statusCode}');
    }
  }

  Future<List<Jugador>> buscarUsuarios(String query) async {
    final resp = await _api.get('/friends/search/$query');
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);

      return data.map((item) {
        // Comprobamos si el backend devuelve un objeto (Map) o un simple String
        if (item is Map<String, dynamic>) {
          return Jugador(
              nombre: item['nombre_usuario']?.toString() ?? 'Desconocido',
              coins: item['monedas'] != null ? int.tryParse(item['monedas'].toString()) ?? 0 : 0,
              avatarId : ''
          );
        } else {
          return Jugador(
              nombre: item.toString(),
              coins : 0,
              avatarId : ''
          );
        }
      }).toList();
    }
    return [];
  }
}