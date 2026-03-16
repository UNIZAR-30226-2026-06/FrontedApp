import 'package:flutter/material.dart';
import '../viewmodels/seleccionar_roles_viewmodel.dart';
import 'config_roles_vs_ia_view.dart';
import 'multijugador_menu_view.dart';

class SeleccionRolesView extends StatefulWidget {
  final String modoTitulo; // ej: "Modo con roles"
  final String modoSubtitulo; // ej: "Partida Privada"

  const SeleccionRolesView({
    super.key,
    required this.modoTitulo,
    required this.modoSubtitulo,
  });

  @override
  State<SeleccionRolesView> createState() => _SeleccionModoViewState();
}

class _SeleccionModoViewState extends State<SeleccionRolesView> {
  late final SeleccionRolesViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = SeleccionRolesViewModel(
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
                // BOTÓN VOLVER ANIMADO (TOP RIGHT) - ESCALA SUAVIZADA
                Positioned(
                  top: 14,
                  right: 14,
                  child: _AnimatedBackPill(
                    onTap: () => Navigator.pop(context),
                  ),
                ),

                // Contenido central
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

                        const SizedBox(height: 6),

                        Text(
                          vm.modoSubtitulo,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          'Selecciona el modo de juego',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // BOTÓN JUGAR VS IA (ROJO CORAL NEÓN) - ESCALA SUAVIZADA
                        _AnimatedBigChoiceButton(
                          background: const Color(0xFFCF5C5C),
                          title: 'Jugar vs IA',
                          subtitle: 'Compite contra la IA en frenéticas partidas',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConfigRolesVsIaView(modoTitulo: widget.modoTitulo),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // BOTÓN MULTIJUGADOR (VERDE NEÓN) - ESCALA SUAVIZADA
                        _AnimatedBigChoiceButton(
                          background: const Color(0xFF53D86A),
                          title: 'Modo Multijugador',
                          subtitle: 'Desafía a otros rivales para demostrar quién es el mejor',
                          isTextDark: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MultijugadorMenuView(
                                  modoTitulo: widget.modoTitulo,
                                  modoSubtitulo1: 'Modo Multijugador',
                                  modoSubtitulo2: widget.modoSubtitulo,
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
// COMPONENTES ANIMADOS CON ESCALA REDUCIDA
// ---------------------------------------------------------

class _AnimatedBigChoiceButton extends StatefulWidget {
  final Color background;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isTextDark;

  const _AnimatedBigChoiceButton({
    required this.background,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isTextDark = false,
  });

  @override
  State<_AnimatedBigChoiceButton> createState() => _AnimatedBigChoiceButtonState();
}

class _AnimatedBigChoiceButtonState extends State<_AnimatedBigChoiceButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          // AJUSTADO: Escala 1.06 (crece la mitad que antes) para no saturar la pantalla
          scale: _isHovered ? 1.06 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: _isHovered ? widget.background.withOpacity(0.95) : widget.background,
              borderRadius: BorderRadius.circular(18),
              boxShadow: _isHovered
                  ? [BoxShadow(
                  color: widget.background.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 3,
                  offset: const Offset(0, 4)
              )]
                  : [const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.isTextDark ? Colors.black : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.isTextDark ? Colors.black87 : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
          // AJUSTADO: Escala 1.05 para el botón de volver
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