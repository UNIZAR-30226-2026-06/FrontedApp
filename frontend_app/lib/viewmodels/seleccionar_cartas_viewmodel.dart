import 'package:flutter/material.dart';

class SeleccionarCartasViewModel extends ChangeNotifier {
  final String modoTitulo;
  final String modoSubtitulo;

  SeleccionarCartasViewModel({
    required this.modoTitulo,
    required this.modoSubtitulo,
  });

  void jugarVsIA(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Jugar vs IA (pendiente)')),
    );
  }
}