import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../views/tienda_view.dart';
import '../views/perfil_view.dart';
import '../views/amigos_view.dart';

class HomeViewModel extends ChangeNotifier {

  HomeViewModel({Jugador? jugadorInicial})
      : _jugador = jugadorInicial ?? Jugador(
      nombre: "Jugador",
      coins: 0,
      avatarId: 'a0',
      skinId: 's1'
  );

  Jugador _jugador;
  Jugador get jugador => _jugador;

  int _bottomIndex = 0;
  int get bottomIndex => _bottomIndex;

  void setJugador(Jugador nuevo) {
    _jugador = nuevo;
    notifyListeners();
  }

  // Simplificamos: La View solo llama a esto, el VM decide qué hacer
  void selectBottomTab(BuildContext context, int index) {
    _bottomIndex = index;
    notifyListeners();

    // Disparamos la navegación según el índice
    switch (index) {
      case 0: openAmigos(context); break;
      case 1: openTienda(context); break;
      case 2: openPerfil(context); break;
    }
  }

  void onTapAction(BuildContext context, String destino) {
    // Aquí es donde conectarás con la pantalla de "SeleccionModoView"
    debugPrint("Navegando a modo: $destino");
  }

  void openTienda(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TiendaView()),
    );
  }

  Future<void> openPerfil(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PerfilView()),
    );

    if (result is Jugador) {
      setJugador(result);
    }
  }

  Future<void> openAmigos(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AmigosView()),
    );

    if (result is Jugador) {
      setJugador(result);
    }
  }
}