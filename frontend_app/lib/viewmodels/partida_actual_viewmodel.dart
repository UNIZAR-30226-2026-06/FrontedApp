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

  int _votosPausa = 0;
  bool _yoHeVotadoPausa = false;
  bool _partidaEstaPausada = false;
  String? _votanteActualPausa;

  Map<String, dynamic>? _miRol;
  Map<String, dynamic>? get miRol => _miRol;

  int _usosRol = 0;
  int get usosRol => _usosRol;

  int _maxUsosRol = 0;
  int get maxUsosRol => _maxUsosRol;

  bool _canUseRoleNow = false;
  bool get canUseRoleNow => _canUseRoleNow;

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
      _ganadorPartida != null && _recompensaUltimaPartida > 0 && _monedasTotalesUltimaPartida != null && !_recompensaAplicada;

  void marcarRecompensaAplicada() => _recompensaAplicada = true;
  bool ganadorEs(String? jugadorId) => _ganadorPartida != null && _ganadorPartida == jugadorId;
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

  void _pausarCronometro() => _cronometro?.cancel();

  void _iniciarTasaDeRefresco() {
    _tasaDeRefresco?.cancel();
    Timer(const Duration(seconds: 1), () {
      if (_partidaActual?.phase == 'waiting' && !_partidaEliminada) _refrescarLobbyDesdeServidor();
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

  // 🔥 NUEVO: Función para rescatar el estado (Manual y Automático)
  void solicitarSincronizacion() {
    if (_partidaActual == null) return;
    _socketService.emitir('solicitar_sincronizacion', {'partidaID': _partidaActual!.gameId});
  }

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
      debugPrint("Error al sincronizar rol via HTTP: $e");
    }
  }

  Future<Map<String, dynamic>?> activarHabilidadRol({String? targetPlayerId, String? ownCardId, String? cardId, String? newColor, int? newNumber}) async {
    if (_partidaActual == null || !_canUseRoleNow) return null;
    try {
      final response = await _repository.usarRol(_partidaActual!.gameId, targetPlayerId: targetPlayerId, ownCardId: ownCardId, cardId: cardId, newColor: newColor, newNumber: newNumber);
      await cargarMiRol();
      await _refrescarEstadoDesdeServidor();
      return response;
    } catch (e) {
      _setMensajeFeedback("No se pudo usar la habilidad");
      return null;
    }
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
    _socketService.off('game_finished');
    _socketService.off('voto_pausa');
    _socketService.off('voto_reanudar');
    _socketService.off('voto_reanudar_retirado');
    _socketService.off('pausa_rechazada');
    _socketService.off('partida_pausada');
    _socketService.off('partida_reanudada');
    _socketService.off('roles_asignados');
    _socketService.off('sincronizacion_completada');

    _socketService.on('sincronizacion_completada', (data) async {
      if (data is! Map) return;

      final List<dynamic> mano = data['mano'] ?? [];
      final Map<String, dynamic>? rolRecibido = data['miRol'];

      if (_partidaActual != null && _partidaActual!.jugadorLocal != null) {
        final miId = _partidaActual!.jugadorLocal!;
        final jugadores = _partidaActual!.jugadores.map((j) {
          if (j.id == miId) return j.copyWith(hand: mano);
          return j;
        }).toList();

        _partidaActual = _partidaActual!.copyWith(
          jugadores: jugadores,
          rolesMode: data['mode'] == 'roles',
        );
      }

      if (rolRecibido != null) {
        _miRol = rolRecibido;
        _maxUsosRol = rolRecibido['num_usos_max'] ?? 0;
        _canUseRoleNow = true;
      }

      await _refrescarEstadoDesdeServidor();
      notifyListeners();
    });

    _socketService.on('roles_asignados', (_) => cargarMiRol());

    _socketService.on('partida_iniciada', (data) async {
      _tasaDeRefresco?.cancel();
      if (_partidaActual == null || data is! Map) return;

      _segundosTranscurridos = 0;
      _iniciarCronometro();
      _reiniciarDeadlineTurno();

      final Map<String, dynamic>? rolRecibido = data['miRol'];

      _partidaActual = _partidaActual!.copyWith(
        phase: 'playing',
        rolesMode: data['mode'] == 'roles',
      );

      if (rolRecibido != null) {
        _miRol = rolRecibido;
        _maxUsosRol = rolRecibido['num_usos_max'] ?? 0;
        _usosRol = 0;
        _canUseRoleNow = true;
      }

      await _refrescarEstadoDesdeServidor();
      notifyListeners();
    });

    _socketService.on('partida_iniciada_broadcast', (data) async {
      if (_partidaActual == null || _partidaActual!.phase == 'playing') return;
      _tasaDeRefresco?.cancel();
      _segundosTranscurridos = 0;
      _iniciarCronometro();
      _reiniciarDeadlineTurno();
      if (data is Map && data['mode'] == 'roles') {
        _partidaActual = _partidaActual!.copyWith(rolesMode: true);
      }
      await _refrescarEstadoDesdeServidor();
      notifyListeners();
    });

    void aplicarVotoPausa(dynamic data) {
      if (data is! Map) return;
      _votosPausa = (data['votosActuales'] as int?) ?? _votosPausa;
      final String? jugadorQueVoto = data['jugador']?.toString();
      if (jugadorQueVoto != null && jugadorQueVoto != _partidaActual?.jugadorLocal && !_yoHeVotadoPausa) {
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

    _socketService.on('voto_reanudar', (data) => aplicarPayloadReanudar(data));
    _socketService.on('voto_reanudar_registrado', (data) => aplicarPayloadReanudar(data));

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

      solicitarSincronizacion();

      notifyListeners();
    });

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
        _recompensaUltimaPartida = (data['recompensa'] as int?) ?? 0;
        _monedasTotalesUltimaPartida = data['monedasTotales'] as int?;
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
    _refrescandoEstado = true;
    try {
      final estado = await _repository.obtenerPartida(_partidaActual!.gameId);
      _partidaActual = estado.copyWith(
        code: _partidaActual!.code,
        isPrivate: _partidaActual!.isPrivate,
        jugadorLocal: _partidaActual!.jugadorLocal,
        maxJugadores: _partidaActual!.maxJugadores,
      );
      notifyListeners();
    } on PartidaNoEncontradaException {
      _partidaEliminada = true;
      _tasaDeRefresco?.cancel();
      notifyListeners();
    } catch (_) {}
    finally { _refrescandoEstado = false; }
  }

  Future<void> _refrescarEstadoDesdeServidor() async {
    if (_partidaActual == null || _refrescandoEstado) return;
    _refrescandoEstado = true;
    try {
      final estado = await _repository.obtenerEstadoPartida(_partidaActual!.gameId);

      _partidaEstaPausada = estado.phase == 'paused' || estado.phase == 'pausada';

      _votersReanudar = estado.resumeVoters;
      _votosReanudar = estado.resumeVoters.length;
      _votosPausa = estado.pauseVoters.length;

      final miId = _partidaActual!.jugadorLocal;
      if (miId != null) {
        _yoHeVotadoReanudar = estado.resumeVoters.contains(miId);
        _yoHeVotadoPausa = estado.pauseVoters.contains(miId);
      }

      _partidaActual = estado.copyWith(
        code: _partidaActual!.code,
        isPrivate: _partidaActual!.isPrivate,
        jugadorLocal: _partidaActual!.jugadorLocal,
        maxJugadores: _partidaActual!.maxJugadores,
      );

      if (estado.rolesMode && _miRol == null && estado.phase != 'waiting') {
        cargarMiRol();
      }

      notifyListeners();
    } on PartidaNoEncontradaException {
      _partidaEliminada = true;
      notifyListeners();
    } catch (_) {}
    finally { _refrescandoEstado = false; }
  }

  Future<void> crearPartida({required bool isPrivate, String? jugadorLocal, int maxJugadores = 4, bool modoRoles = false}) async {
    _cargando = true;
    _error = null;
    _maxJugadores = maxJugadores;
    notifyListeners();
    try {
      final partida = await _repository.crearPartida(isPrivate: isPrivate, maxJugadores: maxJugadores, modoRoles: modoRoles);
      List<JugadorPartidaModel> listaInicial = partida.jugadores;
      if (listaInicial.isEmpty) listaInicial = [JugadorPartidaModel(id: jugadorLocal ?? 'Yo')];
      _partidaActual = partida.copyWith(jugadorLocal: jugadorLocal, jugadores: listaInicial, maxJugadores: maxJugadores, isPrivate: isPrivate, rolesMode: modoRoles);
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
    required int maxJugadores,
    required String mode,
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

      _partidaActual = partida.copyWith(
        jugadorLocal: jugadorLocal,
        rolesMode: mode == 'roles',
      );

      _activarTiempoReal();

      await _refrescarLobbyDesdeServidor();

    } catch (e) {
      _error = e.toString();
      debugPrint("Error al buscar partida pública: $_error");
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
      _partidaActual = partida.copyWith(jugadorLocal: jugadorLocal, isPrivate: true, code: code);
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
    _socketService.emitir('comprobar_turno', {'partidaID': _partidaActual!.gameId, 'cartaId': cartaId});
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
      _socketService.on('game_state_updated', (_) {});
      _socketService.off('game_finished');
      _socketService.off('voto_pausa');
      _socketService.off('voto_reanudar');
      _socketService.off('voto_reanudar_retirado');
      _socketService.off('pausa_rechazada');
      _socketService.off('partida_pausada');
      _socketService.off('partida_reanudada');
      _socketService.off('roles_asignados');
      _socketService.off('sincronizacion_completada');
    }
    _partidaActual = null;
    _error = null;
    _maxJugadores = 4;
    _partidaEliminada = false;
    _isVsIA = false;
    _miRol = null;
    _usosRol = 0;
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
      debugPrint("Error al finalizar partida vs IA: $e. Intentando borrar...");
      await abandonarYBorrarPartida();
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
    if (_partidaActual!.phase != 'playing' || _partidaEstaPausada || _isVsIA || !_partidaActual!.isPrivate) return;
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