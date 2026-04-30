import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/tablero_viewmodel.dart';
import '../viewmodels/partida_actual_viewmodel.dart';
import '../models/carta_model.dart';
import '../models/jugador_partida_model.dart';

import 'package:frontend_app/views/ajustes_overlay.dart';
import 'package:frontend_app/views/widgets/avatar_jugador_widget.dart';
import 'package:frontend_app/views/widgets/carta_widget.dart';
import 'package:frontend_app/views/widgets/mazo_central_widget.dart';

class TableroView extends StatelessWidget {
  const TableroView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TableroViewModel>();
    final partidaVm = context.watch<PartidaActualViewModel>();
    final partida = partidaVm.partidaActual;

    if (partida == null || partida.jugadores.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00FFFF)),
        ),
      );
    }

    // Identificar al jugador local y a los rivales
    final String miId = partida.jugadorLocal ?? '';
    final JugadorPartidaModel? miJugador = partida.jugadores
        .where((p) => p.id == miId)
        .firstOrNull;

    final List<JugadorPartidaModel> rivales = partida.jugadores
        .where((p) => p.id != miId)
        .toList();

    final bool esMiTurno = partida.esMiTurno(miId);

    // Función auxiliar para saber el turno de un rival
    bool esTurnoDeRival(String rivalId) {
      if (partida.jugadores.isEmpty) return false;
      return partida.jugadores[partida.currentTurn % partida.jugadores.length].id == rivalId;
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildFondo(),

          if (rivales.isNotEmpty)
            Positioned(
              top: 150, left: 40,
              child: AvatarJugadorWidget(
                participante: rivales[0],
                esSuTurno: esTurnoDeRival(rivales[0].id),
              ),
            ),

          if (rivales.length > 1)
            Positioned(
              top: 80, left: 0, right: 0,
              child: Center(
                child: AvatarJugadorWidget(
                  participante: rivales[1],
                  esSuTurno: esTurnoDeRival(rivales[1].id),
                ),
              ),
            ),

          if (rivales.length > 2)
            Positioned(
              top: 150, right: 40,
              child: AvatarJugadorWidget(
                participante: rivales[2],
                esSuTurno: esTurnoDeRival(rivales[2].id),
              ),
            ),

          // Mazo central
          Center(
            child: MazoCentralWidget(
              // Si el backend envía la carta como JSON, mapearla a CartaModel
              cartaEnMesa: partida.currentCard != null
                  ? Carta.fromJson(partida.currentCard)
                  : null,
              onRobar: esMiTurno ? () => vm.robarCarta() : () {},
            ),
          ),

          _buildTopBar(vm),

          // Mano del jugador local
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (esMiTurno)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "¡TU TURNO!",
                      style: TextStyle(
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: (miJugador?.hand ?? []).map((cartaData) {
                        final carta = Carta.fromJson(cartaData);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: CartaWidget(
                            carta: carta,
                            onTap: esMiTurno
                                ? () => vm.intentarTirarCarta(carta.id)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (vm.mostrandoAjustes)
            Positioned.fill(
              child: AjustesOverlay(
                onClose: () => vm.cerrarAjustes(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFondo() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/tableroFuturista.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTopBar(TableroViewModel vm) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/logo.png', height: 40),
            const Text(
                "0:00",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)
            ),

            _AnimatedPauseButton(
              onTap: () {
                debugPrint("Solicitar pausa al backend");
                // vm.solicitarPausa(); // Método a implementar en el futuro
              },
            ),

            _AnimatedSettingsButton(
              onTap: () => vm.abrirAjustes(),
            ),
          ],
        ),
      ),
    );
  }
}

// (Los widgets _AnimatedSettingsButton y _AnimatedPauseButton se mantienen exactamente iguales)

class _AnimatedSettingsButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedSettingsButton({required this.onTap});

  @override
  State<_AnimatedSettingsButton> createState() => _AnimatedSettingsButtonState();
}

class _AnimatedSettingsButtonState extends State<_AnimatedSettingsButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const neonCyan = Color(0xFF00FFFF);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.2 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isPressed ? neonCyan.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: _isPressed
                ? [BoxShadow(
                color: neonCyan.withOpacity(0.7),
                blurRadius: 15,
                spreadRadius: 2
            )]
                : [],
          ),
          child: const Icon(
              Icons.menu,
              color: neonCyan,
              size: 36
          ),
        ),
      ),
    );
  }
}

class _AnimatedPauseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedPauseButton({required this.onTap});

  @override
  State<_AnimatedPauseButton> createState() => _AnimatedPauseButtonState();
}

class _AnimatedPauseButtonState extends State<_AnimatedPauseButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const errorRed = Color(0xFFD65B5B);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.08 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: errorRed,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isPressed
                ? [BoxShadow(
                color: errorRed.withOpacity(0.7),
                blurRadius: 15,
                spreadRadius: 4
            )]
                : [const BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pause, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                  "PAUSAR (1/4)",
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)
              ),
            ],
          ),
        ),
      ),
    );
  }
}