import 'package:flutter/material.dart';

class RecuperarPasswordViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  bool _estaCargando = false;

  String? mensajeError;

  bool get estaCargando => _estaCargando;

  Future<bool> enviarEmail() async {
    final String email = emailController.text.trim();
    mensajeError = null;

    if (email.isEmpty || !email.contains('@')) {
      mensajeError = "Introduce un correo electrónico válido";
      notifyListeners();
      return false;
    }

    _setLoading(true);

    await Future.delayed(const Duration(seconds: 2));


    bool existeEmail = (email == "test@test.com");

    _setLoading(false);

    if (!existeEmail) {
      mensajeError = "Este correo no está registrado en nuestra arena";
      notifyListeners();
      return false;
    }

    return true;
  }

  void _setLoading(bool valor) {
    _estaCargando = valor;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}