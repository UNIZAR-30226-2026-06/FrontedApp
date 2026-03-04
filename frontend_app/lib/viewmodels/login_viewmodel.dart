import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final nombreController = TextEditingController();
  final passwordController = TextEditingController();

  bool _estaCargando = false;
  bool get estaCargando => _estaCargando;

  /// Intenta realizar el login.
  /// Devolverá [true] si los campos son válidos para permitir la navegación.
  Future<bool> intentarLogin() async {
    final nombre = nombreController.text.trim();
    final password = passwordController.text.trim();

    // 1. Validación básica de presencia de datos
    if (nombre.isEmpty || password.isEmpty) {
      debugPrint("Error: Campos obligatorios vacíos.");
      return false;
    }

    _setLoading(true);

    try {
      // 2. Simulación de latencia de red (Simulamos la llamada al Back-end)
      // Aumentamos a 1.5s para que se vea el Spinner amarillo que pusimos en la View
      await Future.delayed(const Duration(milliseconds: 1500));

      debugPrint("Login exitoso para el usuario: $nombre");

      _setLoading(false);
      return true; // Acceso concedido: La View recibirá este true y hará el Navigator.push

    } catch (e) {
      debugPrint("Error inesperado en el proceso de login: $e");
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool valor) {
    _estaCargando = valor;
    notifyListeners();
  }

  /// Limpia los campos de texto (útil si quieres resetear el formulario)
  void limpiarCampos() {
    nombreController.clear();
    passwordController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    nombreController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}