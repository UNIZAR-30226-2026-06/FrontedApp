import 'dart:convert';
import '../services/api_service.dart';
import '../models/usuario_model.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<UsuarioModel> register(String username, String email,
      String password) async {
    final response = await _apiService.post('/auth/register', {
      'nombre_usuario': username,
      'correo': email,
      'password': password,
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = json.decode(response.body);
      final String token = data['token'];
      _apiService.setToken(token);

      final meResponse = await _apiService.get('/auth/me');
      final walletResponse = await _apiService.get('/wallet/balance');

      if (meResponse.statusCode == 200 && walletResponse.statusCode == 200) {
        final meData = json.decode(meResponse.body);
        final walletData = json.decode(walletResponse.body);

        // Juntamos los datos: inyectamos las "coins" del wallet como "monedas"
        meData['monedas'] = walletData['coins'] ?? 0;

        return UsuarioModel.fromJson(meData, token: token);
      } else {
        throw Exception(
            'Cuenta creada, pero falló al cargar el perfil o la cartera.');
      }
    } else {
      final error = json.decode(response.body);
      throw Exception(
          error['error'] ?? error['message'] ?? 'Error al registrar usuario');
    }
  }

  Future<UsuarioModel> login(String username, String password) async {
    final response = await _apiService.post('/auth/login', {
      'nombre_usuario': username,
      'password': password,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      final String token = data['token'];
      _apiService.setToken(token);

      final meResponse = await _apiService.get('/auth/me');
      final walletResponse = await _apiService.get('/wallet/balance');

      print('🚨 --- ESPIONAJE DE APIS --- 🚨');
      print('Ruta /auth/me -> Status: ${meResponse.statusCode} | Cuerpo: ${meResponse.body}');
      print('Ruta /wallet  -> Status: ${walletResponse.statusCode} | Cuerpo: ${walletResponse.body}');

      if (meResponse.statusCode == 200 && walletResponse.statusCode == 200) {
        final meData = json.decode(meResponse.body);
        final walletData = json.decode(walletResponse.body);

        // Juntamos los datos: inyectamos las "coins" del wallet como "monedas"
        meData['monedas'] = walletData['coins'] ?? 0;

        return UsuarioModel.fromJson(meData, token: token);
      } else {
        throw Exception(
            'Sesión iniciada, pero falló al descargar el perfil o la cartera.');
      }
    } else {
      final error = json.decode(response.body);
      throw Exception(
          error['error'] ?? error['message'] ?? 'Error al iniciar sesión');
    }
  }
}