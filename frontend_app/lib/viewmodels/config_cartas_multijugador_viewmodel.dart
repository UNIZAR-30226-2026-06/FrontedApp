import 'package:flutter/material.dart';
import 'partida_actual_viewmodel.dart';
import '../views/sala_espera_view.dart';

class ConfigCartasMultijugadorViewModel extends ChangeNotifier {
  final String modoTitulo;
  final bool isPrivate;

  ConfigCartasMultijugadorViewModel({
    required this.modoTitulo,
    required this.isPrivate,
  });

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

  String get subtitulo => isPrivate ? 'Partida Privada' : 'Partida Pública';
  String get detalleJugadores => '$_jugadores humanos';

  Future<void> comenzarPartida(
    BuildContext context,
    PartidaActualViewModel partidaVm, {
    String? jugadorLocal,
  }) async {
    if (_isCreating) return;

    _isCreating = true;
    notifyListeners();

    try {
      if (isPrivate) {
        await partidaVm.crearPartida(
          isPrivate: true,
          maxJugadores: _jugadores,
          modoCartasEspeciales: true,
          modoRoles: false,
          jugadorLocal: jugadorLocal,
        );
      } else {
        await partidaVm.unirsePartidaPublica(
          maxJugadores: _jugadores,
          mode: 'cards',
          jugadorLocal: jugadorLocal,
        );
      }

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SalaEsperaView(
            modoJuego: modoTitulo,
            requiereSalaLlena: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error al crear/unirse a sala de cartas: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
