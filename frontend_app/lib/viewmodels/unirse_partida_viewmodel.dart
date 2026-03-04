import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../views/tablero_view.dart';

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

  // Objeto de prueba para la Beta
  final miPerfil = Jugador(
    nombre: "Jugador Beta",
    coins: 100,
    avatarId: "user_avatar",
    skinId: "default",
  );

  void unirse(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableroView(miPerfil: miPerfil),
      ),
    );

    // Opcional: Feedback visual en consola
    debugPrint('Uniéndose a partida $modoTitulo con código: $_codigo');
  }
}