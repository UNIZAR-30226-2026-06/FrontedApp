import 'package:flutter/material.dart';

class SeleccionRolesViewModel extends ChangeNotifier {
  final String modoTitulo;
  final String modoSubtitulo;

  SeleccionRolesViewModel({
    required this.modoTitulo,
    required this.modoSubtitulo,
  });

  // Acciones “abiertas” para futuro:
  void jugarVsIA(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jugar vs IA (pendiente)')),
    );
  }

  void modoMultijugador(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modo Multijugador (pendiente)')),
    );
  }
}