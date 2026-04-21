import 'dart:convert';
import '../models/jugador_model.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService _api;

  UserRepository(this._api);

  /// Obtiene los datos actualizados del perfil del usuario logueado
  Future<Jugador> getProfile() async {
    final response = await _api.get('/profile'); // Ajusta segun tu endpoint real

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Jugador.fromJson(data);
    } else {
      throw Exception('Error al obtener perfil');
    }
  }

  /// Actualiza los datos del usuario en el backend (monedas, avatar, etc.)
  Future<void> updateProfile(Jugador jugador) async {
    // Adaptamos el objeto Jugador al formato que espera tu backend
    final body = {
      'monedas': jugador.coins,
      'avatar': jugador.avatarId,
      'estilo': jugador.skinId,
    };

    final response = await _api.put('/profile', body); // Ajusta segun tu endpoint real

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar perfil en el servidor');
    }
  }
}
