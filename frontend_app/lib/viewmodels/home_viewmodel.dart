import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../repositories/user_repository.dart';
import '../repositories/partida_repository.dart';
import '../views/tienda_view.dart';
import '../views/perfil_view.dart';
import '../views/amigos_view.dart';
import '../views/partida_personalizada_view.dart';
import '../views/seleccion_roles_view.dart';
import '../views/seleccion_cartas_view.dart';
import '../views/partidas_pausadas_view.dart';
import '../services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final UserRepository? _userRepo;
  late final PartidaRepository _partidaRepo;

  HomeViewModel({Jugador? jugadorInicial, UserRepository? userRepo})
      : _userRepo = userRepo,
        _jugador = jugadorInicial ??
            Jugador(
              nombre: "Jugador",
              coins: 0,
              avatarId: 'a1',
              skinId: 's1',
            ) {
    _partidaRepo = PartidaRepository(ApiService());
  }

  Jugador _jugador;
  Jugador get jugador => _jugador;

  int _bottomIndex = -1;
  int get bottomIndex => _bottomIndex;

  // Variable para el contador
  int cantidadPausadas = 0;

  Future<void> cargarCantidadPausadas() async {
    try {
      final partidas = await _partidaRepo.obtenerPartidasPausadas();
      cantidadPausadas = partidas.length;
      notifyListeners();
    } catch (e) {
      debugPrint("Error contando pausadas: $e");
    }
  }

  Future<void> setJugador(Jugador nuevo) async {
    _jugador = nuevo;
    notifyListeners();

    if (_userRepo != null) {
      try {
        await _userRepo!.updateProfile(nuevo);
        debugPrint("Perfil actualizado en el backend correctamente");
      } catch (e) {
        debugPrint("Error al sincronizar perfil con el backend: $e");
      }
    }
  }

  Future<void> refreshProfile() async {
    if (_userRepo != null) {
      try {
        final perfilActualizado = await _userRepo!.getProfile();
        _jugador = perfilActualizado;
        notifyListeners();
      } catch (e) {
        debugPrint("Error al refrescar perfil: $e");
      }
    }
  }

  Future<void> selectBottomTab(BuildContext context, int index) async {
    _bottomIndex = index;
    notifyListeners();

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

    _bottomIndex = -1;
    notifyListeners();
  }

  void onTapAction(BuildContext context, String destino) {
    if (destino == 'personalizada_privada') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PartidaPersonalizadaView()));
      return;
    }
    if (destino == 'roles_privada') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SeleccionRolesView(modoTitulo: 'Modo con roles', modoSubtitulo: 'Partida Privada')));
      return;
    }
    if (destino == 'cartas_privada') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SeleccionCartasView(modoTitulo: 'Modo cartas', modoSubtitulo: 'Partida Privada')));
      return;
    }
    if (destino == 'pausadas_abrir') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PartidasPausadasView()));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ir a: $destino (pendiente)')));
  }

  Future<void> openTienda(BuildContext context) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const TiendaView()));
    await refreshProfile();
  }

  Future<void> openPerfil(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilView()));
    if (result is Jugador) {
      await setJugador(result);
    }
  }

  Future<void> openAmigos(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AmigosView()));
    if (result is Jugador) {
      await setJugador(result);
    }
  }
}