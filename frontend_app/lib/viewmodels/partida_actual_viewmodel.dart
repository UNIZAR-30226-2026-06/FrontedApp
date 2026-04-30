import 'package:flutter/material.dart';
import '../models/partida_model.dart';
import '../models/jugador_partida_model.dart';
import '../repositories/partida_repository.dart';
import '../services/socket_service.dart';

class PartidaActualViewModel extends ChangeNotifier {
  final PartidaRepository _repository;
  final SocketService _socketService;

  PartidaActualViewModel(this._repository, this._socketService);

  PartidaModel? _partidaActual;
  bool _cargando = false;
  String? _error;

  String? get error => _error;
  PartidaModel? get partidaActual => _partidaActual;
  bool get cargando => _cargando;
  bool get hayPartidaActiva => _partidaActual != null;

  void iniciarPartida({bool vsIA = false, int cantidadBots = 0}) {
    if (_partidaActual == null) return;

    _socketService.emitir('start_game', {
      'partidaID': _partidaActual!.gameId,
      'vsIA': vsIA,
      'cantidadBots': vsIA ? cantidadBots : 0,
    });
  }

  void _activarTiempoReal() {
    if (_socketService.socket == null || _partidaActual == null) return;

    final String gameId = _partidaActual!.gameId;

    _socketService.socket!.off('partida_iniciada');
    _socketService.socket!.off('nuevo_jugador');
    _socketService.socket!.off('error_partida');
    _socketService.socket!.off('turno_siguiente');

    _socketService.emitir('unirse_partida', {'partidaID': gameId});

    _socketService.socket!.on('partida_iniciada', (data) {
      if (_partidaActual != null) {
        final miJugador = JugadorPartidaModel(
          id: _partidaActual!.jugadorLocal ?? 'yo',
          hand: data['manoInicial'] ?? [],
        );

        _partidaActual = _partidaActual!.copyWith(
          phase: 'playing',
          rolesMode: data['modoJuego'] == 'roles',
          specialCardsMode: data['modoJuego'] == 'cards',
          jugadores: [miJugador],
        );
        notifyListeners();
      }
    });

    _socketService.socket!.on('nuevo_jugador', (data) {
      if (_partidaActual != null) {
        final nuevoJugador = JugadorPartidaModel(id: data['jugador']);
        final listaActualizada = List<JugadorPartidaModel>.from(_partidaActual!.jugadores)
          ..add(nuevoJugador);

        _partidaActual = _partidaActual!.copyWith(jugadores: listaActualizada);
        notifyListeners();
      }
    });

    _socketService.socket!.on('error_partida', (data) {
      _error = data['message'];
      notifyListeners();
    });

    _socketService.socket!.on('turno_siguiente', (data) {
      // Aqui actualizarias quien tiene el turno y que carta hay en la mesa
      // sea un humano o un bot quien haya movido.
      notifyListeners();
    });
  }

  Future<void> crearPartida({required bool isPrivate, String? jugadorLocal}) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final partida = await _repository.crearPartida(isPrivate: isPrivate);
      _partidaActual = partida.copyWith(jugadorLocal: jugadorLocal);
      _activarTiempoReal();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> unirsePartidaPublica({String? jugadorLocal}) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final partida = await _repository.unirsePartidaPublica();
      _partidaActual = partida.copyWith(jugadorLocal: jugadorLocal);
      _activarTiempoReal();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> unirsePorCodigo(String code, {String? jugadorLocal}) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final partida = await _repository.unirsePorCodigo(code);
      _partidaActual = partida.copyWith(jugadorLocal: jugadorLocal);
      _activarTiempoReal();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void jugarCarta(String cartaId) {
    if (_partidaActual == null) return;
    _socketService.emitir('comprobar_turno', {
      'partidaID': _partidaActual!.gameId,
      'cartaId': cartaId,
    });
  }

  void robarCarta() {
    if (_partidaActual == null) return;
    _socketService.emitir('robar_carta', {
      'partidaID': _partidaActual!.gameId,
    });
  }

  void limpiarPartida() {
    if (_socketService.socket != null) {
      _socketService.socket!.off('partida_iniciada');
      _socketService.socket!.off('nuevo_jugador');
      _socketService.socket!.off('error_partida');
      _socketService.socket!.off('turno_siguiente');
    }
    _partidaActual = null;
    _error = null;
    notifyListeners();
  }
}