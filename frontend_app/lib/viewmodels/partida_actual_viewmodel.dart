import 'package:flutter/material.dart';
import '../models/partida_model.dart';
import '../repositories/partida_repository.dart';

class PartidaActualViewModel extends ChangeNotifier {
  final PartidaRepository _repository;

  PartidaActualViewModel(this._repository);

  PartidaModel? _partidaActual;
  PartidaModel? get partidaActual => _partidaActual;

  bool _cargando = false;
  bool get cargando => _cargando;

  String? _error;
  String? get error => _error;

  bool get hayPartidaActiva => _partidaActual != null;

  Future<void> crearPartida({
    required bool isPrivate,
    String? jugadorLocal,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final partida = await _repository.crearPartida(isPrivate: isPrivate);
      _partidaActual = partida.copyWith(jugadorLocal: jugadorLocal);
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