import 'dart:convert';
import '../models/jugador_model.dart';
import '../services/api_service.dart';
import '../models/tienda_item_model.dart';

class UserRepository {
  final ApiService _api;

  UserRepository(this._api);

  String? _normalizeStoreImage(dynamic value) {
    final image = value?.toString().trim();
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('http') || image.startsWith('assets/')) return image;
    if (image.contains('/') || image.contains('\\')) return image;
    if (image.contains('.')) return 'assets/images/shop/$image';
    return image;
  }

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
      'avatar_id': int.tryParse(avatarId) ?? avatarId,
    });

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'No se pudo cambiar el avatar');
    }
  }

  /// Cambiar el estilo activo (PUT /usuarios/me/estilo)
  Future<void> updateStyle(String estiloId) async {
    final response = await _api.put('/usuarios/me/estilo', {
      'estilo_id': int.tryParse(estiloId) ?? estiloId,
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
        id: (item['id_avatar'] ?? item['id'] ?? item['avatar_id']).toString(),
        titulo: item['nombre'] ?? '',
        precio: item['precioavatar'] ?? item['precio'] ?? 0,
        tipo: TiendaItemTipo.avatar,
        assetPath: item['image']?.toString() ?? item['assetPath']?.toString(),
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
        id: (item['id_estilo'] ?? item['id'] ?? item['estilo_id']).toString(),
        titulo: item['nombre'] ?? '',
        precio: item['precioestilo'] ?? item['precio'] ?? 0,
        tipo: TiendaItemTipo.diseno,
        assetPath: _normalizeStoreImage(item['image'] ?? item['assetPath']),
      )).toList();
    } else {
      throw Exception('Error al obtener estilos comprados');
    }
  }

  /// Cambia la contraseña del usuario autenticado.
  /// PUT `/usuarios/me/password` con `{contrasena_actual, nueva_contrasena}`.
  /// Lanza con el mensaje específico del backend (e.g. "Contraseña actual
  /// incorrecta") para que la UI lo muestre tal cual.
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final response = await _api.put('/usuarios/me/password', {
      'contrasena_actual': currentPassword,
      'nueva_contrasena': newPassword,
    });

    if (response.statusCode != 200) {
      final body = response.body.isNotEmpty
          ? (json.decode(response.body) as Map<String, dynamic>)
          : <String, dynamic>{};
      throw Exception(
        body['error'] ?? body['message'] ?? 'No se pudo cambiar la contraseña',
      );
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
