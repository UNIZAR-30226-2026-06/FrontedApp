import 'package:flutter/material.dart';
import '../viewmodels/seleccionar_cartas_viewmodel.dart';
import 'config_cartas_vs_ia_view.dart';
import 'multijugador_menu_cartas_view.dart';

class SeleccionCartasView extends StatefulWidget {
  final String modoTitulo;     // "Modo cartas"
  final String modoSubtitulo;  // "Partida Privada"

  const SeleccionCartasView({
    super.key,
    required this.modoTitulo,
    required this.modoSubtitulo,
  });

  @override
  State<SeleccionCartasView> createState() => _SeleccionCartasViewState();
}

class _SeleccionCartasViewState extends State<SeleccionCartasView> {
  late final SeleccionarCartasViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = SeleccionarCartasViewModel(
      modoTitulo: widget.modoTitulo,
      modoSubtitulo: widget.modoSubtitulo,
    );
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
                // ✅ contenido con scroll (por si crece)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            const Text(
                              'UNO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 14),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('⚡', style: TextStyle(fontSize: 22)),
                                const SizedBox(width: 10),
                                Text(
                                  vm.modoTitulo,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Text(
                              vm.modoSubtitulo,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 22),

                            const Text(
                              'Selecciona el modo de juego',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _BigChoiceButton(
                              background: const Color(0xFFCF5C5C),
                              title: 'Jugar vs IA',
                              subtitle: 'Compite contra la IA en frenéticas partidas',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ConfigCartasVsIaView(
                                      modoTitulo: widget.modoTitulo,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            _BigChoiceButton(
                              background: const Color(0xFF53D86A),
                              title: 'Modo Multijugador',
                              subtitle: 'Desafía a otros rivales para demostrar quién es el mejor',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MultijugadorMenuCartasView(
                                      modoTitulo: widget.modoTitulo,
                                      modoSubtitulo1: 'Modo Multijugador',
                                      modoSubtitulo2: widget.modoSubtitulo,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // ✅ Volver encima y clicable
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigChoiceButton extends StatelessWidget {
  final Color background;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BigChoiceButton({
    required this.background,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}