import 'package:flutter/material.dart';
import '../../models/carta_model.dart';

class CartaWidget extends StatelessWidget {
  final Carta carta;
  final VoidCallback? onTap;

  const CartaWidget({super.key, required this.carta, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.8, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 90,
          decoration: BoxDecoration(
            color: _getColor(carta.color),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(2, 2),
              )
            ],
          ),
          child: Center(
            child: Text(
              _getValor(carta.valor),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getColor(CartaColor c) {
    switch (c) {
      case CartaColor.rojo: return Colors.red.shade700;
      case CartaColor.azul: return Colors.blue.shade800;
      case CartaColor.verde: return Colors.green.shade700;
      case CartaColor.amarillo: return Colors.amber.shade700;
      default: return Colors.black;
    }
  }

  String _getValor(CartaValor v) {
    String nombre = v.name;
    if (nombre.contains('mas')) return nombre.replaceAll('mas', '+');
    if (nombre == 'reversa') return '🔄';
    if (nombre == 'saltar') return '🚫';

    Map<CartaValor, String> numeros = {
      CartaValor.cero: '0', CartaValor.uno: '1', CartaValor.dos: '2',
      CartaValor.tres: '3', CartaValor.cuatro: '4', CartaValor.cinco: '5',
      CartaValor.seis: '6', CartaValor.siete: '7', CartaValor.ocho: '8', CartaValor.nueve: '9',
    };
    return numeros[v] ?? '?';
  }
}