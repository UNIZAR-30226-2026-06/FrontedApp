import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/socket_service.dart';

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

      await authProvider.login(email, password);

      if (context.mounted) {
        final socketService = Provider.of<SocketService>(context, listen: false);
        final String token = authProvider.token ?? '';
        socketService.connect(token);

        _mostrarSnackBar(context, "¡Bienvenido de nuevo!", esError: false);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (context.mounted) {
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