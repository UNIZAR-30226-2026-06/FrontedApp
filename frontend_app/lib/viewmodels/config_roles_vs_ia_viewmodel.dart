import 'package:flutter/material.dart';
import 'partida_actual_viewmodel.dart';
import '../views/tablero_view.dart';

class ConfigRolesVsIaViewModel extends ChangeNotifier {
  final String modoTitulo;

  ConfigRolesVsIaViewModel({required this.modoTitulo});

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

  void comenzarPartida(BuildContext context, PartidaActualViewModel partidaVm) {
    final int botsASpawnear = _jugadores - 1;

    partidaVm.iniciarPartida(
        vsIA: true,
        cantidadBots: botsASpawnear
    );

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TableroView(),
        ),
      );
    }
  }
}