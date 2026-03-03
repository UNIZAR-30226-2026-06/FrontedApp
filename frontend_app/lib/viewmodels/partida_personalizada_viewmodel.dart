import 'package:flutter/material.dart';

enum ReglaPersonalizada { normal, roles, cartasEspeciales }

class PartidaPersonalizadaViewModel extends ChangeNotifier {
  // Selección de reglas
  ReglaPersonalizada _regla = ReglaPersonalizada.normal;
  ReglaPersonalizada get regla => _regla;

  void setRegla(ReglaPersonalizada value) {
    _regla = value;
    notifyListeners();
  }

  // Número de cartas
  int _numCartas = 7; // como en tu mock
  int get numCartas => _numCartas;

  // Ajusta límites si quieres (yo dejo algo razonable)
  static const int minCartas = 3;
  static const int maxCartas = 20;

  void incCartas() {
    if (_numCartas < maxCartas) {
      _numCartas++;
      notifyListeners();
    }
  }

  void decCartas() {
    if (_numCartas > minCartas) {
      _numCartas--;
      notifyListeners();
    }
  }

  // Toggles
  bool _musica = true;
  bool get musica => _musica;
  void toggleMusica(bool v) {
    _musica = v;
    notifyListeners();
  }

  bool _sonido = false;
  bool get sonido => _sonido;
  void toggleSonido(bool v) {
    _sonido = v;
    notifyListeners();
  }

  bool _vibracion = true;
  bool get vibracion => _vibracion;
  void toggleVibracion(bool v) {
    _vibracion = v;
    notifyListeners();
  }

  // Acción abierta
  void crearPartida(BuildContext context) {
    final reglaTxt = switch (_regla) {
      ReglaPersonalizada.normal => 'Normal',
      ReglaPersonalizada.roles => 'Roles',
      ReglaPersonalizada.cartasEspeciales => 'Cartas esp.',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Crear partida (pendiente) | Regla: $reglaTxt | Cartas: $_numCartas | '
              'Música: ${_musica ? "ON" : "OFF"} | Sonido: ${_sonido ? "ON" : "OFF"} | Vibración: ${_vibracion ? "ON" : "OFF"}',
        ),
      ),
    );
  }
}