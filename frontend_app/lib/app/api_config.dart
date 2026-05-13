class ApiConfig {
  // 🅰️ Modo LOCAL (Android emulator): habla con el backend que tienes
  //    corriendo en tu Mac (`npm run dev` en /backend, escucha en :3000).
  //    10.0.2.2 es el alias que el emulador usa para llegar al host.
  //    Tiene todos los fixes recientes (cleanup, withGameLock, bot_unido…).
  static const String baseUrl = "http://10.0.2.2:3000/api/v1";
  static const String socketUrl = "http://10.0.2.2:3000";

  // 🅱️ Para volver a Render (cuando el equipo backend haya hecho push y
  //    redeployed), descomenta estas dos líneas y comenta las de arriba:
  // static const String baseUrl = "https://backend-i797.onrender.com/api/v1";
  // static const String socketUrl = "https://backend-i797.onrender.com";

  // Endpoints
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String profile = "/profile";
  static const String tienda = "/shop/items";
  static const String amigos = "/friends";
  static const String solicitudes = "/friends/request/pending";
  static const String buscarUsuarios = "/friends/search";
}
