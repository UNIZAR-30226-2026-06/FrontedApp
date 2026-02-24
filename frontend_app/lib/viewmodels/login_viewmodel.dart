import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier{
  final nombreController= TextEditingController();
  final passwordController = TextEditingController();

  bool _estaCargando = false;
  bool get estaCargando => _estaCargando;

  bool intentarLogin(){
    final nombre = nombreController.text;
    final password = passwordController.text;;

    if(nombre.isNotEmpty && password.isNotEmpty){
      _setLoading(true);
      print("Validando credenciales para el usuarion $nombre");
      // * VALIDAR CREDENCIALES
      _setLoading(false);
      return true; //Acceso concedido
    }
    //* MOSTRAR ERRORES
    return false; //Campos vacios, error
  }

  void _setLoading(bool valor){
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