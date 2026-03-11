import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../services/api_service.dart';
import '../models/usuario_model.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository(ApiService());

  final nombreController = TextEditingController();
  final passwordController = TextEditingController();

  bool _estaCargando = false;
  bool get estaCargando => _estaCargando;

  String? _mensajeError;
  String? get mensajeError => _mensajeError;

  UsuarioModel? _usuarioLogueado;
  UsuarioModel? get usuarioLogueado => _usuarioLogueado;

  /// Intenta realizar el login real contra el backend de Node.js.
  Future<bool> intentarLogin() async {
    final nombre = nombreController.text.trim();
    final password = passwordController.text.trim();

    if (nombre.isEmpty || password.isEmpty) {
      _mensajeError = "Campos obligatorios vacíos";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _mensajeError = null; // Limpiamos errores previos

    try {
      // Realizamos la petición HTTP real al servidor
      // El repositorio ya se encarga de gestionar el JSON y el Token
      _usuarioLogueado = await _authRepo.login(nombre, password);

      debugPrint("Login exitoso en DB para: ${_usuarioLogueado?.nombreUsuario}");

      _setLoading(false);
      return true; // Éxito: La View permitirá la navegación al Home

    } catch (e) {
      // Capturamos los errores devueltos por auth.controller.js
      _mensajeError = e.toString().contains("Exception: ")
          ? e.toString().split("Exception: ")[1]
          : "Error de conexión con el servidor";

      debugPrint("Error en el login: $_mensajeError");
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