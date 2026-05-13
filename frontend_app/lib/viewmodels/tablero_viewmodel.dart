import 'package:flutter/material.dart';
import 'partida_actual_viewmodel.dart';

class TableroViewModel extends ChangeNotifier {
  final PartidaActualViewModel _partidaViewModel;

  bool _mostrandoAjustes = false;
  bool get mostrandoAjustes => _mostrandoAjustes;

  bool _mostrandoRol = false;
  bool get mostrandoRol => _mostrandoRol;

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

  void abrirRol() {
    _mostrandoRol = true;
    notifyListeners();
  }

  void cerrarRol() {
    _mostrandoRol = false;
    notifyListeners();
  }
}