import 'package:flutter/material.dart';
import '../models/partida_model.dart';
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

  void _activarTiempoReal() {
    if (_socketService.socket == null || _partidaActual == null) return;

    final String gameId = _partidaActual!.gameId;

    _socketService.socket!.off('partida_actualizada');
    _socketService.socket!.off('nuevoMensajeChat');

    _socketService.emitir('join_game', {'gameId': gameId});

    _socketService.socket!.on('partida_actualizada', (data) {
      notifyListeners();
      debugPrint("Partida $gameId actualizada por socket");
    });

    _socketService.socket!.on('nuevoMensajeChat', (data) {
      debugPrint("💬 Nuevo mensaje en partida $gameId: $data");
    });
  }


  Future<void> crearPartida({required bool isPrivate, String? jugadorLocal}) async {
    _cargando = true;
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
      _activarTiempoReal(); // <--- Uso de la función unificada
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
      _activarTiempoReal(); // <--- Limpio y consistente con los otros métodos
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> recargarEstado() async {
    if (_partidaActual == null) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _partidaActual = await _repository.obtenerPartida(_partidaActual!.gameId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> finalizarPartida() async {
    if (_partidaActual == null) return;

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.finalizarPartida(_partidaActual!.gameId);
      _partidaActual = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void limpiarPartida() {
    _partidaActual = null;
    _error = null;
    notifyListeners();
  }

}