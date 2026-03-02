import 'package:flutter/material.dart';
import '../viewmodels/multijugador_menu_cartas_viewmodel.dart';
import 'config_cartas_multijugador_view.dart';
import 'unirse_partida_view.dart';

class MultijugadorMenuCartasView extends StatefulWidget {
  final String modoTitulo;       // "Modo cartas"
  final String modoSubtitulo1;   // "Modo Multijugador"
  final String modoSubtitulo2;   // "Partida Privada"

  const MultijugadorMenuCartasView({
    super.key,
    required this.modoTitulo,
    required this.modoSubtitulo1,
    required this.modoSubtitulo2,
  });

  @override
  State<MultijugadorMenuCartasView> createState() => _MultijugadorMenuCartasViewState();
}

class _MultijugadorMenuCartasViewState extends State<MultijugadorMenuCartasView> {
  late final MultijugadorMenuCartasViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = MultijugadorMenuCartasViewModel(
      modoTitulo: widget.modoTitulo,
      modoSubtitulo1: widget.modoSubtitulo1,
      modoSubtitulo2: widget.modoSubtitulo2,
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
                            Text(vm.modoSubtitulo2,
                                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),

                            const SizedBox(height: 22),

                            _GreenButton(
                              label: 'Crear partida',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ConfigCartasMultijugadorView(
                                      modoTitulo: widget.modoTitulo,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _GreenButton(
                              label: 'Unirse partida',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const UnirsePartidaView(
                                      modoTitulo: 'Modo cartas',
                                      modoSubtitulo: 'Partida Privada',
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
        width: 190,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF53D86A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}