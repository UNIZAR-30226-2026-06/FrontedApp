import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app/api_config.dart';

class ApiService {
  // Leemos la URL desde ApiConfig (misma fuente que SocketService) para que
  // HTTP y socket hablen siempre con el mismo backend. Cambiar la URL en un
  // solo sitio (api_config.dart) basta para alternar entre local y Render.
  final String baseUrl = ApiConfig.baseUrl;
  String? _token;

  void setToken(String token) => _token = token;

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
      body: json.encode(body),
    );
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(
      url,
      headers: {
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(
      url,
      headers: {
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
    );
  }

  Future<http.Response> put(String endpoint, [Map<String, dynamic>? body]) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      },
      body: body != null ? json.encode(body) : null,
    );
  }
}