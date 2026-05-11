import 'package:flutter/material.dart';
import '../viewmodels/partida_actual_viewmodel.dart';

class UnirsePartidaViewModel extends ChangeNotifier {
  final String modoTitulo;
  final String modoSubtitulo;
  final PartidaActualViewModel _partidaActualViewModel;

  UnirsePartidaViewModel({
    required this.modoTitulo,
    required this.modoSubtitulo,
    required PartidaActualViewModel partidaActualViewModel,
  }) : _partidaActualViewModel = partidaActualViewModel;

  String _codigo = '';
  String get codigo => _codigo;

  String? _mensajeError;
  String? get mensajeError => _mensajeError;

  bool get cargando => _partidaActualViewModel.cargando;

  void setCodigo(String value) {
    _codigo = value;
    _mensajeError = null;
    notifyListeners();
  }

  Future<void> unirse({String? jugadorLocal}) async {
    _mensajeError = null;
    notifyListeners();

    try {
      await _partidaActualViewModel.unirsePorCodigo(
        _codigo,
        jugadorLocal: jugadorLocal,
      );
    } catch (e) {
      if (e.toString().contains('column "codigo" does not exist')) {
        _mensajeError = "Error técnico: El servidor no reconoce la columna 'codigo'.";
      } else {
        _mensajeError = "No se ha encontrado ninguna partida con el código: $_codigo";
      }
      notifyListeners();
      rethrow;
    }
  }
}
