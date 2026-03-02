import 'package:flutter/material.dart';

class ConfigRolesVsIaViewModel extends ChangeNotifier {
  final String modoTitulo; // "Modo con roles"

  ConfigRolesVsIaViewModel({required this.modoTitulo});

  int _jugadores = 2; // 2 = 1 humano + 1 IA
  int get jugadores => _jugadores;

  bool _reglasAbiertas = false;
  bool get reglasAbiertas => _reglasAbiertas;

  void inc() {
    if (_jugadores < 4) {
      _jugadores++;
      notifyListeners();
    }
  }

  void dec() {
    if (_jugadores > 2) {
      _jugadores--;
      notifyListeners();
    }
  }

  void toggleReglas() {
    _reglasAbiertas = !_reglasAbiertas;
    notifyListeners();
  }

  String get subtitulo => 'Partida vs IA';

  String get detalleJugadores {
    // En tu mock: "1 humano + 1 IA"
    // Si sube a 3/4: interpretamos 1 humano + (n-1) IA
    final ia = _jugadores - 1;
    return '1 humano + $ia IA';
  }

  void comenzarPartida(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comenzar partida vs IA (pendiente)')),
    );
  }
}