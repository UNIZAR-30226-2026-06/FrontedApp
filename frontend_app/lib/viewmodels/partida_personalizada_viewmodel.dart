import 'package:flutter/material.dart';
import 'partida_actual_viewmodel.dart';
import '../views/sala_espera_view.dart';
import '../views/unirse_partida_view.dart';

enum ModoPersonalizado { normal, roles, cartasEspeciales }

class PartidaPersonalizadaViewModel extends ChangeNotifier {
  // Toggles independientes. Invariante: siempre al menos uno activo.
  final Set<ModoPersonalizado> _modos = {ModoPersonalizado.normal};

  bool isModoActivo(ModoPersonalizado m) => _modos.contains(m);

  /// Invierte el toggle. Si dejaría todos apagados, no aplica el cambio.
  void toggleModo(ModoPersonalizado m) {
    final next = {..._modos};
    if (next.contains(m)) {
      next.remove(m);
    } else {
      next.add(m);
    }
    if (next.isEmpty) return; // mantenemos la invariante
    _modos
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  bool get modoRoles => _modos.contains(ModoPersonalizado.roles);
  bool get modoCartasEspeciales =>
      _modos.contains(ModoPersonalizado.cartasEspeciales);

  /// Texto resumen, ej: "Normal + Roles" o "Roles + Cartas esp.".
  String get summary {
    const orden = [
      ModoPersonalizado.normal,
      ModoPersonalizado.roles,
      ModoPersonalizado.cartasEspeciales,
    ];
    return orden.where(_modos.contains).map(_labelDe).join(' + ');
  }

  static String _labelDe(ModoPersonalizado m) {
    switch (m) {
      case ModoPersonalizado.normal:
        return 'Normal';
      case ModoPersonalizado.roles:
        return 'Roles';
      case ModoPersonalizado.cartasEspeciales:
        return 'Cartas esp.';
    }
  }

  int _numCartas = 7;
  int get numCartas => _numCartas;

  static const int minCartas = 5;
  static const int maxCartas = 15;

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

  // Toggles decorativos (no se persisten en backend).
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

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  static const String tituloModo = 'Partida personalizada';

  /// Crea la sala con la configuración elegida y navega a la sala de espera.
  /// Lobby siempre con maxJugadores=4. El host iniciará desde la sala cuando
  /// haya al menos 2 jugadores. NO se auto-inicia desde aquí.
  Future<void> crearPartida(
    BuildContext context,
    PartidaActualViewModel partidaVm, {
    String? jugadorLocal,
  }) async {
    if (_isCreating) return;
    _isCreating = true;
    notifyListeners();

    try {
      await partidaVm.crearPartida(
        isPrivate: true,
        maxJugadores: 4,
        jugadorLocal: jugadorLocal,
        modoRoles: modoRoles,
        modoCartasEspeciales: modoCartasEspeciales,
        numCartasInicio: _numCartas,
      );

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SalaEsperaView(
            modoJuego: tituloModo,
            // personalizada: ≥2 jugadores basta (el host decide cuándo empezar)
            requiereSalaLlena: false,
          ),
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
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Abre la pantalla para introducir el código y unirse a una partida
  /// personalizada de otro host.
  void unirsePartida(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UnirsePartidaView(
          modoTitulo: tituloModo,
          modoSubtitulo: 'Unirse con código',
          // personalizada: ≥2 jugadores basta
          requiereSalaLlena: false,
        ),
      ),
    );
  }
}
