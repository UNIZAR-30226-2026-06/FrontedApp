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
                // 1. CONTENIDO PRINCIPAL (Capa inferior)
                Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
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

                // 2. BOTÓN VOLVER (Capa superior - Ahora al final para que funcione el click)
                Positioned(
                  top: 14,
                  right: 14,
                  child: _AnimatedBackPill(
                    onTap: () => Navigator.pop(context),
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
// COMPONENTES CON RESPUESTA 0ms Y BRILLO 0.7
// ---------------------------------------------------------

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
          width: 200,
          height: 42,
          decoration: BoxDecoration(
            color: greenBase,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isPressed
                ? [BoxShadow(
              color: greenBase.withOpacity(0.7), // Brillo al 0.7
              blurRadius: 15,
              spreadRadius: 4,
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
              color: activeBlue.withOpacity(0.7), // Brillo al 0.7
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
              Text(
                'Volver',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}