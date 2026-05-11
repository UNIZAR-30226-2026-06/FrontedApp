import 'dart:async';
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

  // ESTADOS DE LA PAUSA
  int _votosPausa = 0;
  bool _yoHeVotadoPausa = false;
  bool _partidaEstaPausada = false;
  String? _votanteActualPausa;

  // ==========================================
  // ESTADOS DE ROLES
  // ==========================================
  Map<String, dynamic>? _miRol;
  Map<String, dynamic>? get miRol => _miRol;

  int _usosRol = 0;
  int get usosRol => _usosRol;

  int _maxUsosRol = 0;
  int get maxUsosRol => _maxUsosRol;

  bool _canUseRoleNow = false;
  bool get canUseRoleNow => _canUseRoleNow;

  // ESTADOS DE REANUDAR
  int _votosReanudar = 0;
  bool _yoHeVotadoReanudar = false;
  List<String> _votersReanudar = const [];

  int _segundosTranscurridos = 0;
  Timer? _cronometro;
  Timer? _tasaDeRefresco;
  bool _refrescandoEstado = false;
  bool _partidaEliminada = false;

  String? _ganadorPartida;
  int _recompensaUltimaPartida = 0;
  int? _monedasTotalesUltimaPartida;
  bool _ganadorEsBot = false;
  bool _recompensaAplicada = false;

  static const int _duracionTurnoMs = 30000;
  static const int _margenTimeoutMs = 2000;
  int? _turnoExpiraEnMs;
  Timer? _refreshTrasTimeout;

  String? _mensajeFeedback;
  String? get mensajeFeedback => _mensajeFeedback;

  void _setMensajeFeedback(String mensaje) {
    _mensajeFeedback = mensaje;
    notifyListeners();
  }

  String? consumirMensajeFeedback() {
    final m = _mensajeFeedback;
    _mensajeFeedback = null;
    return m;
  }

  void _reiniciarDeadlineTurno() {
    _turnoExpiraEnMs = DateTime.now().millisecondsSinceEpoch + _duracionTurnoMs;

    _refreshTrasTimeout?.cancel();
    _refreshTrasTimeout = Timer(
      const Duration(milliseconds: _duracionTurnoMs + _margenTimeoutMs),
          () {
        if (_partidaActual?.phase == 'playing' && !_partidaEstaPausada) {
          _refrescarEstadoDesdeServidor();
          _reiniciarDeadlineTurno();
        }
      },
    );
  }

  String? get error => _error;
  PartidaModel? get partidaActual => _partidaActual;
  bool get cargando => _cargando;
  bool get hayPartidaActiva => _partidaActual != null;
  bool get isVsIA => _isVsIA;
  int get maxJugadores => _partidaActual?.maxJugadores ?? _maxJugadores;

  int get votosPausa => _votosPausa;
  bool get yoHeVotadoPausa => _yoHeVotadoPausa;
  bool get partidaEstaPausada => _partidaEstaPausada;
  String? get votanteActualPausa => _votanteActualPausa;

  int get votosReanudar => _votosReanudar;
  bool get yoHeVotadoReanudar => _yoHeVotadoReanudar;
  List<String> get votersReanudar => _votersReanudar;
  bool get partidaEliminada => _partidaEliminada;

  String? get ganadorPartida => _ganadorPartida;
  int get recompensaUltimaPartida => _recompensaUltimaPartida;
  int? get monedasTotalesUltimaPartida => _monedasTotalesUltimaPartida;
  bool get ganadorEsBot => _ganadorEsBot;

  bool get recompensaPendienteAplicar =>
      _ganadorPartida != null &&
          _recompensaUltimaPartida > 0 &&
          _monedasTotalesUltimaPartida != null &&
          !_recompensaAplicada;

  void marcarRecompensaAplicada() {
    _recompensaAplicada = true;
  }

  bool ganadorEs(String? jugadorId) =>
      _ganadorPartida != null && _ganadorPartida == jugadorId;

  int? get turnoExpiraEnMs => _turnoExpiraEnMs;

  bool get yoSoyHost {
    final p = _partidaActual;
    if (p == null || p.jugadores.isEmpty) return false;
    return p.jugadores.first.id == p.jugadorLocal;
  }

  String get tiempoFormateado {
    final minutos = (_segundosTranscurridos ~/ 60).toString();
    final segundos = (_segundosTranscurridos % 60).toString().padLeft(2, '0');
    return "$minutos:$segundos";
  }

  void _iniciarCronometro() {
    _cronometro?.cancel();
    _cronometro = Timer.periodic(const Duration(seconds: 1), (timer) {
      _segundosTranscurridos++;
      notifyListeners();
    });
  }

  void _pausarCronometro() {
    _cronometro?.cancel();
  }

  void _iniciarTasaDeRefresco() {
    _tasaDeRefresco?.cancel();

    Timer(const Duration(seconds: 1), () {
      if (_partidaActual?.phase == 'waiting' && !_partidaEliminada) {
        _refrescarLobbyDesdeServidor();
      }
    });

    _tasaDeRefresco = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_partidaActual?.phase != 'waiting') {
        _tasaDeRefresco?.cancel();
        return;
      }
      _refrescarLobbyDesdeServidor();
    });
  }

  @override
  void dispose() {
    _cronometro?.cancel();
    _tasaDeRefresco?.cancel();
    _refreshTrasTimeout?.cancel();
    super.dispose();
  }

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
    if (!_socketService.hasSocket || _partidaActual == null) return;

    final String gameId = _partidaActual!.gameId;

    _socketService.off('partida_iniciada');
    _socketService.off('partida_iniciada_broadcast');
    _socketService.off('nuevo_jugador');
    _socketService.off('bot_unido');
    _socketService.off('error_partida');
    _socketService.off('turno_invalido');
    _socketService.off('turno_siguiente');
    _socketService.off('game_state_updated');
    _socketService.off('bot_action');
    _socketService.off('carta_robada');
    _socketService.off('game_finished');
    _socketService.off('voto_pausa');
    _socketService.off('voto_reanudar');
    _socketService.off('voto_reanudar_retirado');
    _socketService.off('pausa_rechazada');
    _socketService.off('partida_pausada');
    _socketService.off('partida_reanudada');

    _socketService.on('partida_iniciada', (data) {
      _tasaDeRefresco?.cancel();
      if (_partidaActual == null) return;

      final misCartas = (data is Map && data['manoInicial'] is List)
          ? data['manoInicial'] as List
          : null;

      if (misCartas != null) {
        final miId = _partidaActual!.jugadorLocal ?? 'yo';

        List<JugadorPartidaModel> jugadoresActualizados = _partidaActual!
            .jugadores
            .map((j) {
          if (j.id == miId) return JugadorPartidaModel(id: j.id, hand: misCartas);
          return j;
        }).toList();

        if (jugadoresActualizados.isEmpty) {
          jugadoresActualizados.add(JugadorPartidaModel(id: miId, hand: misCartas));
        }

        _partidaActual = _partidaActual!.copyWith(
          phase: 'playing',
          rolesMode: data['mode'] == 'roles',
          specialCardsMode: data['mode'] == 'cards',
          jugadores: jugadoresActualizados,
        );
      } else {
        _partidaActual = _partidaActual!.copyWith(
          phase: 'playing',
          rolesMode: data is Map && data['mode'] == 'roles',
          specialCardsMode: data is Map && data['mode'] == 'cards',
        );
      }

      _segundosTranscurridos = 0;
      _iniciarCronometro();
      _reiniciarDeadlineTurno();
      notifyListeners();
      _refrescarEstadoDesdeServidor();

      if(_partidaActual?.rolesMode == true) cargarMiRol();
    });

    _socketService.on('partida_iniciada_broadcast', (data) {
      if (_partidaActual == null || _partidaActual!.phase == 'playing') return;

      _tasaDeRefresco?.cancel();
      _partidaActual = _partidaActual!.copyWith(
        phase: 'playing',
        rolesMode: data is Map ? data['mode'] == 'roles' : false,
        specialCardsMode: data is Map ? data['mode'] == 'cards' : false,
      );
      _segundosTranscurridos = 0;
      _iniciarCronometro();
      _reiniciarDeadlineTurno();
      notifyListeners();
      _refrescarEstadoDesdeServidor();
    });

    void aplicarVotoPausa(dynamic data) {
      if (data is! Map) return;
      _votosPausa = (data['votosActuales'] as int?) ?? _votosPausa;
      final String? jugadorQueVoto = data['jugador']?.toString();

      if (jugadorQueVoto != null &&
          jugadorQueVoto != _partidaActual?.jugadorLocal &&
          !_yoHeVotadoPausa) {
        _votanteActualPausa = jugadorQueVoto;
      }
      notifyListeners();
    }

    _socketService.on('voto_pausa', aplicarVotoPausa);
    _socketService.on('voto_pausa_registrado', aplicarVotoPausa);

    _socketService.on('pausa_rechazada', (data) {
      _votosPausa = 0;
      _yoHeVotadoPausa = false;
      _votanteActualPausa = null;
      notifyListeners();
    });

    _socketService.on('partida_pausada', (_) {
      _partidaEstaPausada = true;
      _votosPausa = 0;
      _yoHeVotadoPausa = false;
      _votosReanudar = 0;
      _yoHeVotadoReanudar = false;
      _votersReanudar = const [];
      _votanteActualPausa = null;
      _turnoExpiraEnMs = null;
      _refreshTrasTimeout?.cancel();
      _pausarCronometro();
      notifyListeners();
    });

    // --- EVENTOS DE REANUDAR ---
    void aplicarPayloadReanudar(dynamic data) {
      if (data is! Map) return;
      _votosReanudar = (data['votosActuales'] as int?) ?? _votosReanudar;
      final raw = data['voters'];
      if (raw is List) {
        _votersReanudar = raw.map((v) => v.toString()).toList();
      }
      final miId = _partidaActual?.jugadorLocal;
      if (miId != null && raw is List) {
        _yoHeVotadoReanudar = _votersReanudar.contains(miId);
      }
    }

    void onVotoReanudar(dynamic data) {
      aplicarPayloadReanudar(data);
      notifyListeners();
    }

    _socketService.on('voto_reanudar', onVotoReanudar);
    _socketService.on('voto_reanudar_registrado', onVotoReanudar);

    _socketService.on('voto_reanudar_retirado', (data) {
      aplicarPayloadReanudar(data);
      final String? jugadorQueRetiro = data is Map ? data['jugador'] : null;
      if (jugadorQueRetiro != null && jugadorQueRetiro == _partidaActual?.jugadorLocal) {
        _yoHeVotadoReanudar = false;
      }
      notifyListeners();
    });

    _socketService.on('partida_reanudada', (_) {
      _partidaEstaPausada = false;
      if (_partidaActual != null) {
        _partidaActual = _partidaActual!.copyWith(phase: 'playing');
      }
      _votosPausa = 0;
      _yoHeVotadoPausa = false;
      _votosReanudar = 0;
      _yoHeVotadoReanudar = false;
      _votersReanudar = const [];
      _iniciarCronometro();
      _reiniciarDeadlineTurno();
      notifyListeners();
    });

    // --- EVENTOS GENERALES ---
    _socketService.on('nuevo_jugador', (_) => _refrescarLobbyDesdeServidor());
    _socketService.on('bot_unido', (_) => _refrescarLobbyDesdeServidor());

    _socketService.on('error_partida', (data) {
      final msg = data is Map ? data['message']?.toString() : null;
      if (msg != null && msg.isNotEmpty) _setMensajeFeedback(msg);
    });

    _socketService.on('turno_invalido', (data) {
      final msg = data is Map ? data['message']?.toString() : null;
      if (msg != null && msg.isNotEmpty) _setMensajeFeedback(msg);
    });

    _socketService.on('turno_siguiente', (_) => notifyListeners());
    _socketService.on('game_state_updated', (_) {
      _reiniciarDeadlineTurno();
      _refrescarEstadoDesdeServidor();
    });


    _socketService.on('game_finished', (data) {
      if (data is Map) {
        _ganadorPartida = data['winner']?.toString();
        _ganadorEsBot = data['isBot'] == true;
        final rec = data['recompensa'];
        _recompensaUltimaPartida = rec is int ? rec : 0;
        final tot = data['monedasTotales'];
        _monedasTotalesUltimaPartida = tot is int ? tot : null;
        _recompensaAplicada = false;
      }
      if (_partidaActual != null) {
        _partidaActual = _partidaActual!.copyWith(phase: 'finished');
      }
      notifyListeners();
    });

    _socketService.emitir('unirse_partida', {'partidaID': gameId});

    if (_partidaActual!.phase == 'waiting') {
      _iniciarTasaDeRefresco();
    }
  }

  Future<void> _refrescarLobbyDesdeServidor() async {
    if (_partidaActual == null || _refrescandoEstado) return;

    if (_partidaActual!.phase != 'waiting') {
      _tasaDeRefresco?.cancel();
      await _refrescarEstadoDesdeServidor();
      return;
    }

    _refrescandoEstado = true;
    final String gameId = _partidaActual!.gameId;
    final String fasePrevia = _partidaActual!.phase;

    try {
      final estado = await _repository.obtenerPartida(gameId);
      if (_partidaActual == null) return;

      if (fasePrevia == 'waiting' && _partidaActual!.phase != 'waiting') return;

      if (estado.phase != 'waiting') {
        _tasaDeRefresco?.cancel();
        _refrescandoEstado = false;
        await _refrescarEstadoDesdeServidor();
        return;
      }

      _partidaActual = estado.copyWith(
        code: _partidaActual!.code,
        isPrivate: _partidaActual!.isPrivate,
        jugadorLocal: _partidaActual!.jugadorLocal,
        maxJugadores: _partidaActual!.maxJugadores,
        rolesMode: _partidaActual!.rolesMode,
        specialCardsMode: _partidaActual!.specialCardsMode,
      );
      notifyListeners();
    } on PartidaNoEncontradaException {
      _partidaEliminada = true;
      _tasaDeRefresco?.cancel();
      notifyListeners();
    } catch (e) {
      debugPrint("[LOBBY] Error refrescando: $e");
    } finally {
      _refrescandoEstado = false;
    }
  }

  Future<void> _refrescarEstadoDesdeServidor() async {
    await _refrescarConRepoCall((id) => _repository.obtenerEstadoPartida(id), etiqueta: 'STATE');
  }

  Future<void> _refrescarConRepoCall(
      Future<PartidaModel> Function(String) repoCall, {
        required String etiqueta,
      }) async {
    if (_partidaActual == null || _refrescandoEstado) return;

    _refrescandoEstado = true;
    final String gameId = _partidaActual!.gameId;

    try {
      final estado = await repoCall(gameId);
      if (_partidaActual == null) return;

      if (estado.phase == 'paused' || estado.phase == 'pausada') {
        _partidaEstaPausada = true;
      } else if (estado.phase == 'playing') {
        _partidaEstaPausada = false;
      }

      _partidaActual = estado.copyWith(
        code: _partidaActual!.code,
        isPrivate: _partidaActual!.isPrivate,
        jugadorLocal: _partidaActual!.jugadorLocal,
        maxJugadores: _partidaActual!.maxJugadores, // ¡Mantiene el 2 intacto!
        rolesMode: _partidaActual!.rolesMode,
        specialCardsMode: _partidaActual!.specialCardsMode,
      );

      _votersReanudar = estado.resumeVoters;
      _votosReanudar = estado.resumeVoters.length;
      _votosPausa = estado.pauseVoters.length;

      final miId = _partidaActual!.jugadorLocal;
      if (miId != null) {
        _yoHeVotadoReanudar = estado.resumeVoters.contains(miId);
        _yoHeVotadoPausa = estado.pauseVoters.contains(miId);
      }

      if (estado.rolesMode && _miRol == null && (estado.phase == 'playing' || estado.phase == 'paused')) {
        cargarMiRol();
      }

      notifyListeners();
    } on PartidaNoEncontradaException {
      _partidaEliminada = true;
      _tasaDeRefresco?.cancel();
      notifyListeners();
    } catch (e) {
      debugPrint("[$etiqueta] Error: $e");
    } finally {
      _refrescandoEstado = false;
    }
  }

  // ==========================================
  // LÓGICA DE ROLES
  // ==========================================

  /// Llama al backend para saber qué rol me ha tocado
  Future<void> cargarMiRol() async {
    if (_partidaActual == null || !_partidaActual!.rolesMode) return;

    try {
      final infoRol = await _repository.obtenerMiRol(_partidaActual!.gameId);
      _miRol = infoRol['role'];
      _usosRol = infoRol['uses'] ?? 0;
      _maxUsosRol = infoRol['maxUses'] ?? 0;
      _canUseRoleNow = infoRol['canUseNow'] ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error al cargar mi rol: $e");
    }
  }

  /// Método genérico para usar la habilidad del rol
  Future<Map<String, dynamic>?> activarHabilidadRol({
    String? targetPlayerId,
    String? ownCardId,
    String? cardId,
    String? newColor,
    int? newNumber,
  }) async {
    if (_partidaActual == null || !_canUseRoleNow) return null;

    try {
      final response = await _repository.usarRol(
        _partidaActual!.gameId,
        targetPlayerId: targetPlayerId,
        ownCardId: ownCardId,
        cardId: cardId,
        newColor: newColor,
        newNumber: newNumber,
      );

      await cargarMiRol();
      await _refrescarEstadoDesdeServidor();

      return response;
    } catch (e) {
      debugPrint("Error al usar habilidad del rol: $e");
      _setMensajeFeedback("No se pudo usar la habilidad");
      return null;
    }
  }

  Future<void> crearPartida({
    required bool isPrivate,
    String? jugadorLocal,
    int maxJugadores = 4,
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
        modoRoles: modoRoles,
      );
      List<JugadorPartidaModel> listaInicial = partida.jugadores;
      if (listaInicial.isEmpty) {
        listaInicial = [JugadorPartidaModel(id: jugadorLocal ?? 'Yo')];
      }
      _partidaActual = partida.copyWith(
        jugadorLocal: jugadorLocal,
        jugadores: listaInicial,
        maxJugadores: maxJugadores,
        isPrivate: isPrivate,
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
      await _refrescarEstadoDesdeServidor();
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
      _partidaActual = partida.copyWith(
        jugadorLocal: jugadorLocal,
        isPrivate: true,
        code: code,
      );
      _activarTiempoReal();
      await _refrescarEstadoDesdeServidor();
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

  void dismissBannerPausa() {
    _votanteActualPausa = null;
    notifyListeners();
  }

  void limpiarPartida() {
    if (_socketService.hasSocket) {
      _socketService.off('partida_iniciada');
      _socketService.off('partida_iniciada_broadcast');
      _socketService.off('nuevo_jugador');
      _socketService.off('bot_unido');
      _socketService.off('error_partida');
      _socketService.off('turno_invalido');
      _socketService.off('turno_siguiente');
      _socketService.off('game_state_updated');
      _socketService.off('bot_action');
      _socketService.off('carta_robada');
      _socketService.off('game_finished');
      _socketService.off('voto_pausa');
      _socketService.off('voto_reanudar');
      _socketService.off('voto_reanudar_retirado');
      _socketService.off('pausa_rechazada');
      _socketService.off('partida_pausada');
      _socketService.off('partida_reanudada');
    }
    _partidaActual = null;
    _error = null;
    _maxJugadores = 4;
    _partidaEliminada = false;
    _isVsIA = false;

    _ganadorPartida = null;
    _recompensaUltimaPartida = 0;
    _monedasTotalesUltimaPartida = null;
    _ganadorEsBot = false;
    _recompensaAplicada = false;
    _turnoExpiraEnMs = null;
    _refreshTrasTimeout?.cancel();
    _mensajeFeedback = null;

    _partidaEstaPausada = false;
    _votosPausa = 0;
    _yoHeVotadoPausa = false;
    _votosReanudar = 0;
    _yoHeVotadoReanudar = false;
    _votersReanudar = const [];
    _votanteActualPausa = null;

    _tasaDeRefresco?.cancel();
    _pausarCronometro();
    _segundosTranscurridos = 0;
    _refrescandoEstado = false;

    notifyListeners();
  }

  Future<void> abandonarYBorrarPartida() async {
    try {
      if (_partidaActual != null) {
        await _repository.borrarPartida(_partidaActual!.gameId);
      }
    } catch (e) {
      debugPrint("Error borrando partida: $e");
    } finally {
      limpiarPartida();
    }
  }

  Future<void> salirDePartidaVsIA() async {
    if (_partidaActual == null) {
      limpiarPartida();
      return;
    }
    try {
      await _repository.finalizarPartida(_partidaActual!.gameId);
    } catch (e) {
      debugPrint("Error al finalizar partida vs IA: $e");
    } finally {
      limpiarPartida();
    }
  }

  void setPartidaActual(PartidaModel partida, {String? jugadorLocal}) {
    _partidaActual = partida;

    if (jugadorLocal != null) {
      _partidaActual = _partidaActual!.copyWith(jugadorLocal: jugadorLocal);
    }

    _partidaEstaPausada = partida.phase == 'paused';
    _activarTiempoReal();
    notifyListeners();
    _refrescarEstadoDesdeServidor();
  }

  void solicitarPausa() {
    if (_partidaActual == null || _yoHeVotadoPausa) return;

    if (_partidaActual!.phase != 'playing' ||
        _partidaEstaPausada ||
        _isVsIA ||
        !_partidaActual!.isPrivate) {
      return;
    }

    _yoHeVotadoPausa = true;
    _votosPausa = 1;
    notifyListeners();

    _socketService.emitir('jugador_solicita_pausa', {'partidaID': _partidaActual!.gameId});
  }

  void aceptarPausa() {
    if (_partidaActual == null || _yoHeVotadoPausa) return;

    _yoHeVotadoPausa = true;
    _votosPausa = _votosPausa + 1;
    _votanteActualPausa = null;
    notifyListeners();

    _socketService.emitir('jugador_voto_pausa', {'partidaID': _partidaActual!.gameId});
  }


  void emitirRechazoPausa() {
    if (_partidaActual == null) return;

    _votanteActualPausa = null;
    notifyListeners();

    _socketService.emitir('jugador_rechaza_pausa', {'partidaID': _partidaActual!.gameId});
  }

  void emitirVotoReanudar() {
    if (_partidaActual == null || _yoHeVotadoReanudar) return;

    _yoHeVotadoReanudar = true;
    notifyListeners();

    final evento = _votosReanudar == 0 ? 'jugador_solicita_reanudar' : 'jugador_voto_reanudar';
    _socketService.emitir(evento, {'partidaID': _partidaActual!.gameId});
  }

  void aplicarResultadoVotoReanudar(ResumeVoteResult res) {
    if (res.partidaReanudada) {
      _partidaEstaPausada = false;
      if (_partidaActual != null) {
        _partidaActual = _partidaActual!.copyWith(phase: 'playing');
      }
      _votosReanudar = 0;
      _yoHeVotadoReanudar = false;
      _votersReanudar = const [];
      _iniciarCronometro();
      _reiniciarDeadlineTurno();
    } else {
      _votersReanudar = res.voters;
      _votosReanudar = res.votosActuales;
      final miId = _partidaActual?.jugadorLocal;
      if (miId != null) {
        _yoHeVotadoReanudar = res.voters.contains(miId);
      } else {
        _yoHeVotadoReanudar = true;
      }
    }
    notifyListeners();
  }

  void retirarVotoReanudar() {
    if (_partidaActual == null || !_yoHeVotadoReanudar) return;

    _yoHeVotadoReanudar = false;
    notifyListeners();

    _socketService.emitir('abandonar_voto_reanudar', {'partidaID': _partidaActual!.gameId});
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