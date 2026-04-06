import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterViewModel extends ChangeNotifier {
  // Controladores de texto para la UI
  final nombreController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarpasswordController = TextEditingController();

  // Estado para mostrar un spinner en la UI si fuera necesario
  bool _cargando = false;
  bool get cargando => _cargando;

  /// MÉTODO PRINCIPAL: Es el que debe llamar tu botón de "Registrar"
  Future<void> ejecutarRegistro(BuildContext context) async {
    // 1. Validaciones locales previas (sin tocar el servidor aún)
    String? errorValidacion = _validarCampos();
    if (errorValidacion != null) {
      _mostrarSnackBar(context, errorValidacion, esError: true);
      return;
    }

    // 2. Obtener el AuthProvider (nuestro motor de datos)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 3. Intentar el registro real
    _setLoading(true);
    try {
      // Llamada al backend a través del flujo: ViewModel -> Provider -> Repository -> API
      await authProvider.register(
        nombreController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );

      // 4. Éxito: Navegación y mensaje
      if (context.mounted) {
        _mostrarSnackBar(context, "¡Usuario registrado con éxito!", esError: false);
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // 5. Error: El backend nos devuelve algo (ej: "El correo ya existe")
      if (context.mounted) {
        // Limpiamos el mensaje de error para que no diga "Exception: ..."
        final mensajeLimpio = e.toString().replaceAll('Exception: ', '');
        _mostrarSnackBar(context, mensajeLimpio, esError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Lógica de validación de formularios
  String? _validarCampos() {
    if (nombreController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      return "Todos los campos son obligatorios";
    }

    if (passwordController.text != confirmarpasswordController.text) {
      return "Las contraseñas no coinciden";
    }

    if (passwordController.text.length < 6) {
      return "La contraseña debe tener al menos 6 caracteres";
    }

    return null; // Todo OK
  }

  /// Utilidad para mostrar mensajes al usuario
  void _mostrarSnackBar(BuildContext context, String mensaje, {required bool esError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setLoading(bool valor) {
    _cargando = valor;
    notifyListeners();
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmarpasswordController.dispose();
    super.dispose();
  }
}