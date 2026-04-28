import 'package:flutter/material.dart';
import '../viewmodels/tablero_viewmodel.dart';
import '../models/jugador_model.dart';
import 'package:frontend_app/views/ajustes_overlay.dart';
import 'package:frontend_app/views/widgets/avatar_jugador_widget.dart';
import 'package:frontend_app/views/widgets/carta_widget.dart';
import 'package:frontend_app/views/widgets/mazo_central_widget.dart';

class TableroView extends StatefulWidget {
  final Jugador miPerfil;
  const TableroView({super.key, required this.miPerfil});

  @override
  State<TableroView> createState() => _TableroViewState();
}

class _TableroViewState extends State<TableroView> {
  late final TableroViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = TableroViewModel();
    vm.prepararPartida(widget.miPerfil);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          return Stack(
            children: [
              _buildFondo(),

              if (vm.bots.length >= 3) ...[
                Positioned(
                  top: 150, left: 40,
                  child: AvatarJugadorWidget(participante: vm.bots[0]),
                ),
                Positioned(
                  top: 80, left: 0, right: 0,
                  child: Center(child: AvatarJugadorWidget(participante: vm.bots[1])),
                ),
                Positioned(
                  top: 150, right: 40,
                  child: AvatarJugadorWidget(participante: vm.bots[2]),
                ),
              ],

              Center(
                child: MazoCentralWidget(
                  cartaEnMesa: vm.cartaActual,
                  onRobar: () => vm.robarCarta(),
                ),
              ),

              _buildTopBar(),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: vm.jugadorHumano?.mano.map((carta) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: CartaWidget(
                            carta: carta,
                            onTap: () => vm.intentarTirarCarta(carta),
                          ),
                        );
                      }).toList() ?? [],
                    ),
                  ),
                ),
              ),

              if (vm.mostrandoAjustes)
                Positioned.fill(
                  child: AjustesOverlay(
                    onClose: () => vm.cerrarAjustes(),
                  ),
                ),
            ],
          );
        },
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

  Widget _buildTopBar() {
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
                // Lógica de pausa aquí
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
        scale: _isPressed ? 1.2 : 1.0, // Un poco más de escala por ser un icono pequeño
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isPressed ? neonCyan.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
            boxShadow: _isPressed
                ? [BoxShadow(
                color: neonCyan.withOpacity(0.7), // Brillo estándar 0.7
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