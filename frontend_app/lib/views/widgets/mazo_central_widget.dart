import 'package:flutter/material.dart';
import '../../models/carta_model.dart';
import 'carta_widget.dart';

class MazoCentralWidget extends StatelessWidget {
  final Carta? cartaEnMesa;
  final VoidCallback onRobar;

  const MazoCentralWidget({super.key, this.cartaEnMesa, required this.onRobar});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mazo de robo (Boca abajo)
        GestureDetector(
          onTap: onRobar,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.only(left: 7, top: 7),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withOpacity(0.45),
                  blurRadius: 18,
                  offset: const Offset(6, 6),
                ),
              ],
            ),
            child: const CartaReversoWidget(
              width: 66,
              estilo: EstiloCarta.retro,
            ),
          ),
        ),
        const SizedBox(width: 36),
        // Carta en mesa (Boca arriba)
        if (cartaEnMesa != null)
          Transform.rotate(
            angle: 0.15, // Efecto orgánico
            child: CartaWidget(carta: cartaEnMesa!, width: 76),
          )
        else
          // Espacio vacío si no hay carta todavía
          Container(
            width: 60,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white10,
                style: BorderStyle.none,
              ),
            ),
          ),
      ],
    );
  }
}
