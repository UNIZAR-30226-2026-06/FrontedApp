import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Cambia 'localhost' por tu IP local si pruebas en un móvil físico
  final String baseUrl = "http://localhost:3000/api/v1";
  String? _token;

  void setToken(String token) => _token = token;

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token', // Requerido por vuestro middleware
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
}