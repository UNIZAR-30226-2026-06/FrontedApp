import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'partida_actual_viewmodel.dart';
import '../providers/auth_provider.dart';
import '../views/tablero_view.dart';

class ConfigRolesVsIaViewModel extends ChangeNotifier {
  final String modoTitulo;

  ConfigRolesVsIaViewModel({required this.modoTitulo});

  int _jugadores = 2;
  int get jugadores => _jugadores;
  bool _cargando = false;

  bool _reglasAbiertas = false;
  bool get reglasAbiertas => _reglasAbiertas;
  bool get cargando => _cargando;

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
    if (_cargando) return; // evita doble disparo al pulsar dos veces "comenzar"
    try {
      _cargando = true;
      notifyListeners();

      final usuario = context.read<AuthProvider>().usuario;
      await partidaVm.crearPartida(
        isPrivate: true,
        jugadorLocal: usuario?.nombreUsuario,
        maxJugadores: _jugadores,
      );


      final int botsASpawnear = _jugadores - 1;

      for (int i = 0; i < botsASpawnear; i++) {
        debugPrint("Añadiendo bot ${i + 1} de $botsASpawnear...");
        await partidaVm.anyadirBot();
      }

      // Esperamos (event-driven) a que el backend haya emitido `bot_unido`
      // para CADA bot. Hasta que `jugadores.length == _jugadores` no
      // arrancamos. Sin esto, `start_game` puede llegar al backend antes de
      // que el último `add-bot` haya hecho COMMIT → race que dejaba
      // jugadores con la mano vacía.
      final ok = await partidaVm.esperarHastaQueHayaJugadores(
        _jugadores,
        timeout: const Duration(seconds: 5),
      );
      if (!ok) {
        debugPrint(
          'No llegaron todos los bot_unido a tiempo; iniciando igualmente',
        );
      }

      partidaVm.iniciarPartida(
          vsIA: true,
          cantidadBots: botsASpawnear
      );

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TableroView()),
        );
      }
    } catch (e) {
      debugPrint("Error al configurar partida IA: $e");
    } finally {
      if(context.mounted) {
        _cargando = false;
        notifyListeners();
      }
    }
  }
}