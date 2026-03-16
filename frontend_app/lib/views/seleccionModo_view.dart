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
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: BoxDecoration(
              color: azulPanel,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Stack(
              children: [
                // BOTÓN VOLVER (TOP RIGHT)
                Align(
                  alignment: Alignment.topRight,
                  child: _AnimatedBackPill(
                    onTap: () => vm.volver(context),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      "UNO",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Icono y Títulos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.theater_comedy, color: Colors.white, size: 40),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vm.tituloModo,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                            Text(vm.subtituloPartida,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),
                    const Text(
                      "Selecciona el modo de juego",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 30),

                    // Botón Jugar vs IA (Rojo Neón)
                    _AnimatedModeButton(
                      titulo: "Jugar vs IA",
                      subtitulo: "Compite contra la IA en frenéticas partidas",
                      color: const Color(0xFFD65B5B),
                      onTap: () => vm.jugarVsIA(context),
                    ),

                    const SizedBox(height: 20),

                    // Botón Modo Multijugador (Verde Neón)
                    _AnimatedModeButton(
                      titulo: "Modo Multijugador",
                      subtitulo: "Desafía a otros rivales para demostrar quién es el mejor",
                      color: const Color(0xFF53D86A),
                      onTap: () => vm.jugarVsJugador(context),
                      isTextDark: true,
                    ),
                  ],
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
          scale: _isHovered ? 1.12 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            decoration: BoxDecoration(
              color: _isHovered ? widget.color.withOpacity(0.9) : widget.color,
              borderRadius: BorderRadius.circular(25),
              boxShadow: _isHovered
                  ? [BoxShadow(
                  color: widget.color.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 3,
                  offset: const Offset(0, 4)
              )]
                  : [const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                Text(
                  widget.titulo,
                  style: TextStyle(
                      color: widget.isTextDark ? Colors.black : Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.subtitulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: widget.isTextDark ? Colors.black87 : Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600
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
          scale: _isHovered ? 1.1 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _isHovered ? activeBlue : const Color(0xFF2A316B),
              borderRadius: BorderRadius.circular(14),
              boxShadow: _isHovered ? [BoxShadow(color: activeBlue.withOpacity(0.4), blurRadius: 10)] : [],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.reply, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Volver',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}