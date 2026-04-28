import 'package:flutter/material.dart';
import '../../models/participante_model.dart';

class AvatarJugadorWidget extends StatefulWidget {
  final Participante participante;
  final bool esSuTurno;

  const AvatarJugadorWidget({
    super.key,
    required this.participante,
    this.esSuTurno = false,
  });

  @override
  State<AvatarJugadorWidget> createState() => _AvatarJugadorWidgetState();
}

class _AvatarJugadorWidgetState extends State<AvatarJugadorWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.esSuTurno) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AvatarJugadorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.esSuTurno && !oldWidget.esSuTurno) {
      _controller.repeat(reverse: true);
    } else if (!widget.esSuTurno && oldWidget.esSuTurno) {
      _controller.stop();
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Efecto de resplandor (glow) alrededor del avatar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.esSuTurno 
                      ? Colors.yellowAccent.withOpacity(0.8) 
                      : Colors.cyanAccent.withOpacity(0.4),
                  blurRadius: widget.esSuTurno ? 20 : 10,
                  spreadRadius: widget.esSuTurno ? 4 : 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF1E244D),
              backgroundImage: AssetImage('assets/images/avatares/${widget.participante.perfil.avatarId}.png'),
              onBackgroundImageError: (_, __) => const Icon(Icons.smart_toy, color: Colors.cyanAccent),
            ),
          ),
          const SizedBox(height: 6),
          // Nombre del Bot con estilo futurista
          Text(
            widget.participante.perfil.nombre,
            style: TextStyle(
              color: widget.esSuTurno ? Colors.yellowAccent : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              shadows: widget.esSuTurno ? [
                const Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1))
              ] : [],
            ),
          ),
          // Indicador de cartas restantes
          _buildCardsIndicator(widget.participante.mano.length),
        ],
      ),
    );
  }

  Widget _buildCardsIndicator(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.style, color: Colors.yellow, size: 10),
          const SizedBox(width: 4),
          Text("$count", style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }
}