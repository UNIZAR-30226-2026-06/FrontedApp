import 'package:flutter/material.dart';
import 'partida_actual_viewmodel.dart';
import '../views/sala_espera_view.dart';

class ConfigRolesMultijugadorViewModel extends ChangeNotifier {
  final String modoTitulo;

  ConfigRolesMultijugadorViewModel({required this.modoTitulo});

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

  String get subtitulo => 'Modo multijugador';

  String get detalleJugadores => '$_jugadores humanos';


  void comenzarPartida(BuildContext context, PartidaActualViewModel partidaVm) {
    // 1. Aquí podrías llamar al backend para notificar que la configuración ha terminado
    // partidaVm.actualizarConfiguracion(jugadores: _jugadores);

    // 2. Navegamos a la Sala de Espera que acabamos de crear
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalaEsperaView(modoJuego: modoTitulo),
      ),
    );
  }
}