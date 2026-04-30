import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/config_roles_vs_ia_viewmodel.dart';
import '../viewmodels/partida_actual_viewmodel.dart';

class ConfigRolesVsIaView extends StatefulWidget {
  final String modoTitulo;

  const ConfigRolesVsIaView({
    super.key,
    required this.modoTitulo,
  });

  @override
  State<ConfigRolesVsIaView> createState() => _ConfigRolesVsIaViewState();
}

class _ConfigRolesVsIaViewState extends State<ConfigRolesVsIaView> {
  late final ConfigRolesVsIaViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = ConfigRolesVsIaViewModel(modoTitulo: widget.modoTitulo);
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF2D3473);
    const panel = Color(0xFF3A4288);
    const inner = Color(0xFF2A316B);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Container(
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: ListenableBuilder(
                          listenable: vm,
                          builder: (context, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('🎭', style: TextStyle(fontSize: 22)),
                                    const SizedBox(width: 10),
                                    Text(
                                      vm.modoTitulo,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  vm.subtitulo,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  decoration: BoxDecoration(
                                    color: inner,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Número de jugadores',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _AnimatedSquareBtn(label: '–', onTap: vm.dec),
                                          Text(
                                            vm.jugadores.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          _AnimatedSquareBtn(label: '+', onTap: vm.inc),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        vm.detalleJugadores,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Mínimo 2, máximo 4 jugadores',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                _AnimatedGreenButton(
                                  label: 'Comenzar partida',
                                  onTap: () async {
                                    final partidaVm = context.read<PartidaActualViewModel>();
                                    await vm.comenzarPartida(context, partidaVm);
                                  },
                                ),

                                const SizedBox(height: 16),

                                _RulesSection(open: vm.reglasAbiertas, onToggle: vm.toggleReglas),

                                const SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                Positioned(
                  top: 14,
                  right: 14,
                  child: _AnimatedBackPill(
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _AnimatedSquareBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _AnimatedSquareBtn({required this.label, required this.onTap});

  @override
  State<_AnimatedSquareBtn> createState() => _AnimatedSquareBtnState();
}

class _AnimatedSquareBtnState extends State<_AnimatedSquareBtn> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF3A6BFF);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.1 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _isPressed ? activeBlue : const Color(0xFF263064),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isPressed
                ? [BoxShadow(color: activeBlue.withOpacity(0.7), blurRadius: 15, spreadRadius: 3)]
                : [],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedGreenButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _AnimatedGreenButton({required this.label, required this.onTap});

  @override
  State<_AnimatedGreenButton> createState() => _AnimatedGreenButtonState();
}

class _AnimatedGreenButtonState extends State<_AnimatedGreenButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const greenBase = Color(0xFF53D86A);
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
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: greenBase,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isPressed
                ? [BoxShadow(color: greenBase.withOpacity(0.7), blurRadius: 15, spreadRadius: 4)]
                : [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBackPill extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedBackPill({required this.onTap});

  @override
  State<_AnimatedBackPill> createState() => _AnimatedBackPillState();
}

class _AnimatedBackPillState extends State<_AnimatedBackPill> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF3A6BFF);
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _isPressed ? activeBlue : const Color(0xFF2A316B),
            borderRadius: BorderRadius.circular(15),
            boxShadow: _isPressed
                ? [BoxShadow(
              color: activeBlue.withOpacity(0.7),
              blurRadius: 15,
              spreadRadius: 4,
            )]
                : [],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Volver',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}


class _RulesSection extends StatelessWidget {
  final bool open;
  final VoidCallback onToggle;

  const _RulesSection({required this.open, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(open ? Icons.keyboard_arrow_down : Icons.chevron_right,
                    color: Colors.white70, size: 20),
                const SizedBox(width: 6),
                const Text('Reglas del UNO',
                    style: TextStyle(color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: open ? CrossFadeState.showFirst : CrossFadeState
              .showSecond,
          firstChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A316B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '• Juega una carta que coincida en color o número con la carta superior\n'
                  '• Salto: El siguiente jugador pierde su turno\n'
                  '• Reversa: Cambia la dirección del juego\n'
                  '• +2: El siguiente jugador roba 2 cartas\n'
                  '• +4 / Cambio color: Elige el color y el siguiente jugador roba 4 cartas',
              style: TextStyle(color: Colors.white70,
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w600),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}