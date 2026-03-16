import 'package:flutter/material.dart';
import '../viewmodels/multijugador_menu_viewmodel.dart';
import 'config_roles_multijugador_view.dart';
import 'unirse_partida_view.dart';

class MultijugadorMenuView extends StatefulWidget {
  final String modoTitulo;       // "Modo con roles"
  final String modoSubtitulo1;   // "Modo Multijugador"
  final String modoSubtitulo2;   // "Partida Privada"

  const MultijugadorMenuView({
    super.key,
    required this.modoTitulo,
    required this.modoSubtitulo1,
    required this.modoSubtitulo2,
  });

  @override
  State<MultijugadorMenuView> createState() => _MultijugadorMenuViewState();
}

class _MultijugadorMenuViewState extends State<MultijugadorMenuView> {
  late final MultijugadorMenuViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = MultijugadorMenuViewModel(
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
                // BOTÓN VOLVER ANIMADO (TOP RIGHT)
                Positioned(
                  top: 14,
                  right: 14,
                  child: _AnimatedBackPill(onTap: () => Navigator.pop(context)),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'UNO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🎭', style: TextStyle(fontSize: 22)),
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

                        const SizedBox(height: 8),

                        Text(
                          vm.modoSubtitulo1,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vm.modoSubtitulo2,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // BOTONES DE ACCIÓN ANIMADOS (VERDE NEÓN)
                        _AnimatedGreenButton(
                          label: 'Crear partida',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConfigRolesMultijugadorView(modoTitulo: widget.modoTitulo),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        _AnimatedGreenButton(
                          label: 'Unirse partida',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UnirsePartidaView(
                                  modoTitulo: 'Modo con roles',
                                  modoSubtitulo: 'Partida Privada',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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

// ---------------------------------------------------------
// COMPONENTES ANIMADOS (ESTILO EXTREME GLOW)
// ---------------------------------------------------------

class _AnimatedGreenButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _AnimatedGreenButton({required this.label, required this.onTap});

  @override
  State<_AnimatedGreenButton> createState() => _AnimatedGreenButtonState();
}

class _AnimatedGreenButtonState extends State<_AnimatedGreenButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const greenBase = Color(0xFF53D86A);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          // ESCALA 1.12 para impacto visual equilibrado
          scale: _isHovered ? 1.12 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 200,
            height: 42,
            decoration: BoxDecoration(
              color: _isHovered ? greenBase.withOpacity(0.9) : greenBase,
              borderRadius: BorderRadius.circular(14),
              boxShadow: _isHovered
                  ? [BoxShadow(
                  color: greenBase.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 2)
              )]
                  : [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const activeBlue = Color(0xFF3A6BFF);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          // ESCALA 1.05 para el botón de volver
          scale: _isHovered ? 1.05 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _isHovered ? activeBlue : const Color(0xFF2A316B),
              borderRadius: BorderRadius.circular(14),
              boxShadow: _isHovered
                  ? [BoxShadow(color: activeBlue.withOpacity(0.4), blurRadius: 12)]
                  : [],
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
        ),
      ),
    );
  }
}