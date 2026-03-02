import 'package:flutter/material.dart';

class SeleccionModoViewModel extends ChangeNotifier {
  // Datos que la View leerá del ViewModel
  final String tituloModo = "Modo con roles";
  final String subtituloPartida = "Partida Privada";

  void volver(BuildContext context) {
    Navigator.pop(context);
  }

  void jugarVsIA(BuildContext context) {
    debugPrint("Navegando a la pantalla de jugar contra la IA");
    // Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaIA()));
  }

  void jugarVsJugador(BuildContext context) {
    debugPrint("Navegando a la pantalla de jugar contra jugador");
    // Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaMulti()));
  }
}