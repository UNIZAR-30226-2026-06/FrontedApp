import 'package:flutter/material.dart';
import 'partida_actual_viewmodel.dart';
import '../views/tablero_view.dart';

enum ReglaPersonalizada { normal, roles, cartasEspeciales }

class PartidaPersonalizadaViewModel extends ChangeNotifier {
  ReglaPersonalizada _regla = ReglaPersonalizada.normal;
  ReglaPersonalizada get regla => _regla;

  void setRegla(ReglaPersonalizada value) {
    _regla = value;
    notifyListeners();
  }

  int _numCartas = 7;
  int get numCartas => _numCartas;

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

  Future<void> crearPartida(BuildContext context, PartidaActualViewModel partidaVm) async {
    try {

      await partidaVm.crearPartida(isPrivate: true);

      partidaVm.iniciarPartida();

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TableroView(),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear la partida personalizada: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}