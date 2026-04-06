import 'package:flutter/material.dart';
import '../viewmodels/seleccionmodo_viewmodel.dart';

class SeleccionModoView extends StatefulWidget {
  const SeleccionModoView({super.key});

  @override
  State<SeleccionModoView> createState() => _SeleccionModoViewState();
}

class _SeleccionModoViewState extends State<SeleccionModoView> {
  late final SeleccionModoViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = SeleccionModoViewModel();
  }

  @override
  Widget build(BuildContext context) {
    const Color azulFondo = Color(0xFF2D3473);
    const Color azulPanel = Color(0xFF3A4288);

    return Scaffold(
      backgroundColor: azulFondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( // Añadido para seguridad en Landscape (Pixel horizontal)
            physics: const BouncingScrollPhysics(),
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: azulPanel,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Stack(
                children: [
                  // 1. CONTENIDO PRINCIPAL (Capa inferior)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "UNO",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Icono y Títulos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.theater_comedy, color: Colors.white, size: 36),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(vm.tituloModo,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900)),
                              Text(vm.subtituloPartida,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 35),
                      const Text(
                        "Selecciona el modo de juego",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 25),

                      // Botón Jugar vs IA (Rojo Neón 0.7)
                      _AnimatedModeButton(
                        titulo: "Jugar vs IA",
                        subtitulo: "Compite contra la IA en frenéticas partidas",
                        color: const Color(0xFFD65B5B),
                        onTap: () => vm.jugarVsIA(context),
                      ),

                      const SizedBox(height: 18),

                      // Botón Modo Multijugador (Verde Neón 0.7)
                      _AnimatedModeButton(
                        titulo: "Modo Multijugador",
                        subtitulo: "Desafía a otros rivales de la Arena",
                        color: const Color(0xFF53D86A),
                        onTap: () => vm.jugarVsJugador(context),
                        isTextDark: true,
                      ),
                    ],
                  ),

                  // 2. BOTÓN VOLVER (Capa superior para asegurar respuesta)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _AnimatedBackPill(
                      onTap: () => vm.volver(context),
                    ),
                  ),
                ],
              ),
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

class _AnimatedModeButton extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;
  final bool isTextDark;

  const _AnimatedModeButton({
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
    this.isTextDark = false,
  });

  @override
  State<_AnimatedModeButton> createState() => _AnimatedModeButtonState();
}

class _AnimatedModeButtonState extends State<_AnimatedModeButton> {
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
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(22),
            boxShadow: _isPressed
                ? [BoxShadow(
              color: widget.color.withOpacity(0.7), // Brillo estándar 0.7
              blurRadius: 20,
              spreadRadius: 6,
            )]
                : [const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Column(
            children: [
              Text(
                widget.titulo,
                style: TextStyle(
                    color: widget.isTextDark ? Colors.black : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: widget.isTextDark ? Colors.black87 : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600
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
              Text('Volver',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}