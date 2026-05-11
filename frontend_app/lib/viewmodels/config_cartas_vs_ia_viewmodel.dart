import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'partida_actual_viewmodel.dart';
import '../views/tablero_view.dart';

class ConfigCartasVsIaViewModel extends ChangeNotifier {
  final String modoTitulo;

  ConfigCartasVsIaViewModel({required this.modoTitulo});

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

  Future<void> comenzarPartida(
      BuildContext context,
      PartidaActualViewModel partidaVm,
      [String? jugadorLocalFallback] // Lo hacemos opcional para no romper tu vista
      ) async {
    bool navegoConExito = false;

    try {
      _cargando = true;
      notifyListeners();

      final auth = context.read<AuthProvider>();
      final String nombreReal = auth.usuario?.nombreUsuario ?? jugadorLocalFallback ?? 'yo';

      await partidaVm.crearPartida(
        isPrivate: true,
        jugadorLocal: nombreReal,
        maxJugadores: _jugadores,
        modoRoles: false,
      ).timeout(const Duration(seconds: 10));

      final int botsASpawnear = _jugadores - 1;

      for (int i = 0; i < botsASpawnear; i++) {
        debugPrint("Añadiendo bot ${i + 1} de $botsASpawnear...");
        await partidaVm.anyadirBot();
      }

      partidaVm.iniciarPartida(
        vsIA: true,
        cantidadBots: botsASpawnear,
      );

      if (context.mounted) {
        navegoConExito = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TableroView()),
        );
      }
    } catch (e) {
      debugPrint("Error al configurar partida cartas IA: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de conexión con el servidor. Inténtalo de nuevo.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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