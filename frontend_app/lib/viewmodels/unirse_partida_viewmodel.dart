import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../views/tablero_view.dart';
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

  bool get cargando => _partidaActualViewModel.cargando;
  String? get error => _partidaActualViewModel.error;

  void setCodigo(String value) {
    _codigo = value;
    notifyListeners();
  }

  final miPerfil = Jugador(
    nombre: "Jugador Beta",
    coins: 100,
    avatarId: "user_avatar",
    skinId: "default",
  );

  Future<void> unirse(BuildContext context) async {
    try {
      await _partidaActualViewModel.unirsePorCodigo(
        _codigo,
        jugadorLocal: miPerfil.nombre,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TableroView(miPerfil: miPerfil),
        ),
      );

      debugPrint(
        'Uniéndose a partida $modoTitulo con código: $_codigo '
            '=> gameId: ${_partidaActualViewModel.partidaActual?.gameId}',
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Error al unirse a la partida'),
        ),
      );
    }
  }
}