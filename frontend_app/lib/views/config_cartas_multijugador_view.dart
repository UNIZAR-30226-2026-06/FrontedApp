import 'package:flutter/material.dart';
import '../viewmodels/config_cartas_multijugador_viewmodel.dart';

class ConfigCartasMultijugadorView extends StatefulWidget {
  final String modoTitulo; // "Modo cartas"

  const ConfigCartasMultijugadorView({
    super.key,
    required this.modoTitulo,
  });

  @override
  State<ConfigCartasMultijugadorView> createState() => _ConfigCartasMultijugadorViewState();
}

class _ConfigCartasMultijugadorViewState extends State<ConfigCartasMultijugadorView> {
  late final ConfigCartasMultijugadorViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = ConfigCartasMultijugadorViewModel(modoTitulo: widget.modoTitulo);
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
                                    const Text('⚡', style: TextStyle(fontSize: 22)),
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

                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        vm.subtitulo,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Código de la partida: ${vm.codigoPartida}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
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
                                          _SquareBtn(label: '–', onTap: vm.dec),
                                          Text(
                                            vm.jugadores.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          _SquareBtn(label: '+', onTap: vm.inc),
                                        ],
                                      ),

                                      const SizedBox(height: 8),
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

                                const SizedBox(height: 14),

                                _GreenWideButton(
                                  label: 'Comenzar partida',
                                  onTap: () => vm.comenzarPartida(context),
                                ),

                                const SizedBox(height: 12),

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

                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14, right: 14),
                    child: _BackPill(
                      onTap: () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                    ),
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

// Widgets comunes (idénticos a los otros)
class _BackPill extends StatelessWidget {
  final VoidCallback onTap;
  const _BackPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A316B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Volver',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _SquareBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SquareBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF263064),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

class _GreenWideButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GreenWideButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF53D86A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
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
          child: Row(
            children: [
              Icon(open ? Icons.keyboard_arrow_down : Icons.chevron_right,
                  color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              const Text('Reglas del UNO',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A316B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '• Juega una carta que coincida en color o número con la carta superior\n'
                  '• Salto: El siguiente jugador pierde su turno\n'
                  '• Reversa: Cambia la dirección del juego\n'
                  '• +2: El siguiente jugador roba 2 cartas\n'
                  '• +4 / Cambio color: Elige el color y el siguiente jugador roba 4 cartas',
              style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.35, fontWeight: FontWeight.w600),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }
}