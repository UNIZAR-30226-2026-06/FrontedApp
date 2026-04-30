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

  bool _isCreating = false;
  bool get isCreating => _isCreating;

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

  Future<void> comenzarPartida(BuildContext context, PartidaActualViewModel partidaVm, {bool isPrivate = true}) async {
    if (_isCreating) return;

    _isCreating = true;
    notifyListeners();

    try {
      debugPrint("⏱️ 1. Solicitando al servidor crear sala multijugador...");

      await partidaVm.crearPartida(
        isPrivate: isPrivate,
        maxJugadores: _jugadores,
      );

      debugPrint("Sala creada. Código: ${partidaVm.partidaActual?.code}");

      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SalaEsperaView(modoJuego: modoTitulo),
        ),
      );

    } catch (e) {
      debugPrint("❌ Error al crear la sala: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión con el servidor. Inténtalo de nuevo.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }
}