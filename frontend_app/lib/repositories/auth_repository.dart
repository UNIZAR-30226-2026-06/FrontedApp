import 'dart:convert';
import 'package:flutter/foundation.dart';

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

      if (meResponse.statusCode == 200 && walletResponse.statusCode == 200) {
        final meData = json.decode(meResponse.body);
        final walletData = json.decode(walletResponse.body);

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

  Future<List<int>> obtenerAvataresComprados() async {
    try {
      final response = await _apiService.get('/usuarios/me/avatares');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e['id_avatar'] as int).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error obteniendo avatares comprados: $e");
      return [];
    }
  }

  Future<List<int>> obtenerEstilosComprados() async {
    try {
      final response = await _apiService.get('/usuarios/me/estilos');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e['id_estilo'] as int).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error obteniendo estilos comprados: $e");
      return [];
    }
  }
}
