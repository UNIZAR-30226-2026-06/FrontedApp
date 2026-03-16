import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../services/api_service.dart';
import '../models/usuario_model.dart';

class LoginViewModel extends ChangeNotifier {
  // Dejamos el repo instanciado pero no lo usaremos en el bypass
  final AuthRepository _authRepo = AuthRepository(ApiService());

  final nombreController = TextEditingController();
  final passwordController = TextEditingController();

  bool _estaCargando = false;
  bool get estaCargando => _estaCargando;

  String? _mensajeError;
  String? get mensajeError => _mensajeError;

  UsuarioModel? _usuarioLogueado;
  UsuarioModel? get usuarioLogueado => _usuarioLogueado;

  /// Método de login con Bypass provisional
  Future<bool> intentarLogin() async {
    final nombre = nombreController.text.trim();
    // final password = passwordController.text.trim(); // Comentado por ahora

    _setLoading(true);
    _mensajeError = null;

    try {
      // === BLOQUE COMENTADO: CONEXIÓN REAL CON EL SERVIDOR ===
      /*
      _usuarioLogueado = await _authRepo.login(nombre, password);
      debugPrint("Login real exitoso para: ${_usuarioLogueado?.nombreUsuario}");
      */
      // =======================================================

      // === BYPASS PROVISIONAL (MAGIA) ===
      // Creamos el usuario sin token para que no dé errores
      _usuarioLogueado = UsuarioModel(
        nombreUsuario: nombre.isEmpty ? "Invitado" : nombre,
        correo: "${nombre.isEmpty ? 'guest' : nombre}@test.com",
        monedas: 999, // Monedas de regalo para testear
      );

      // Simulamos latencia para que veas el spinner un momento
      await Future.delayed(const Duration(milliseconds: 600));

      debugPrint("Bypass activo: Entrando como ${_usuarioLogueado?.nombreUsuario}");

      _setLoading(false);
      return true; // ESTO ES LO QUE HACE QUE LA VISTA NAVEGUE AL HOME
      // ==================================

    } catch (e) {
      _mensajeError = "Error inesperado en el bypass";
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool valor) {
    _estaCargando = valor;
    notifyListeners();
  }

  void limpiarCampos() {
    nombreController.clear();
    passwordController.clear();
    _mensajeError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    nombreController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}