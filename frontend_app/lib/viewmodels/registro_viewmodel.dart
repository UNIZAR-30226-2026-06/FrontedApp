import 'package:flutter/material.dart';
 import '../views/login_view.dart';

class RegisterViewModel extends ChangeNotifier {
  final nombreController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmarpasswordController = TextEditingController();

  // --- NUEVO MÉTODO PARA NAVEGACIÓN ---
  Future<void> ejecutarRegistro(BuildContext context) async {
    bool exito = await registrarUsuario();

    if (exito) {
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<bool> registrarUsuario() async {
    final String nombre = nombreController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmarPassword = confirmarpasswordController.text;

    List<String> errores = [];

    if(nombreController.text.isEmpty) errores.add("nombre");
    if(emailController.text.isEmpty) errores.add("email");
    if(passwordController.text.isEmpty) errores.add("contraseña");
    if(confirmarpasswordController.text.isEmpty) errores.add("confirmar contraseña");

    if(errores.isNotEmpty){
      // He añadido 'default' para que no falle si hay 4 errores
      switch(errores.length){
        case 1:
          _showErrorMessage("Falta el campo ${errores[0]}");
          break;
        case 2:
          _showErrorMessage("Faltan los campos: ${errores.join(' y ')}");
          break;
        default:
          _showErrorMessage("Faltan varios campos. Introduce los datos");
          break;
      }
      return false;
    }

    if(password != confirmarPassword){
      _showErrorMessage("Contraseñas no coincidentes.");
      return false;
    }

    bool exito = await _enviarAlBackend(nombre, email, password);
    return exito;
  }

  Future<bool> _enviarAlBackend(String nombre, String email, String password) async {
    // Simulación de delay de red
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  void _showErrorMessage(String mensaje){
    debugPrint("ALERTA DE VALIDACIÓN: $mensaje");
  }

  @override
  void dispose(){
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmarpasswordController.dispose();
    super.dispose();
  }
}