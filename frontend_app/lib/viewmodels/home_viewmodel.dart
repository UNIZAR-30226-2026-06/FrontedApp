import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../screens/tienda_screen.dart';

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

  /// ✅ Navegación real a Tienda (sin fork, sin nada raro)
  void openTienda(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TiendaScreen(jugador: jugador),
      ),
    );
  }
}