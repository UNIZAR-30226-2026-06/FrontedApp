import 'package:flutter/material.dart';
import 'partida_actual_viewmodel.dart';
import '../views/tablero_view.dart';

class ConfigRolesVsIaViewModel extends ChangeNotifier {
  final String modoTitulo;

  ConfigRolesVsIaViewModel({required this.modoTitulo});

  int _jugadores = 2;
  int get jugadores => _jugadores;

  bool _cargando = false;
  bool get cargando => _cargando;

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

  Future<void> comenzarPartida(BuildContext context, PartidaActualViewModel partidaVm) async {
    bool navegoConExito = false;

    try {
      _cargando = true;
      notifyListeners();

      await partidaVm.crearPartida(
        isPrivate: true,
        jugadorLocal: "Jugador Beta",
        maxJugadores: _jugadores,
      ).timeout(const Duration(seconds: 10));

      final int botsASpawnear = _jugadores - 1;

      // 2. Añadir los bots secuencialmente
      for (int i = 0; i < botsASpawnear; i++) {
        debugPrint("Añadiendo bot ${i + 1} de $botsASpawnear...");
        await partidaVm.anyadirBot();
      }

      partidaVm.iniciarPartida(
          vsIA: true,
          cantidadBots: botsASpawnear
      );

      if (context.mounted) {
        navegoConExito = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TableroView()),
        );
      }
    } catch (e) {
      debugPrint("Error al configurar partida IA: $e");
    } finally {
      if (!navegoConExito) {
        _cargando = false;
        try {
          notifyListeners();
        } catch (_) {}
      }
    }
  }
}