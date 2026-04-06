import 'dart:convert';
import '../services/api_service.dart';
import '../models/usuario_model.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  //Registro de un nuevo usuario
  Future<UsuarioModel> register(String username, String email, String password) async {
    final response = await _apiService.post('/auth/register', {
      'nombre_usuario': username,
      'correo': email,
      'password': password,
    });

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final token = data['token'];
      _apiService.setToken(token);

      return UsuarioModel.fromJson(data['user'], token: token);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Error al registrar usuario');
    }
  }

  //Login de un usuario
  Future<UsuarioModel> login(String username, String password) async {
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