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

  // Variables de estado para "PAUSAR"
  int _votosPausa = 0;
  bool _yoHeVotadoPausa = false;
  bool _partidaEstaPausada = false;

  int _votosReanudar = 0;
  bool _yoHeVotadoReanudar = false;

  String? get error => _error;
  PartidaModel? get partidaActual => _partidaActual;
  bool get cargando => _cargando;
  bool get hayPartidaActiva => _partidaActual != null;
  bool get isVsIA => _isVsIA;
  int get maxJugadores => _maxJugadores;
  int get votosPausa => _votosPausa;
  bool get yoHeVotadoPausa => _yoHeVotadoPausa;
  bool get partidaEstaPausada => _partidaEstaPausada;
  int get votosReanudar => _votosReanudar;
  bool get yoHeVotadoReanudar => _yoHeVotadoReanudar;

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

    // Limpieza de listeners
    _socketService.socket!.off('partida_iniciada');
    _socketService.socket!.off('nuevo_jugador');
    _socketService.socket!.off('error_partida');
    _socketService.socket!.off('turno_siguiente');
    _socketService.socket!.off('game_state_updated');
    _socketService.socket!.off('bot_action');
    _socketService.socket!.off('carta_robada');
    _socketService.socket!.off('game_finished');
    _socketService.socket!.off('voto_pausa_registrado');
    _socketService.socket!.off('voto_reanudar_registrado'); // 🔥 Nuevo off
    _socketService.socket!.off('partida_pausada');
    _socketService.socket!.off('partida_reanudada');

    _socketService.emitir('unirse_partida', {'partidaID': gameId});

    _socketService.socket!.on('partida_iniciada', (data) {
      if (_partidaActual != null) {
        final misCartas = data['manoInicial'] ?? [];
        final miId = _partidaActual!.jugadorLocal ?? 'yo';

        List<JugadorPartidaModel> jugadoresActualizados = _partidaActual!
            .jugadores
            .map((j) {
              if (j.id == miId) {
                return JugadorPartidaModel(id: j.id, hand: misCartas);
              }
              return j;
            })
            .toList();

        if (jugadoresActualizados.isEmpty) {
          jugadoresActualizados.add(
            JugadorPartidaModel(id: miId, hand: misCartas),
          );
        }

        _partidaActual = _partidaActual!.copyWith(
          phase: 'playing',
          rolesMode: data['modoJuego'] == 'roles' || data['mode'] == 'roles',
          specialCardsMode:
              data['modoJuego'] == 'cards' || data['mode'] == 'cards',
          jugadores: jugadoresActualizados,
        );
        notifyListeners();
        _refrescarEstadoDesdeServidor();
      }
    });

    _socketService.socket!.on('voto_pausa_registrado', (data) {
      _votosPausa = data['votosFavor'] ?? 0;
      final String? jugadorQueVoto = data['jugador'];

      notifyListeners();

      if (jugadorQueVoto != null) {
        debugPrint("El jugador $jugadorQueVoto acaba de votar para pausar.");
      }
    });

    _socketService.socket!.on('voto_reanudar_registrado', (data) {
      _votosReanudar = data['votosFavor'] ?? 0;
      final String? jugadorQueVoto = data['jugador'];

      notifyListeners();

      if (jugadorQueVoto != null) {
        debugPrint("El jugador $jugadorQueVoto acaba de votar para reanudar.");
      }
    });

    _socketService.socket!.on('partida_pausada', (_) {
      _partidaEstaPausada = true;
      _votosPausa = 0;
      _yoHeVotadoPausa = false;
      _votosReanudar = 0;
      _yoHeVotadoReanudar = false;
      notifyListeners();
    });

    _socketService.socket!.on('partida_reanudada', (_) {
      _partidaEstaPausada = false;
      _votosPausa = 0;
      _yoHeVotadoPausa = false;
      _votosReanudar = 0;
      _yoHeVotadoReanudar = false;
      notifyListeners();
    });

    _socketService.socket!.on('nuevo_jugador', (data) {
      if (_partidaActual != null) {
        final nuevoJugador = JugadorPartidaModel(id: data['jugador']);
        final listaActualizada = List<JugadorPartidaModel>.from(
          _partidaActual!.jugadores,
        )..add(nuevoJugador);

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

    _socketService.socket!.on(
      'game_state_updated',
      (_) => _refrescarEstadoDesdeServidor(),
    );
    _socketService.socket!.on(
      'bot_action',
      (_) => _refrescarEstadoDesdeServidor(),
    );
    _socketService.socket!.on(
      'carta_robada',
      (_) => _refrescarEstadoDesdeServidor(),
    );
    _socketService.socket!.on('game_finished', (data) {
      if (_partidaActual != null) {
        _partidaActual = _partidaActual!.copyWith(phase: 'finished');
      }
      _error = data is Map ? 'Ganador: ${data['winner']}' : null;
      notifyListeners();
    });
  }

  Future<void> _refrescarEstadoDesdeServidor() async {
    if (_partidaActual == null) return;

    try {
      final estado = await _repository.obtenerEstadoPartida(
        _partidaActual!.gameId,
      );
      _partidaActual = estado.copyWith(
        code: _partidaActual!.code,
        isPrivate: _partidaActual!.isPrivate,
        jugadorLocal: _partidaActual!.jugadorLocal,
        rolesMode: _partidaActual!.rolesMode,
        specialCardsMode: _partidaActual!.specialCardsMode,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Error refrescando estado de partida: $e");
    }
  }

  Future<void> crearPartida({
    required bool isPrivate,
    String? jugadorLocal,
    int maxJugadores = 4,
    bool modoCartasEspeciales = true,
    bool modoRoles = false,
  }) async {
    _cargando = true;
    _error = null;
    _maxJugadores = maxJugadores;
    notifyListeners();

    try {
      final partida = await _repository.crearPartida(
        isPrivate: isPrivate,
        maxJugadores: maxJugadores,
        modoCartasEspeciales: modoCartasEspeciales,
        modoRoles: modoRoles,
      );
      List<JugadorPartidaModel> listaInicial = partida.jugadores;
      if (listaInicial.isEmpty) {
        listaInicial = [JugadorPartidaModel(id: jugadorLocal ?? 'Yo')];
      }
      _partidaActual = partida.copyWith(
        isPrivate: isPrivate,
        jugadorLocal: jugadorLocal,
        jugadores: listaInicial,
        rolesMode: modoRoles,
        specialCardsMode: modoCartasEspeciales,
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

  Future<void> unirsePartidaPublica({
    String? jugadorLocal,
    int maxJugadores = 4,
    String? mode,
  }) async {
    _cargando = true;
    _error = null;
    _maxJugadores = maxJugadores;
    notifyListeners();
    try {
      final partida = await _repository.unirsePartidaPublica(
        maxJugadores: maxJugadores,
        mode: mode,
      );
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
    _socketService.emitir('robar_carta', {'partidaID': _partidaActual!.gameId});
  }

  void limpiarPartida() {
    if (_socketService.socket != null) {
      _socketService.socket!.off('partida_iniciada');
      _socketService.socket!.off('nuevo_jugador');
      _socketService.socket!.off('error_partida');
      _socketService.socket!.off('turno_siguiente');
      _socketService.socket!.off('game_state_updated');
      _socketService.socket!.off('bot_action');
      _socketService.socket!.off('carta_robada');
      _socketService.socket!.off('game_finished');
      _socketService.socket!.off('voto_pausa_registrado');
      _socketService.socket!.off('voto_reanudar_registrado'); // Limpieza
      _socketService.socket!.off('partida_pausada');
      _socketService.socket!.off('partida_reanudada');
    }
    _partidaActual = null;
    _error = null;

    _partidaEstaPausada = false;
    _votosPausa = 0;
    _yoHeVotadoPausa = false;
    _votosReanudar = 0;
    _yoHeVotadoReanudar = false;

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
      limpiarPartida();
    }
  }

  void setPartidaActual(PartidaModel partida, {String? jugadorLocal}) {
    _partidaActual = partida;

    if (jugadorLocal != null) {
      _partidaActual = _partidaActual!.copyWith(jugadorLocal: jugadorLocal);
    }
    // Comprueba si la partida esta en pausa
    if (partida.phase == 'paused') {
      _partidaEstaPausada = true;
    }

    _activarTiempoReal();
    notifyListeners();
  }

  Future<void> emitirVotoPausa() async {
    if (_partidaActual == null) {
      debugPrint("emitirVotoPausa cancelado: _partidaActual es null");
      return;
    }
    if (_yoHeVotadoPausa) {
      debugPrint("emitirVotoPausa cancelado: _yoHeVotadoPausa ya es true");
      return;
    }

    _yoHeVotadoPausa = true;
    notifyListeners();
    debugPrint("Estado CAMBIADO a yoHeVotadoPausa = true. Notificando a UI.");

    try {
      debugPrint("Enviando petición HTTP de pausa...");
      await _repository.solicitarPausa(_partidaActual!.gameId);
      debugPrint("Petición HTTP completada.");
    } catch (e) {
      _yoHeVotadoPausa = false;
      _error = "Error al votar pausa: $e";
      notifyListeners();
      debugPrint("ERROR en la petición HTTP: $e. Estado RESETEADO a false.");
    }
  }

  Future<void> emitirVotoReanudar() async {
    if (_partidaActual == null || _yoHeVotadoReanudar) return;
    _yoHeVotadoReanudar = true;
    notifyListeners();

    try {
      await _repository.reanudarPartida(_partidaActual!.gameId);
    } catch (e) {
      _yoHeVotadoReanudar = false;
      _error = "Error al votar reanudar: $e";
      notifyListeners();
    }
  }

  Future<void> anyadirBot() async {
    if (_partidaActual == null) return;
    try {
      await _repository.anyadirBot(_partidaActual!.gameId);
    } catch (e) {
      _error = "Error al añadir bot: $e";
      rethrow;
    }
  }
}
