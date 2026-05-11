import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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

  Future<void> comenzarPartida(
      BuildContext context,
      PartidaActualViewModel partidaVm,
      [String? jugadorLocalFallback]
      ) async {
    bool navegoConExito = false;

    try {
      _cargando = true;
      notifyListeners();

      // 1. Aseguramos la identidad exacta consultando el AuthProvider
      final auth = context.read<AuthProvider>();
      final String nombreReal = auth.usuario?.nombreUsuario ?? jugadorLocalFallback ?? 'yo';

      // 2. Creamos la partida con la flag modoRoles en TRUE
      await partidaVm.crearPartida(
        isPrivate: true,
        jugadorLocal: nombreReal,
        maxJugadores: _jugadores,
        modoRoles: true, // 🔥 ESTO ACTIVA LAS HABILIDADES EN EL BACKEND
      ).timeout(const Duration(seconds: 10));

      final int botsASpawnear = _jugadores - 1;

      // 3. Añadimos los bots con un pequeño respiro para que la base de datos no sufra
      for (int i = 0; i < botsASpawnear; i++) {
        debugPrint("Añadiendo bot ${i + 1} de $botsASpawnear...");
        await partidaVm.anyadirBot();
        await Future.delayed(const Duration(milliseconds: 300)); // 🔥 Respiro al servidor
      }

      // 4. Disparamos el inicio
      partidaVm.iniciarPartida(
        vsIA: true,
        cantidadBots: botsASpawnear,
      );


      await Future.delayed(const Duration(seconds: 1));

      if (context.mounted) {
        navegoConExito = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TableroView()),
        );
      }
    } catch (e) {
      debugPrint("Error al configurar partida roles IA: $e");
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