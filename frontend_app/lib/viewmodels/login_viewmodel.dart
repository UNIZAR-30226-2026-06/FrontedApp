import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final nombreController = TextEditingController();
  final passwordController = TextEditingController();

  bool _estaCargando = false;
  bool get estaCargando => _estaCargando;

  Future<bool> intentarLogin() async {
    final nombre = nombreController.text;
    final password = passwordController.text;

    if (nombre.isNotEmpty && password.isNotEmpty) {
      _setLoading(true);

      //PETICION AL SERVIDOR (hacerla cuando esté el back)
      await Future.delayed(const Duration(seconds: 2));

      debugPrint("Validando credenciales para: $nombre");

      _setLoading(false);
      return true; // Acceso concedido
    }
    return false; // Error: campos vacíos
  }

  void _setLoading(bool valor) {
    _estaCargando = valor;
    notifyListeners();
  }

  @override
  void dispose() {
    nombreController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}