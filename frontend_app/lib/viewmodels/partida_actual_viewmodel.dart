import 'dart:async';

import 'package:flutter/material.dart';
import '../models/partida_model.dart';
import '../models/jugador_partida_model.dart';
import '../models/resultado_partida_model.dart';
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

  // True si soy el creador de la partida. Lo seteamos explícitamente en
  // crearPartida() / unirsePorCodigo() — más fiable que inferirlo del orden
  // de `jugadores` (el backend puede devolverlo en cualquier orden).
  bool _soyHost = false;
  bool get soyHost => _soyHost;

  // Datos del evento `game_finished`: ganador, recompensas, lista por jugador.
  // Se rellena cuando llega el evento de fin de partida desde el backend.
  ResultadoPartida? _resultadoFinal;
  ResultadoPartida? get resultadoFinal => _resultadoFinal;

  // True mientras estamos reintentando obtener la mano inicial desde el
  // backend. La UI puede usarlo para mostrar un indicador "cargando partida".
  bool _esperandoManoInicial = false;
  bool get esperandoManoInicial => _esperandoManoInicial;

  // Token incremental para invalidar polls anteriores: cada llamada nueva a
  // _garantizarManoCompleta toma un token y si el token cambia mientras está
  // corriendo, abandona. Evita carreras entre múltiples partida_iniciada.
  int _pollManoToken = 0;

  // GameId para el que están registrados los listeners actualmente. Evita que
  // se registren múltiples veces tras hot reload o tras varias activaciones.
  String? _listenersGameId;

  // Voto de pausa entrante de OTRO jugador. Mientras esté !=null, la UI del
  // tablero muestra un banner para aceptar/rechazar la pausa. Auto-expira en
  // 15 s (controlado por un Timer); también se limpia al votar o al recibir
  // `pausa_rechazada` / `partida_pausada` / `partida_reanudada`.
  String? _solicitudPausaDe;
  String? get solicitudPausaDe => _solicitudPausaDe;
  Timer? _solicitudPausaTimer;

  // Timeout para el votante: si pasa 15 s sin respuesta del backend
  // (partida_pausada / pausa_rechazada), reseteamos `_yoHeVotadoPausa`
  // para que el usuario pueda volver a intentarlo. Sin esto, el botón se
  // queda en "ESPERANDO" para siempre.
  Timer? _votoPausaTimer;

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

  /// Espera (event-driven, sin polling) a que `partidaActual.jugadores` tenga
  /// al menos `esperados` jugadores. Resuelve cuando se alcanza la cuota o
  /// cuando se agota el `timeout`. Útil antes de `iniciarPartida` con bots:
  /// los bots se añaden vía HTTP `add-bot` y el backend confirma vía socket
  /// `bot_unido`. Sólo cuando hemos recibido los `esperados - 1` eventos
  /// (el host ya estaba al crear) podemos arrancar con seguridad.
  Future<bool> esperarHastaQueHayaJugadores(
    int esperados, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    int actuales() => _partidaActual?.jugadores.length ?? 0;
    if (actuales() >= esperados) return true;

    final completer = Completer<bool>();
    late final VoidCallback listener;
    listener = () {
      if (!completer.isCompleted && actuales() >= esperados) {
        completer.complete(true);
      }
    };
    addListener(listener);

    Timer? t;
    t = Timer(timeout, () {
      if (!completer.isCompleted) {
        debugPrint(
          '[VM] esperarHastaQueHayaJugadores timeout '
          '(${actuales()}/$esperados tras ${timeout.inMilliseconds}ms)',
        );
        completer.complete(false);
      }
    });

    try {
      return await completer.future;
    } finally {
      t.cancel();
      removeListener(listener);
    }
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
    if (_socketService.socket == null || _partidaActual == null) return;

    final String gameId = _partidaActual!.gameId;

    // Idempotente: si los listeners ya están registrados para este gameId,
    // no los volvemos a registrar. Evita duplicación tras hot reload o tras
    // que un flujo llame _activarTiempoReal más de una vez.
    if (_listenersGameId == gameId) {
      debugPrint('[VM] _activarTiempoReal: listeners ya activos para $gameId, skip');
      return;
    }
    _listenersGameId = gameId;

    // Limpieza de listeners (catch-all + específicos)
    _socketService.socket!.offAny();
    _socketService.socket!.off('partida_iniciada');
    _socketService.socket!.off('nuevo_jugador');
    _socketService.socket!.off('error_partida');
    _socketService.socket!.off('turno_siguiente');
    _socketService.socket!.off('game_state_updated');
    _socketService.socket!.off('bot_action');
    _socketService.socket!.off('carta_robada');
    _socketService.socket!.off('game_finished');
    _socketService.socket!.off('voto_pausa_registrado');
    _socketService.socket!.off('voto_reanudar_registrado');
    _socketService.socket!.off('partida_pausada');
    _socketService.socket!.off('partida_reanudada');

    _socketService.emitir('unirse_partida', {'partidaID': gameId});
    debugPrint('[VM] Emitido unirse_partida para $gameId, jugadorLocal=${_partidaActual!.jugadorLocal}');

    // Defensa CRÍTICA: si el socket se reconecta (hot reload, suspensión de
    // la app, blip de red), el backend pierde el `socket.join(roomId)` y
    // este cliente deja de recibir broadcasts (incluido `voto_pausa`,
    // `partida_pausada`, `partida_iniciada` para futuros restarts, etc.).
    // Re-emitimos `unirse_partida` ante cada conexión para garantizar que
    // siempre estamos en la room del juego activo.
    _socketService.socket!.off('connect');
    _socketService.socket!.on('connect', (_) {
      final activo = _partidaActual?.gameId;
      if (activo != null) {
        debugPrint('[VM] socket reconectado, re-uniendo a room $activo');
        _socketService.emitir('unirse_partida', {'partidaID': activo});
      }
    });

    // Refresh defensivo: en cuanto el backend procesa el unirse_partida (~200 ms),
    // pedimos el estado completo para hidratar la lista de jugadores del lobby
    // con quienes ya estuvieran ahí (host y joiners anteriores). Sin esto, un
    // joiner que llega tarde solo se ve a sí mismo hasta que el host emite
    // `nuevo_jugador`, lo cual puede no ocurrir si Render hace round-trips lentos.
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_partidaActual?.gameId == gameId) {
        _refrescarEstadoDesdeServidor();
      }
    });

    _socketService.socket!.onAny((event, data) {
      debugPrint('[VM][socket<<] $event :: ${data.toString().substring(0, data.toString().length.clamp(0, 240))}');
    });

    _socketService.socket!.on('partida_iniciada', (data) {
      debugPrint('[VM] partida_iniciada recibido. Llaves: ${(data is Map) ? data.keys.toList() : 'no es Map'}');
      if (_partidaActual == null) return;

      // El backend emite DOS eventos al iniciar: un broadcast (sin manoInicial)
      // y uno dirigido a cada jugador (con manoInicial). Solo procesamos la
      // mano si el payload realmente la trae con contenido — si no, no
      // machacamos la mano que ya tenemos.
      final dynamic mano = (data is Map) ? data['manoInicial'] : null;
      final bool traeMano = mano is List && mano.isNotEmpty;

      final miId = _partidaActual!.jugadorLocal ?? 'yo';
      debugPrint('[VM] traeMano=$traeMano (${mano is List ? mano.length : "?"}) miId=$miId ids=${_partidaActual!.jugadores.map((j) => j.id).toList()}');

      List<JugadorPartidaModel> jugadoresActualizados =
          _partidaActual!.jugadores;
      if (traeMano) {
        jugadoresActualizados = _partidaActual!.jugadores.map((j) {
          if (j.id == miId) {
            return JugadorPartidaModel(id: j.id, hand: mano);
          }
          return j;
        }).toList();
        if (!jugadoresActualizados.any((j) => j.id == miId)) {
          jugadoresActualizados = [
            ...jugadoresActualizados,
            JugadorPartidaModel(id: miId, hand: mano),
          ];
        }
      }

      _partidaActual = _partidaActual!.copyWith(
        phase: 'playing',
        rolesMode: data['modoJuego'] == 'roles' ||
            data['mode'] == 'roles' ||
            _partidaActual!.rolesMode,
        specialCardsMode: data['modoJuego'] == 'cards' ||
            data['mode'] == 'cards' ||
            _partidaActual!.specialCardsMode,
        jugadores: jugadoresActualizados,
      );
      notifyListeners();
      // Aunque haya llegado manoInicial vacía o no haya llegado, intentamos
      // garantizar que la mano local se carga vía REST hasta un máximo de
      // intentos. Determinismo desde el cliente: si el backend tiene la
      // partida bien repartida, esto siempre converge.
      _garantizarManoCompleta();
    });

    _socketService.socket!.on('voto_pausa_registrado', (data) {
      _votosPausa = data['votosActuales'] ?? data['votosFavor'] ?? 0;
      final String? jugadorQueVoto = data['jugador'];

      notifyListeners();

      if (jugadorQueVoto != null) {
        debugPrint("El jugador $jugadorQueVoto acaba de votar para pausar.");
      }
    });

    _socketService.socket!.on('voto_reanudar_registrado', (data) {
      _votosReanudar = data['votosActuales'] ?? data['votosFavor'] ?? 0;
      final String? jugadorQueVoto = data['jugador'];

      notifyListeners();

      if (jugadorQueVoto != null) {
        debugPrint("El jugador $jugadorQueVoto acaba de votar para reanudar.");
      }
    });

    // OTRO jugador acaba de solicitar pausar. Mostramos banner en cliente.
    _socketService.socket!.on('voto_pausa', (data) {
      if (data is! Map) return;
      final quien = data['jugador']?.toString();
      if (quien == null || quien == _partidaActual?.jugadorLocal) return;
      _solicitudPausaDe = quien;
      _solicitudPausaTimer?.cancel();
      _solicitudPausaTimer = Timer(const Duration(seconds: 15), () {
        if (_solicitudPausaDe != null) {
          debugPrint('[VM] solicitud pausa expirada (15s sin responder)');
          _dismissSolicitudPausa();
        }
      });
      notifyListeners();
    });

    // Backend confirma rechazo (alguien votó NO). Reseteo banner y votos.
    _socketService.socket!.on('pausa_rechazada', (_) {
      debugPrint('[VM] pausa_rechazada recibido');
      _dismissSolicitudPausa();
      _votosPausa = 0;
      _yoHeVotadoPausa = false;
      _votoPausaTimer?.cancel();
      notifyListeners();
    });

    _socketService.socket!.on('partida_pausada', (_) {
      debugPrint('[VM] partida_pausada recibido');
      _partidaEstaPausada = true;
      _votosPausa = 0;
      _yoHeVotadoPausa = false;
      _votosReanudar = 0;
      _yoHeVotadoReanudar = false;
      _dismissSolicitudPausa();
      _votoPausaTimer?.cancel();
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

    _socketService.socket!.on('bot_unido', (data) {
      if (_partidaActual == null || data is! Map) return;
      // El backend nos puede mandar la lista entera (playersIds) o sólo el
      // botId individual. Preferimos la lista entera porque es la fuente de
      // verdad — los lobby con varios bots evitan races aquí.
      final List<String> ids = (data['playersIds'] is List)
          ? (data['playersIds'] as List).whereType<String>().toList()
          : <String>[];
      final String? botId = data['botId'] as String?;

      if (ids.isNotEmpty) {
        // Reconstruimos la lista de jugadores conservando las manos que ya
        // teníamos (si las hubiera) y añadiendo los IDs que falten.
        final existentes = {
          for (final j in _partidaActual!.jugadores) j.id: j,
        };
        final nueva = [
          for (final id in ids)
            existentes[id] ?? JugadorPartidaModel(id: id),
        ];
        _partidaActual = _partidaActual!.copyWith(jugadores: nueva);
      } else if (botId != null) {
        // Fallback: añadir el bot con dedup.
        if (_partidaActual!.jugadores.any((j) => j.id == botId)) return;
        final lista = List<JugadorPartidaModel>.from(_partidaActual!.jugadores)
          ..add(JugadorPartidaModel(id: botId));
        _partidaActual = _partidaActual!.copyWith(jugadores: lista);
      } else {
        return;
      }
      debugPrint('[VM] bot_unido aplicado. jugadores=${_partidaActual!.jugadores.map((j) => j.id).toList()}');
      notifyListeners();
    });

    _socketService.socket!.on('nuevo_jugador', (data) {
      if (_partidaActual != null) {
        final String? nuevoId = data is Map ? data['jugador'] as String? : null;
        if (nuevoId == null) return;
        // Dedup: el backend a veces re-emite nuevo_jugador (reconexiones, etc.).
        // Si el id ya está en la lista no lo añadimos otra vez.
        if (_partidaActual!.jugadores.any((j) => j.id == nuevoId)) {
          debugPrint('[VM] nuevo_jugador ignorado (duplicado): $nuevoId');
          return;
        }
        final nuevoJugador = JugadorPartidaModel(id: nuevoId);
        final listaActualizada = List<JugadorPartidaModel>.from(
          _partidaActual!.jugadores,
        )..add(nuevoJugador);

        _partidaActual = _partidaActual!.copyWith(jugadores: listaActualizada);
        notifyListeners();
      }
    });

    _socketService.socket!.on('error_partida', (data) {
      debugPrint('[VM] error_partida: $data');
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
      if (data is Map) {
        try {
          _resultadoFinal = ResultadoPartida.fromJson(
            Map<String, dynamic>.from(data),
          );
        } catch (e) {
          debugPrint('[VM] No se pudo parsear game_finished: $e');
        }
      }
      if (_partidaActual != null) {
        _partidaActual = _partidaActual!.copyWith(phase: 'finished');
      }
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

  /// Hace polling contra `GET /partidas/:id/state` hasta que la mano del
  /// jugador local llegue poblada, o se agoten los intentos. Útil cuando el
  /// socket emite `partida_iniciada` con `manoInicial=[]` (race de backend):
  /// el state REST acaba siendo consistente y aquí nos sincronizamos.
  ///
  /// Idempotente vía `_pollManoToken`: si alguien llama otra vez mientras
  /// corre, la primera ejecución se aborta.
  Future<void> _garantizarManoCompleta({
    int intentos = 5,
    Duration delay = const Duration(milliseconds: 600),
  }) async {
    final miToken = ++_pollManoToken;
    if (_partidaActual == null) return;

    _esperandoManoInicial = true;
    notifyListeners();

    try {
      for (int i = 0; i < intentos; i++) {
        await _refrescarEstadoDesdeServidor();
        // Si alguien lanzó otra ronda de polling, dejamos que la nueva siga.
        if (miToken != _pollManoToken) return;
        if (_partidaActual == null) return;

        final miId = _partidaActual!.jugadorLocal ?? '';
        final miJugador = _partidaActual!.jugadores
            .where((p) => p.id == miId)
            .cast<JugadorPartidaModel?>()
            .firstWhere((_) => true, orElse: () => null);
        final tieneCartas =
            miJugador != null && miJugador.hand.isNotEmpty;

        if (tieneCartas) {
          debugPrint('[VM] mano cargada tras ${i + 1} intento(s)');
          return;
        }
        if (i < intentos - 1) {
          await Future.delayed(delay);
        }
      }
      debugPrint(
        '[VM] mano vacía tras $intentos intentos — backend probably corrupto',
      );
    } finally {
      // Sólo el token actual apaga el flag (otra ronda podría estar corriendo).
      if (miToken == _pollManoToken) {
        _esperandoManoInicial = false;
        notifyListeners();
      }
    }
  }

  Future<void> crearPartida({
    required bool isPrivate,
    String? jugadorLocal,
    int maxJugadores = 4,
    bool modoCartasEspeciales = true,
    bool modoRoles = false,
    int numCartasInicio = 7,
  }) async {
    _cargando = true;
    _error = null;
    _maxJugadores = maxJugadores;
    notifyListeners();

    try {
      // Cleanup defensivo: borramos cualquier partida zombie mía (lobbies sin
      // cerrar, partidas que quedaron colgadas por kill brusco). Esto evita
      // que el backend confunda la nueva sesión con residuos de la anterior.
      // Si el cleanup falla, no abortamos: la creación puede seguir su curso.
      try {
        final n = await _repository.cleanupMisPartidas();
        if (n > 0) debugPrint('[VM] cleanup pre-crear: $n partida(s) zombie eliminada(s)');
      } catch (e) {
        debugPrint('[VM] cleanup pre-crear falló (no crítico): $e');
      }

      final partida = await _repository.crearPartida(
        isPrivate: isPrivate,
        maxJugadores: maxJugadores,
        modoCartasEspeciales: modoCartasEspeciales,
        modoRoles: modoRoles,
        numCartasInicio: numCartasInicio,
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
      _soyHost = true; // creador de la partida
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
      _soyHost = false; // me uno a sala existente
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
      // Mismo cleanup que en crearPartida: garantiza que no hay partidas mías
      // zombie antes de meterme en una nueva como joiner.
      try {
        final n = await _repository.cleanupMisPartidas();
        if (n > 0) debugPrint('[VM] cleanup pre-unirse: $n partida(s) zombie eliminada(s)');
      } catch (e) {
        debugPrint('[VM] cleanup pre-unirse falló (no crítico): $e');
      }

      final partida = await _repository.unirsePorCodigo(code);
      _partidaActual = partida.copyWith(jugadorLocal: jugadorLocal);
      _soyHost = false; // me uno por código, nunca soy host
      // Importante: alinear `_maxJugadores` con el valor real que viene en la
      // partida. Sin esto, el VM se queda en 4 (default) y la sala muestra
      // "X/4" aunque la partida tenga max 2 — y la lógica de "sala llena"
      // nunca se cumple.
      if (partida.maxJugadores > 0) {
        _maxJugadores = partida.maxJugadores;
      }
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
      _socketService.socket!.offAny();
      _socketService.socket!.off('partida_iniciada');
      _socketService.socket!.off('nuevo_jugador');
      _socketService.socket!.off('error_partida');
      _socketService.socket!.off('turno_siguiente');
      _socketService.socket!.off('game_state_updated');
      _socketService.socket!.off('bot_action');
      _socketService.socket!.off('carta_robada');
      _socketService.socket!.off('game_finished');
      _socketService.socket!.off('voto_pausa_registrado');
      _socketService.socket!.off('voto_reanudar_registrado');
      _socketService.socket!.off('partida_pausada');
      _socketService.socket!.off('partida_reanudada');
      _socketService.socket!.off('voto_pausa');
      _socketService.socket!.off('pausa_rechazada');
      _socketService.socket!.off('connect');
    }
    _partidaActual = null;
    _error = null;
    _soyHost = false;
    _listenersGameId = null;
    _resultadoFinal = null;
    _esperandoManoInicial = false;
    _pollManoToken++; // invalida cualquier polling de mano en curso
    _dismissSolicitudPausa();
    _votoPausaTimer?.cancel();
    _votoPausaTimer = null;

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

    // Caso "reanudar partida pausada": el creador real podría ser otro.
    // Por seguridad lo dejamos en false; quien quiera iniciar usará la
    // lógica del backend.
    _soyHost = false;
    _activarTiempoReal();
    notifyListeners();
  }

  /// El usuario local INICIA una votación de pausa. Emite `jugador_solicita_pausa`
  /// por socket — así el backend hace broadcast a los demás jugadores como
  /// `voto_pausa`. Cada cliente que reciba ese broadcast verá el banner para
  /// votar (a través de `solicitudPausaDe`).
  Future<void> emitirVotoPausa() async {
    if (_partidaActual == null || _yoHeVotadoPausa) return;
    if (_socketService.socket == null) {
      debugPrint('[VM] emitirVotoPausa abortado: socket null');
      return;
    }
    final gameId = _partidaActual!.gameId;
    debugPrint('[VM] emitiendo jugador_solicita_pausa para $gameId');
    _socketService.emitir('jugador_solicita_pausa', {
      'partidaID': gameId,
    });
    _yoHeVotadoPausa = true;
    _votosPausa = 1; // mi voto cuenta; el backend confirmará el total
    notifyListeners();
    _armarTimeoutVotoPausa();
  }

  /// Si en 15 s no llega `partida_pausada` ni `pausa_rechazada`, antes de
  /// resetear hacemos un GET defensivo a `/state` para chequear si el backend
  /// SÍ procesó la pausa pero el broadcast socket nunca llegó (típico cuando
  /// un cliente perdió la room por una reconexión). Si la partida está
  /// realmente pausada en backend, simulamos localmente `partida_pausada`.
  /// Si no, reseteamos el voto.
  void _armarTimeoutVotoPausa() {
    _votoPausaTimer?.cancel();
    _votoPausaTimer = Timer(const Duration(seconds: 15), () async {
      if (!_yoHeVotadoPausa || _partidaEstaPausada) return;

      debugPrint('[VM] voto pausa: timeout 15s, comprobando state…');
      try {
        final id = _partidaActual?.gameId;
        if (id != null) {
          final estado = await _repository.obtenerEstadoPartida(id);
          if (estado.phase == 'paused') {
            debugPrint('[VM] backend tenía la partida pausada, sincronizo');
            _partidaEstaPausada = true;
            _votosPausa = 0;
            _yoHeVotadoPausa = false;
            _votosReanudar = 0;
            _yoHeVotadoReanudar = false;
            _dismissSolicitudPausa();
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        debugPrint('[VM] error comprobando state en timeout: $e');
      }

      debugPrint('[VM] voto pausa: nadie respondió, reset');
      _yoHeVotadoPausa = false;
      _votosPausa = 0;
      notifyListeners();
    });
  }

  /// El usuario CONFIRMA un voto de pausa que otro jugador inició. Emite
  /// `jugador_voto_pausa` socket. Si con este voto se alcanza unanimidad,
  /// el backend emite `partida_pausada` a la sala.
  void confirmarVotoPausa() {
    if (_partidaActual == null) return;
    _yoHeVotadoPausa = true;
    _dismissSolicitudPausa();
    notifyListeners();
    _socketService.emitir('jugador_voto_pausa', {
      'partidaID': _partidaActual!.gameId,
    });
  }

  /// El usuario RECHAZA la pausa propuesta. Emite `jugador_rechaza_pausa`
  /// socket → backend broadcastea `pausa_rechazada` a todos.
  void rechazarVotoPausa() {
    if (_partidaActual == null) return;
    _dismissSolicitudPausa();
    notifyListeners();
    _socketService.emitir('jugador_rechaza_pausa', {
      'partidaID': _partidaActual!.gameId,
    });
  }

  void _dismissSolicitudPausa() {
    _solicitudPausaTimer?.cancel();
    _solicitudPausaTimer = null;
    _solicitudPausaDe = null;
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
