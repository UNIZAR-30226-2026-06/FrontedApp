import 'package:flutter/material.dart';

class MultijugadorMenuCartasViewModel extends ChangeNotifier {
  final String modoTitulo;
  final String modoSubtitulo1;
  final String modoSubtitulo2;

  MultijugadorMenuCartasViewModel({
    required this.modoTitulo,
    required this.modoSubtitulo1,
    required this.modoSubtitulo2,
  });

  void crearPartida(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crear partida (pendiente)')),
    );
  }
}