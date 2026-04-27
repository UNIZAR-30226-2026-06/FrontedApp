import 'package:flutter/material.dart';
import '../viewmodels/partida_actual_viewmodel.dart';

class MultijugadorMenuCartasViewModel extends ChangeNotifier {
  final String modoTitulo;
  final String modoSubtitulo1;
  final String modoSubtitulo2;
  final PartidaActualViewModel _partidaActualViewModel;

  MultijugadorMenuCartasViewModel({
    required this.modoTitulo,
    required this.modoSubtitulo1,
    required this.modoSubtitulo2,
    required PartidaActualViewModel partidaActualViewModel,
  }) : _partidaActualViewModel = partidaActualViewModel;

  bool get cargando => _partidaActualViewModel.cargando;
  String? get error => _partidaActualViewModel.error;

  Future<void> crearPartida(
      BuildContext context, {
        required bool isPrivate,
        String? jugadorLocal,
      }) async {
    try {
      await _partidaActualViewModel.crearPartida(
        isPrivate: isPrivate,
        jugadorLocal: jugadorLocal,
      );

      final partida = _partidaActualViewModel.partidaActual;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Partida creada. GameId: ${partida?.gameId ?? "-"}'
                '${partida?.code != null ? ' | Código: ${partida!.code}' : ''}',
          ),
        ),
      );

      notifyListeners();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al crear la partida'),
        ),
      );
    }
  }
}