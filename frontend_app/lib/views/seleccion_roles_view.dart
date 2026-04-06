import 'package:flutter/material.dart';
import '../viewmodels/seleccionar_roles_viewmodel.dart';
import 'config_roles_vs_ia_view.dart';
import 'multijugador_menu_view.dart';

class SeleccionRolesView extends StatefulWidget {
  final String modoTitulo;
  final String modoSubtitulo;

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
                // 1. EL CONTENIDO VA PRIMERO (capa inferior)
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
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),

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

                        Text(
                          vm.modoSubtitulo,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // BOTONES DE ELECCIÓN INSTANTÁNEOS
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

                        _AnimatedBigChoiceButton(
                          background: const Color(0xFF53D86A),
                          title: 'Modo Multijugador',
                          subtitle: 'Desafía a otros rivales de la Arena',
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

                // 2. EL BOTÓN VOLVER AL FINAL (capa superior para que funcione el click)
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
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
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
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: BorderRadius.circular(18),
            boxShadow: _isPressed
                ? [BoxShadow(
              color: widget.background.withOpacity(0.7),
              blurRadius: 20,
              spreadRadius: 6,
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