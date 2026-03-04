import 'package:flutter/material.dart';

class AjustesViewModel extends ChangeNotifier {

  // Estados iniciales de los ajustes (podrían venir de un SharedPreferences en el futuro)
  bool _musicaActiva = true;
  bool _sonidoActivo = false;
  bool _vibracionActiva = true;

  // Getters para que la View pueda leer el estado
  bool get musicaActiva => _musicaActiva;
  bool get sonidoActivo => _sonidoActivo;
  bool get vibracionActiva => _vibracionActiva;

  // Métodos para cambiar el estado (Toggles)
  void toggleMusica(bool value) {
    _musicaActiva = value;
    // Aquí podrías llamar a un servicio de audio para pausar/reproducir
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

  // Lógica para el botón de cerrar (podría disparar alguna acción extra)
  void guardarYSalir(BuildContext context, VoidCallback onClose) {
    // Aquí guardarías en base de datos local si fuera necesario
    onClose();
  }
}