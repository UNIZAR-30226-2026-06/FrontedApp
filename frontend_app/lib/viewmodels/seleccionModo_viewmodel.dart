import 'package:flutter/material.dart';
import '../views/config_roles_vs_ia_view.dart';
import '../views/multijugador_menu_view.dart';

class SeleccionModoViewModel extends ChangeNotifier {
  final String tituloModo = "Modo con roles";
  final String subtituloPartida = "Partida Privada";

  void volver(BuildContext context) {
    Navigator.pop(context);
  }

  void jugarVsIA(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfigRolesVsIaView(modoTitulo: tituloModo),
      ),
    );
  }

  void jugarVsJugador(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultijugadorMenuView(
          modoTitulo: tituloModo,
          modoSubtitulo1: 'Modo Multijugador',
          modoSubtitulo2: subtituloPartida,
        ),
      ),
    );
  }
}