import 'package:flutter/material.dart';
import 'partida_actual_viewmodel.dart';

class TableroViewModel extends ChangeNotifier {
  final PartidaActualViewModel _partidaViewModel;

  bool _mostrandoAjustes = false;
  bool get mostrandoAjustes => _mostrandoAjustes;

  TableroViewModel(this._partidaViewModel);

  //Funciones
  void robarCarta() {
    _partidaViewModel.robarCarta();
  }

  void intentarTirarCarta(String cartaId) {
    debugPrint("Intentando tirar la carta: $cartaId");
    _partidaViewModel.jugarCarta(cartaId);
  }

  void abrirAjustes() {
    _mostrandoAjustes = true;
    notifyListeners();
  }

  void cerrarAjustes() {
    _mostrandoAjustes = false;
    notifyListeners();
  }
}