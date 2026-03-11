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

  // Inicializamos en -1 para que ningún botón aparezca marcado por defecto
  int _bottomIndex = -1;
  int get bottomIndex => _bottomIndex;

  void setJugador(Jugador nuevo) {
    _jugador = nuevo;
    notifyListeners();
  }

  /// Gestiona la pulsación del menú inferior de forma asíncrona
  Future<void> selectBottomTab(BuildContext context, int index) async {
    _bottomIndex = index;
    notifyListeners();

    // Esperamos a que la navegación termine (que el usuario vuelva)
    switch (index) {
      case 0:
        await openAmigos(context);
        break;
      case 1:
        await openTienda(context);
        break;
      case 2:
        await openPerfil(context);
        break;
    }

    // Al regresar, reseteamos el índice para que no se quede marcado en azul
    _bottomIndex = -1;
    notifyListeners();
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

    // Placeholder para el resto de acciones
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ir a: $destino (pendiente)')),
    );
  }

  // Ahora todas las funciones de apertura son asíncronas para permitir el reset del índice

  Future<void> openTienda(BuildContext context) async {
    await Navigator.push(
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