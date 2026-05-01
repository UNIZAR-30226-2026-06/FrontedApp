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
  bool _isVsIA = false;
  int _maxJugadores = 4;

  String? get error => _error;
  PartidaModel? get partidaActual => _partidaActual;
  bool get cargando => _cargando;
  bool get hayPartidaActiva => _partidaActual != null;
  bool get isVsIA => _isVsIA;
  int get maxJugadores => _maxJugadores;

  void iniciarPartida({bool vsIA = false, int cantidadBots = 0}) {
    if (_partidaActual == null) return;

    _isVsIA = vsIA;
    notifyListeners();

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
        final misCartas = data['manoInicial'] ?? [];
        final miId = _partidaActual!.jugadorLocal ?? 'yo';

        // Mapeamos la lista actual para no borrar a los bots ni a otros humanos
        List<JugadorPartidaModel> jugadoresActualizados = _partidaActual!.jugadores.map((j) {
          if (j.id == miId) {
            // Actualizamos solo al jugador local con sus cartas
            return JugadorPartidaModel(id: j.id, hand: misCartas);
          }
          return j;
        }).toList();

        // Por si acaso la lista estaba vacía, nos añadimos
        if (jugadoresActualizados.isEmpty) {
          jugadoresActualizados.add(JugadorPartidaModel(id: miId, hand: misCartas));
        }

        _partidaActual = _partidaActual!.copyWith(
          phase: 'playing',
          rolesMode: data['modoJuego'] == 'roles',
          specialCardsMode: data['modoJuego'] == 'cards',
          jugadores: jugadoresActualizados,
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
      notifyListeners();
    });
  }

  Future<void> crearPartida({required bool isPrivate, String? jugadorLocal, int maxJugadores = 4}) async {
    _cargando = true;
    _error = null;
    _maxJugadores = maxJugadores;
    notifyListeners();

    try {
      final partida = await _repository.crearPartida(isPrivate: isPrivate);

      // FIX: Si el backend devuelve la lista vacía, nos añadimos nosotros
      List<JugadorPartidaModel> listaInicial = partida.jugadores;
      if (listaInicial.isEmpty) {
        listaInicial = [JugadorPartidaModel(id: jugadorLocal ?? 'Yo')];
      }

      _partidaActual = partida.copyWith(
        jugadorLocal: jugadorLocal,
        jugadores: listaInicial,
      );

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

  Future<void> abandonarYBorrarPartida() async {
    try {
      if (partidaActual != null) {
        await _repository.borrarPartida(partidaActual!.gameId);
      }
    } catch (e) {
      debugPrint("Error borrando partida zombie: $e");
    } finally {
      _partidaActual = null;
      notifyListeners();
    }
  }
}