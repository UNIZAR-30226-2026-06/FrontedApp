import 'package:flutter/material.dart';

// ChangeNotifier avisa a la interfaz cuando algo cambie en la pantalla
class SeleccionModoViewModel extends ChangeNotifier{

  void volver(BuildContext context){ //Volver a la pantalla anterior
    Navigator.pop(context);
  }

  void jugarVsIA(BuildContext context){
    debugPrint("Navegando a la pantalla de jugar contra la IA");
    // Navigator.push();
  }

  void jugarVsJugador(BuildContext context){
    debugPrint("Navegando a la pantalla de jugar contra jugador");
    // Navigator.push();
  }
}