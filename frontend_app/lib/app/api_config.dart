class ApiConfig {
  // Cambia esta URL cuando tengas tu backend definitivo
  static const String baseUrl = "http://10.0.2.2:3000/api/v1";

  // Endpoints
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String profile = "/profile";
  static const String tienda = "/shop/items";
  static const String amigos = "/friends";
  static const String solicitudes = "/friends/request/pending";
  static const String buscarUsuarios = "/friends/search";
}
