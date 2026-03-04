import 'package:flutter/material.dart';
import 'views/login_view.dart'; // Asegúrate de que la ruta sea correcta

void main() {
  runApp(const UnoArenaApp());
}

class UnoArenaApp extends StatelessWidget {
  const UnoArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNO Arena',
      debugShowCheckedModeBanner: false, // Quita la banda roja de debug
      theme: ThemeData(
        brightness: Brightness.dark, // Para que los diálogos y textos se adapten al fondo oscuro
        primarySwatch: Colors.orange,
      ),
      home: const LoginView(), // Comenzamos en el Login
    );
  }
}