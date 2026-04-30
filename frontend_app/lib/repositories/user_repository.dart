import 'dart:convert';
import '../models/jugador_model.dart';
import '../services/api_service.dart';
import '../models/tienda_item_model.dart';

class UserRepository {
  final ApiService _api;

  UserRepository(this._api);

  /// Obtiene los datos actualizados del perfil del usuario logueado
  Future<Jugador> getProfile() async {
    final response = await _api.get('/usuarios/me');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Jugador.fromJson(data);
    } else {
      throw Exception('Error al obtener perfil');
    }
  }

  /// Cambiar el avatar activo (PUT /usuarios/me/avatar)
  Future<void> updateAvatar(String avatarId) async {
    final response = await _api.put('/usuarios/me/avatar', {
      'id_avatar': avatarId,
    });

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'No se pudo cambiar el avatar');
    }
  }

  /// Cambiar el estilo activo (PUT /usuarios/me/estilo)
  Future<void> updateStyle(String estiloId) async {
    final response = await _api.put('/usuarios/me/estilo', {
      'id_estilo': estiloId,
    });

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'No se pudo cambiar el estilo');
    }
  }

  /// Obtener los avatares comprados del usuario (GET /usuarios/me/avatares)
  Future<List<TiendaItem>> getPurchasedAvatars() async {
    final response = await _api.get('/usuarios/me/avatares');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => TiendaItem(
        id: item['id'].toString(),
        titulo: item['nombre'] ?? '',
        precio: item['precio'] ?? 0,
        tipo: TiendaItemTipo.avatar,
        assetPath: item['assetPath'],
      )).toList();
    } else {
      throw Exception('Error al obtener avatares comprados');
    }
  }

  /// Obtener los estilos comprados del usuario (GET /usuarios/me/estilos)
  Future<List<TiendaItem>> getPurchasedStyles() async {
    final response = await _api.get('/usuarios/me/estilos');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => TiendaItem(
        id: item['id'].toString(),
        titulo: item['nombre'] ?? '',
        precio: item['precio'] ?? 0,
        tipo: TiendaItemTipo.diseno,
        assetPath: item['assetPath'],
      )).toList();
    } else {
      throw Exception('Error al obtener estilos comprados');
    }
  }

  /// Actualiza los datos del usuario en el backend (genérico)
  Future<void> updateProfile(Jugador jugador) async {
    final body = {
      'nombre': jugador.nombre,
      'correo': jugador.correo,
    };

    final response = await _api.put('/usuarios/me', body);

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar datos básicos del perfil');
    }
  }
}
