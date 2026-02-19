import 'package:flutter/material.dart';
import '../models/jugador_model.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required Jugador jugadorInicial,
  }) : _jugador = jugadorInicial;

  Jugador _jugador;
  Jugador get jugador => _jugador;

  int _bottomIndex = 0;
  int get bottomIndex => _bottomIndex;

  // En el futuro podrás cargarlo desde backend / storage
  void setJugador(Jugador nuevo) {
    _jugador = nuevo;
    notifyListeners();
  }

  void selectBottomTab(int index) {
    _bottomIndex = index;
    notifyListeners();
  }

  /// Placeholder de navegación: lo dejamos “abierto”
  void onTapAction(BuildContext context, String destino) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ir a: $destino (pendiente)')),
    );
  }
}