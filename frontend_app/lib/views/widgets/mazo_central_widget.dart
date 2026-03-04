import 'package:flutter/material.dart';
import '../../models/carta_model.dart';
import 'carta_widget.dart';

class MazoCentralWidget extends StatelessWidget {
  final Carta? cartaEnMesa;
  final VoidCallback onRobar;

  const MazoCentralWidget({
    super.key,
    this.cartaEnMesa,
    required this.onRobar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mazo de robo (Boca abajo)
        GestureDetector(
          onTap: onRobar,
          child: Container(
            width: 60,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade800,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white30),
            ),
            child: const Center(
              child: Icon(Icons.layers, color: Colors.white, size: 30),
            ),
          ),
        ),
        const SizedBox(width: 30),
        // Carta en mesa (Boca arriba)
        if (cartaEnMesa != null)
          Transform.rotate(
            angle: 0.15, // Efecto orgánico
            child: CartaWidget(carta: cartaEnMesa!),
          )
        else
        // Espacio vacío si no hay carta todavía
          Container(
            width: 60, height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10, style: BorderStyle.none),
            ),
          ),
      ],
    );
  }
}