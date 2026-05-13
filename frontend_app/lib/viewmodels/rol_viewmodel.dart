import 'dart:async';

import 'package:flutter/material.dart';

import '../models/rol_model.dart';
import '../repositories/rol_repository.dart';
import '../services/socket_service.dart';

/// VM del rol del jugador local. Carga el rol bajo demanda (al entrar al
/// tablero en modo roles) y se refresca tras cada uso. Escucha eventos
/// socket para invalidar la caché cuando alguien (yo u otro) usa un rol.
class RolViewModel extends ChangeNotifier {
  final RolRepository _repository;
  final SocketService _socketService;

  RolViewModel(this._repository, this._socketService) {
    // Escuchamos al SocketService: si el socket aún no estaba listo cuando
    // cargarMiRol() se llamó por primera vez, los listeners no se pudieron
    // registrar. Al conectar, reintentamos: registramos listeners y, si el
    // primer GET había fallado (rol nulo), forzamos un refresh.
    _socketService.addListener(_onSocketCambio);
  }

  MiRolResponse? _miRol;
  MiRolResponse? get miRol => _miRol;

  bool _cargando = false;
  bool get cargando => _cargando;

  String? _error;
  String? get error => _error;

  // Último resultado de un uso de rol (e.g. mano espiada o carta peek).
  // El UI lo lee para mostrar el overlay correspondiente y luego llama a
  // clearUltimoResultado() para no mostrarlo dos veces.
  UsarRolResponse? _ultimoResultado;
  UsarRolResponse? get ultimoResultado => _ultimoResultado;

  String? _gameIdActivo;
  bool _listenersRegistrados = false;

  /// Carga el rol del jugador para una partida. Idempotente: si ya está
  /// cargado para el mismo gameId, no repite.
  Future<void> cargarMiRol(String gameId, {bool forzar = false}) async {
    // Cambio de partida: reseteamos estado anterior (rol viejo, listeners,
    // resultado pendiente). Si no hacemos esto, al entrar a una segunda
    // partida verías el rol de la primera hasta el siguiente refresh.
    if (_gameIdActivo != null && _gameIdActivo != gameId) {
      _miRol = null;
      _ultimoResultado = null;
      _error = null;
      _limpiarListeners();
    }
    if (!forzar && _miRol != null && _gameIdActivo == gameId) return;
    if (_cargando) return;

    _cargando = true;
    _error = null;
    // Importante: registramos gameId activo y listeners ANTES del GET. Si el
    // backend aún no ha terminado asignarRolesIniciales el GET devolverá 404
    // y antes (versión anterior) el listener nunca se registraba → cuando
    // luego llegaba 'roles_asignados' por socket, el cliente lo ignoraba y
    // el rol no cargaba nunca. Ahora el listener existe y refresca solo.
    _gameIdActivo = gameId;
    _registrarListeners();
    notifyListeners();

    try {
      final rol = await _repository.obtenerMiRol(gameId);
      _miRol = rol;
    } catch (e) {
      _error = e.toString();
      _miRol = null;
      debugPrint('[RolVM] Error cargando rol (se reintentará al recibir roles_asignados): $e');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void _onSocketCambio() {
    // Si el socket no estaba listo al primer cargarMiRol, los listeners no
    // se registraron. Al conectar reintentamos: registramos listeners y, si
    // el rol sigue sin cargar para la partida activa, forzamos refresh.
    if (!_socketService.isConnected) return;
    if (_gameIdActivo == null) return;
    if (!_listenersRegistrados) {
      _registrarListeners();
    }
    if (_miRol == null && !_cargando) {
      cargarMiRol(_gameIdActivo!, forzar: true);
    }
  }

  /// Refresca el rol desde el backend (sin guardia idempotente).
  Future<void> refrescar() async {
    final id = _gameIdActivo;
    if (id == null) return;
    await cargarMiRol(id, forzar: true);
  }

  /// Usa el rol con el payload dado. Devuelve la respuesta (UI puede
  /// mostrar resultado en un modal) y refresca el estado interno.
  Future<UsarRolResponse?> usarRol(UsarRolPayload payload) async {
    final id = _gameIdActivo;
    if (id == null || _cargando) return null;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _repository.usarRol(id, payload);
      _ultimoResultado = res;
      // Tras usar, refrescamos para actualizar uses/canUseNow.
      await cargarMiRol(id, forzar: true);
      return res;
    } catch (e) {
      _error = e.toString();
      debugPrint('[RolVM] Error usando rol: $e');
      return null;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// El UI llama esto tras mostrar el resultado para que no vuelva a salir.
  void clearUltimoResultado() {
    if (_ultimoResultado != null) {
      _ultimoResultado = null;
      notifyListeners();
    }
  }

  void _registrarListeners() {
    if (_listenersRegistrados) return;
    final socket = _socketService.socket;
    if (socket == null) return;

    // Cuando el backend confirma que se asignaron roles tras `start_game`,
    // forzamos un refresh por si el GET previo (en cargarMiRol) llegó antes.
    socket.on('roles_asignados', (_) {
      if (_gameIdActivo != null) {
        debugPrint('[RolVM] roles_asignados recibido, refrescando');
        cargarMiRol(_gameIdActivo!, forzar: true);
      }
    });

    // `game_state_updated` se emite tras cada acción. Refrescamos el rol si:
    //  - alguien USÓ un rol (lastAction='role') → mis usos pueden haber bajado
    //    si fue mi rol, o uses-extra si me afecta indirectamente.
    //  - se jugó una carta que MUTA roles. Las cartas especiales de UNO con
    //    id que contiene "role" / "Role" son las que tocan rol (changeRole,
    //    addRole, addRoleUse, etc.). Sin este refresh, mi cliente sigue
    //    pensando que tengo el rol viejo y enviaría payload mal formado al
    //    backend (típico: tras un changeRole pasas de Espía a Ladrón y la
    //    UI/payload sigue siendo de Espía, backend rechaza con "ownCardId
    //    es requerido").
    socket.on('game_state_updated', (data) {
      if (data is! Map) return;
      final lastAction = data['lastAction']?.toString();
      final cardId = data['cardId']?.toString() ?? '';
      final tocaRol = lastAction == 'role' ||
          cardId.toLowerCase().contains('role');
      if (tocaRol && _gameIdActivo != null) {
        debugPrint('[RolVM] game_state toca rol (action=$lastAction card=$cardId) → refresh');
        cargarMiRol(_gameIdActivo!, forzar: true);
      }
    });

    _listenersRegistrados = true;
  }

  void _limpiarListeners() {
    final socket = _socketService.socket;
    socket?.off('roles_asignados');
    socket?.off('game_state_updated');
    _listenersRegistrados = false;
  }

  /// Limpia todo el estado. Útil cuando se abandona la partida.
  void limpiar() {
    _limpiarListeners();
    _miRol = null;
    _ultimoResultado = null;
    _error = null;
    _gameIdActivo = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.removeListener(_onSocketCambio);
    _limpiarListeners();
    super.dispose();
  }
}
