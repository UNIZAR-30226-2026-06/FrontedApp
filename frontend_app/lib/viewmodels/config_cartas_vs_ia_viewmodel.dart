import 'package:flutter/material.dart';

class ConfigCartasVsIaViewModel extends ChangeNotifier {
  final String modoTitulo; // "Modo cartas"

  ConfigCartasVsIaViewModel({required this.modoTitulo});

  int _jugadores = 2;
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
    final ia = _jugadores - 1;
    return '1 humano + $ia IA';
  }

  void comenzarPartida(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comenzar partida cartas vs IA (pendiente)')),
    );
  }
}