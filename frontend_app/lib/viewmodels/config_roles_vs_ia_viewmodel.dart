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

  Future<void> comenzarPartida(BuildContext context, PartidaActualViewModel partidaVm) async {
    try {
      print("Iniciando peticion al servidor...");
      await partidaVm.crearPartida(
          isPrivate: true,
          jugadorLocal: "Jugador Beta",
          maxJugadores: _jugadores,
      );

      print("crearPartida ha terminado correctamente");

      final int botsASpawnear = _jugadores - 1;

      print("Llamando a iniciarPartida (Socket) con $botsASpawnear bots...");

      partidaVm.iniciarPartida(
          vsIA: true,
          cantidadBots: botsASpawnear
      );


      print("Comprobando context.mounted: ${context.mounted}");

      if (context.mounted) {
        print("Navegando al TableroView...");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TableroView(),
          ),
        );
      }else{
        print("EL CONTEXT YA NO ESTA MONTADO; NO PUEDO NAVEGAR"); // BORRAR
      }
    } catch (e) {
      debugPrint("Error al configurar partida IA: $e");
    }
  }
}