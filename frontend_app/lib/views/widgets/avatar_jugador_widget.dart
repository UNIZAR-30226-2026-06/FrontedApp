// lib/views/widgets/avatar_jugador_widget.dart
import 'package:flutter/material.dart';
import '../../models/participante_model.dart';

class AvatarJugadorWidget extends StatelessWidget {
  final Participante participante;

  const AvatarJugadorWidget({super.key, required this.participante});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Efecto de resplandor (glow) alrededor del avatar
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF1E244D),
            // Aquí cargamos la imagen del bot. Si no existe, ponemos un icono por defecto.
            backgroundImage: AssetImage('assets/images/avatares/${participante.perfil.avatarId}.png'),
            // Si la imagen falla, mostramos un fallback
            onBackgroundImageError: (_, __) => const Icon(Icons.smart_toy, color: Colors.cyanAccent),
          ),
        ),
        const SizedBox(height: 6),
        // Nombre del Bot con estilo futurista
        Text(
          participante.perfil.nombre,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        // Indicador de cartas restantes
        _buildCardsIndicator(participante.mano.length),
      ],
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