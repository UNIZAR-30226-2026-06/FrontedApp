import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../views/tienda_view.dart';
import '../views/perfil_view.dart';
import '../views/amigos_view.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required Jugador jugadorInicial,
  }) : _jugador = jugadorInicial;

  Jugador _jugador;
  Jugador get jugador => _jugador;

  int _bottomIndex = 0;
  int get bottomIndex => _bottomIndex;

  void setJugador(Jugador nuevo) {
    _jugador = nuevo;
    notifyListeners();
  }

  void selectBottomTab(int index) {
    _bottomIndex = index;
    notifyListeners();
  }

  void onTapAction(BuildContext context, String destino) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ir a: $destino (pendiente)')),
    );
  }

  void openTienda(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TiendaScreen(jugador: jugador),
      ),
    );
  }

  /// ✅ PERFIL: abre pantalla y si vuelve con Jugador actualizado, lo guarda
  Future<void> openPerfil(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PerfilScreen(jugador: jugador),
      ),
    );

    if (result is Jugador) {
      setJugador(result);
    }
  }

  /// ✅ AMIGOS: abre pantalla y si vuelve con Jugador actualizado (friendIds/requestIds), lo guarda
  Future<void> openAmigos(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AmigosScreen(jugador: jugador),
      ),
    );

    if (result is Jugador) {
      setJugador(result);
    }
  }
}