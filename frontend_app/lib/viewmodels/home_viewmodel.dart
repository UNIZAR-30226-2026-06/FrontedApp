import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../views/tienda_view.dart';
import '../views/perfil_view.dart';
import '../views/amigos_view.dart';
import '../views/partida_personalizada_view.dart';
import '../views/seleccion_roles_view.dart';
import '../views/seleccion_cartas_view.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({Jugador? jugadorInicial})
      : _jugador = jugadorInicial ??
      Jugador(
        nombre: "Jugador",
        coins: 0,
        avatarId: 'a0',
        skinId: 's1',
      );

  Jugador _jugador;
  Jugador get jugador => _jugador;

  int _bottomIndex = 0;
  int get bottomIndex => _bottomIndex;

  void setJugador(Jugador nuevo) {
    _jugador = nuevo;
    notifyListeners();
  }

  // La View solo llama a esto, el VM decide qué hacer
  void selectBottomTab(BuildContext context, int index) {
    _bottomIndex = index;
    notifyListeners();

    switch (index) {
      case 0:
        openAmigos(context);
        break;
      case 1:
        openTienda(context);
        break;
      case 2:
        openPerfil(context);
        break;
    }
  }

  void onTapAction(BuildContext context, String destino) {
    debugPrint("Navegando a modo: $destino");


    // ====== MODO PERSONALIZADO ======
    if (destino == 'personalizada_privada') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PartidaPersonalizadaView()),
      );
      return;
    }

    // ====== MODO CON ROLES ======
    if (destino == 'roles_privada') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SeleccionRolesView(
            modoTitulo: 'Modo con roles',
            modoSubtitulo: 'Partida Privada',
          ),
        ),
      );
      return;
    }
/*
    if (destino == 'roles_publica') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SeleccionRolesView(
            modoTitulo: 'Modo con roles',
            modoSubtitulo: 'Partida Pública',
          ),
        ),
      );
      return;
    }
*/
    // ====== MODO CARTAS ======
    if (destino == 'cartas_privada') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SeleccionCartasView(
            modoTitulo: 'Modo cartas',
            modoSubtitulo: 'Partida Privada',
          ),
        ),
      );
      return;
    }
/*
    if (destino == 'cartas_publica') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SeleccionCartasView(
            modoTitulo: 'Modo cartas',
            modoSubtitulo: 'Partida Pública',
          ),
        ),
      );
      return;
    }
*/
    // Placeholder para el resto de acciones
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ir a: $destino (pendiente)')),
    );
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