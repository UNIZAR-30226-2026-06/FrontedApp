import 'package:flutter/material.dart';

class ConfigCartasMultijugadorViewModel extends ChangeNotifier {
  final String modoTitulo;

  ConfigCartasMultijugadorViewModel({required this.modoTitulo});

  int _jugadores = 2;
  int get jugadores => _jugadores;

  bool _reglasAbiertas = false;
  bool get reglasAbiertas => _reglasAbiertas;

  final String codigoPartida = 'C7890';

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

  String get subtitulo => 'Modo multijugador';
  String get detalleJugadores => '$_jugadores humanos';

  void comenzarPartida(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comenzar partida cartas multijugador (pendiente)')),
    );
  }
}