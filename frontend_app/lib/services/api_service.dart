import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _host = "10.0.2.2";
  final String baseUrl = "http://10.0.2.2:3000/api/v1"; //Localhost (cambiar a backend)
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