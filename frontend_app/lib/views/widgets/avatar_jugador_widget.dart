import 'package:flutter/material.dart';
import '../../models/jugador_partida_model.dart';
import 'carta_widget.dart';

class AvatarJugadorWidget extends StatefulWidget {
  final JugadorPartidaModel participante;
  final bool esSuTurno;
  final EstiloCarta estilo;

  const AvatarJugadorWidget({
    super.key,
    required this.participante,
    this.esSuTurno = false,
    this.estilo = EstiloCarta.basic,
  });

  @override
  State<AvatarJugadorWidget> createState() => _AvatarJugadorWidgetState();
}

class _AvatarJugadorWidgetState extends State<AvatarJugadorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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
              child: widget.participante.isBot
                  ? const Icon(Icons.smart_toy, color: Colors.cyanAccent)
                  : const Icon(Icons.person, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.participante.id, // <-- Usamos el ID como nombre de momento
            style: TextStyle(
              color: widget.esSuTurno ? Colors.yellowAccent : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              shadows: widget.esSuTurno
                  ? [
                      const Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 8),
          _buildCardsFan(widget.participante.hand.length),
        ],
      ),
    );
  }

  Widget _buildCardsFan(int count) {
    final visible = count.clamp(0, 6);
    return SizedBox(
      width: 95,
      height: 55,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          for (int i = 0; i < visible; i++)
            Transform.translate(
              offset: Offset((i - (visible - 1) / 2) * 11, 0),
              child: Transform.rotate(
                angle: (i - (visible - 1) / 2) * 0.16,
                alignment: Alignment.bottomCenter,
                child: CartaReversoWidget(width: 34, estilo: widget.estilo),
              ),
            ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00E5FF), width: 1),
              ),
              child: Text(
                "$count",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
