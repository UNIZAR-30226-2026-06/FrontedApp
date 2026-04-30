import 'package:flutter/material.dart';

class AjustesViewModel extends ChangeNotifier {

  bool _musicaActiva = true;
  bool _sonidoActivo = false;
  bool _vibracionActiva = true;

  bool get musicaActiva => _musicaActiva;
  bool get sonidoActivo => _sonidoActivo;
  bool get vibracionActiva => _vibracionActiva;

  void toggleMusica(bool value) {
    _musicaActiva = value;
    notifyListeners();
  }

  void toggleSonido(bool value) {
    _sonidoActivo = value;
    notifyListeners();
  }

  void toggleVibracion(bool value) {
    _vibracionActiva = value;
    notifyListeners();
  }

  void guardarYSalir(BuildContext context, VoidCallback onClose) {
    onClose();
  }
}