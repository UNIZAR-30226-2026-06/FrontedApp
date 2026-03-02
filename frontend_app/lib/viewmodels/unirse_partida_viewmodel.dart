import 'package:flutter/material.dart';

class UnirsePartidaViewModel extends ChangeNotifier {
  final String modoTitulo;
  final String modoSubtitulo;

  UnirsePartidaViewModel({
    required this.modoTitulo,
    required this.modoSubtitulo,
  });

  String _codigo = '';
  String get codigo => _codigo;

  void setCodigo(String value) {
    _codigo = value;
    notifyListeners();
  }

  void unirse(BuildContext context) {
    // Acción abierta por ahora, pero el código queda guardado en _codigo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unirse con código: $_codigo (pendiente)')),
    );
  }
}