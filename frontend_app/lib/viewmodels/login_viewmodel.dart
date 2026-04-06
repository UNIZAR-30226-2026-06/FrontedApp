import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginViewModel extends ChangeNotifier {
  // Quitamos la instancia manual del repositorio, usaremos el Provider
  final nombreController = TextEditingController();
  final passwordController = TextEditingController();

  bool _estaCargando = false;
  bool get estaCargando => _estaCargando;

  /// MÉTODO DE LOGIN REAL
  Future<void> ejecutarLogin(BuildContext context) async {
    final email = nombreController.text.trim();
    final password = passwordController.text;

    // Validación básica local
    if (email.isEmpty || password.isEmpty) {
      _mostrarSnackBar(context, "Por favor, introduce tus credenciales", esError: true);
      return;
    }

    // Obtenemos el motor de autenticación
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    _setLoading(true);

    try {
      // LLAMADA REAL AL BACKEND
      // Nota: nombreController aquí actúa como el campo de Email/Usuario
      await authProvider.login(email, password);

      if (context.mounted) {
        _mostrarSnackBar(context, "¡Bienvenido de nuevo!", esError: false);
        // Navegamos al Home y limpiamos el historial para que no pueda volver atrás al login
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (context.mounted) {
        // Si el backend devuelve 401, el error dirá algo como "Invalid credentials"
        String mensaje = e.toString().replaceAll('Exception: ', '');
        if (mensaje.contains("401")) mensaje = "Usuario o contraseña incorrectos";

        _mostrarSnackBar(context, mensaje, esError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool valor) {
    _estaCargando = valor;
    notifyListeners();
  }

  void _mostrarSnackBar(BuildContext context, String mensaje, {required bool esError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

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