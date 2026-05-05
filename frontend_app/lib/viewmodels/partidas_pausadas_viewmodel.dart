import 'package:flutter/material.dart';
import '../models/partida_model.dart';
import '../repositories/partida_repository.dart';
import 'partida_actual_viewmodel.dart';
import '../views/tablero_view.dart';
import '../models/jugador_model.dart';

class PartidasPausadasViewModel extends ChangeNotifier {
  final PartidaRepository _repository;
  final Jugador miPerfil;

  PartidasPausadasViewModel(this._repository, this.miPerfil);

  List<PartidaModel> _partidas = [];
  List<PartidaModel> get partidas => _partidas;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> cargarPartidasPausadas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _partidas = await _repository.obtenerPartidasPausadas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reanudarPartida(BuildContext context, String gameId, PartidaActualViewModel partidaActualVm) async {
    try {
      // 1. Llamamos al repo para reanudar (backend cambia estado a 'playing' o similar)
      final partida = await _repository.reanudarPartida(gameId);
      
      // 2. Actualizamos el ViewModel global de la partida actual
      // (Podríamos necesitar un método en partidaActualVm para 'setear' una partida ya existente)
      // partidaActualVm.setPartidaActual(partida); 

      // 3. Navegamos al tablero
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TableroView(miPerfil: miPerfil)),
        );
      }
    } catch (e) {
      _error = "No se pudo reanudar: $e";
      notifyListeners();
    }
  }
}
