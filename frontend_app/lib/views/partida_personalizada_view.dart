import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/partida_personalizada_viewmodel.dart';
import '../viewmodels/partida_actual_viewmodel.dart';
import 'tablero_view.dart';

class PartidaPersonalizadaView extends StatefulWidget {
  const PartidaPersonalizadaView({super.key});

  @override
  State<PartidaPersonalizadaView> createState() => _PartidaPersonalizadaViewState();
}

class _PartidaPersonalizadaViewState extends State<PartidaPersonalizadaView> {
  late final PartidaPersonalizadaViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = PartidaPersonalizadaViewModel();
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
    const cardBg = Color(0xFF3F578C);

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
                // 1. CONTENIDO (Capa inferior)
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
                              children: [
                                const SizedBox(height: 6),
                                const Text(
                                  'UNO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🛠️', style: TextStyle(fontSize: 18)),
                                    SizedBox(width: 10),
                                    Text(
                                      'Partida personalizada',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Partida Privada',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // PANEL CREAR SALA
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'CREAR SALA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // IZQUIERDA: REGLAS + NUM CARTAS
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Reglas de juego',
                                                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                                                ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    _AnimatedRuleTile(
                                                      selected: vm.regla == ReglaPersonalizada.normal,
                                                      emoji: '🟥',
                                                      label: 'Normal',
                                                      onTap: () => vm.setRegla(ReglaPersonalizada.normal),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _AnimatedRuleTile(
                                                      selected: vm.regla == ReglaPersonalizada.roles,
                                                      emoji: '🎭',
                                                      label: 'Roles',
                                                      onTap: () => vm.setRegla(ReglaPersonalizada.roles),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _AnimatedRuleTile(
                                                      selected: vm.regla == ReglaPersonalizada.cartasEspeciales,
                                                      emoji: '⚡',
                                                      label: 'Esp.',
                                                      onTap: () => vm.setRegla(ReglaPersonalizada.cartasEspeciales),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 16),

                                                // CONTROL NUM CARTAS
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: inner,
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      _AnimatedSquareBtn(label: '–', onTap: vm.decCartas),
                                                      Column(
                                                        children: [
                                                          const Text('CARTAS', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900)),
                                                          Text(vm.numCartas.toString(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                                                        ],
                                                      ),
                                                      _AnimatedSquareBtn(label: '+', onTap: vm.incCartas),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 16),

                                          // DERECHA: TOGGLES
                                          SizedBox(
                                            width: 130,
                                            child: Column(
                                              children: [
                                                _AnimatedToggleRow(label: 'MÚSICA', value: vm.musica, onChanged: vm.toggleMusica),
                                                const SizedBox(height: 8),
                                                _AnimatedToggleRow(label: 'SONIDO', value: vm.sonido, onChanged: vm.toggleSonido),
                                                const SizedBox(height: 8),
                                                _AnimatedToggleRow(label: 'VIBRAR', value: vm.vibracion, onChanged: vm.toggleVibracion),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 24),

                                      _AnimatedGreenButton(
                                        label: 'CREAR PARTIDA',
                                        onTap: () {
                                          // INYECTAMOS EL VIEWMODEL GLOBAL AQUÍ
                                          final partidaVm = context.read<PartidaActualViewModel>();
                                          vm.crearPartida(context, partidaVm);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
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

// ---------------------------------------------------------
// COMPONENTES REFACTORIZADOS (0ms / Brillo 0.7)
// ---------------------------------------------------------

class _AnimatedRuleTile extends StatefulWidget {
  final bool selected;
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _AnimatedRuleTile({required this.selected, required this.emoji, required this.label, required this.onTap});

  @override
  State<_AnimatedRuleTile> createState() => _AnimatedRuleTileState();
}

class _AnimatedRuleTileState extends State<_AnimatedRuleTile> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF4C542);
    const idleBg = Color(0xFF3E6FB1);

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          duration: Duration.zero,
          scale: _isPressed ? 1.08 : 1.0,
          child: AnimatedContainer(
            duration: Duration.zero,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: widget.selected ? const Color(0xFF5A86C9) : idleBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: widget.selected ? gold : Colors.transparent, width: 2),
              boxShadow: (widget.selected || _isPressed)
                  ? [BoxShadow(color: (widget.selected ? gold : Colors.white).withOpacity(0.7), blurRadius: 12, spreadRadius: 2)]
                  : [],
            ),
            child: Column(
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text(widget.label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
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
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.15 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _isPressed ? activeBlue : const Color(0xFF263064),
            borderRadius: BorderRadius.circular(10),
            boxShadow: _isPressed ? [BoxShadow(color: activeBlue.withOpacity(0.7), blurRadius: 15, spreadRadius: 3)] : [],
          ),
          child: Center(
            child: Text(widget.label, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    );
  }
}

class _AnimatedToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _AnimatedToggleRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900))),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: const Color(0xFF53D86A),
              inactiveTrackColor: const Color(0xFFD65B5B),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
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
    const green = Color(0xFF53D86A);
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
          width: 220,
          height: 44,
          decoration: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isPressed
                ? [BoxShadow(color: green.withOpacity(0.7), blurRadius: 20, spreadRadius: 4)]
                : [const BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))],
          ),
          child: Center(
            child: Text(
                widget.label,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)
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
      onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        duration: Duration.zero,
        scale: _isPressed ? 1.08 : 1.0,
        child: AnimatedContainer(
          duration: Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _isPressed ? activeBlue : const Color(0xFF263064),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isPressed ? [BoxShadow(color: activeBlue.withOpacity(0.7), blurRadius: 15, spreadRadius: 4)] : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.arrow_back, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Volver', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}