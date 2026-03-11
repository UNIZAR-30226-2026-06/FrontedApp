import 'dart:convert';
import '../services/api_service.dart';
import '../models/usuario_model.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<UsuarioModel> login(String username, String password) async {
    // Cuerpo esperado por vuestro backend: { nombre_usuario, password }
    final response = await _apiService.post('/auth/login', {
      'nombre_usuario': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      _apiService.setToken(token); // Guardamos el token para futuras peticiones

      return UsuarioModel.fromJson(data['user'], token: token);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Error al iniciar sesión');
    }
  }
}