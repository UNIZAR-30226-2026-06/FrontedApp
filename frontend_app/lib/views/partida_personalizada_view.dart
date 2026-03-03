import 'package:flutter/material.dart';
import '../viewmodels/partida_personalizada_viewmodel.dart';

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
    const card = Color(0xFF3F578C);

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
                // ✅ contenido scrolleable
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
                              children: [
                                const SizedBox(height: 6),

                                const Text(
                                  'UNO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),

                                const SizedBox(height: 6),

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

                                const SizedBox(height: 12),

                                // Panel CREAR SALA
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  decoration: BoxDecoration(
                                    color: card,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        'CREAR SALA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          shadows: [
                                            Shadow(blurRadius: 2, offset: Offset(0, 1)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // IZQUIERDA: reglas + num cartas
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Reglas',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),

                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: _RuleTile(
                                                        selected: vm.regla == ReglaPersonalizada.normal,
                                                        emoji: '🟥',
                                                        label: 'Normal',
                                                        onTap: () => vm.setRegla(ReglaPersonalizada.normal),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: _RuleTile(
                                                        selected: vm.regla == ReglaPersonalizada.roles,
                                                        emoji: '🎭',
                                                        label: 'Roles',
                                                        onTap: () => vm.setRegla(ReglaPersonalizada.roles),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: _RuleTile(
                                                        selected: vm.regla == ReglaPersonalizada.cartasEspeciales,
                                                        emoji: '⚡',
                                                        label: 'Cartas esp.',
                                                        onTap: () => vm.setRegla(ReglaPersonalizada.cartasEspeciales),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 12),

                                                // Num cartas
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                        decoration: BoxDecoration(
                                                          color: inner,
                                                          borderRadius: BorderRadius.circular(14),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            _MiniSquareBtn(label: '–', onTap: vm.decCartas),
                                                            Row(
                                                              children: [
                                                                const Text(
                                                                  'Num cartas',
                                                                  style: TextStyle(
                                                                    color: Colors.white70,
                                                                    fontSize: 11,
                                                                    fontWeight: FontWeight.w800,
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Text(
                                                                  vm.numCartas.toString(),
                                                                  style: const TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.w900,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            _MiniSquareBtn(label: '+', onTap: vm.incCartas),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 16),

                                          // DERECHA: toggles
                                          SizedBox(
                                            width: 140,
                                            child: Column(
                                              children: [
                                                _ToggleRow(
                                                  label: 'MÚSICA',
                                                  value: vm.musica,
                                                  onChanged: vm.toggleMusica,
                                                ),
                                                const SizedBox(height: 10),
                                                _ToggleRow(
                                                  label: 'SONIDO',
                                                  value: vm.sonido,
                                                  onChanged: vm.toggleSonido,
                                                ),
                                                const SizedBox(height: 10),
                                                _ToggleRow(
                                                  label: 'VIBRACIÓN',
                                                  value: vm.vibracion,
                                                  onChanged: vm.toggleVibracion,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 14),

                                      _GreenButton(
                                        label: 'Crear partida',
                                        onTap: () => vm.crearPartida(context),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 18),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                // ✅ Botón volver siempre encima y clicable
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

// ===== Widgets UI =====

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
            Text(
              'Volver',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final bool selected;
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _RuleTile({
    required this.selected,
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF5A86C9) : const Color(0xFF3E6FB1);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSquareBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MiniSquareBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF263064),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _GreenButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GreenButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 200,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF53D86A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ),
      ),
    );
  }
}