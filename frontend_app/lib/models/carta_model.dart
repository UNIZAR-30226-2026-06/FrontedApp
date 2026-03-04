enum CartaColor { rojo, azul, verde, amarillo, especial }
enum CartaValor { cero, uno, dos, tres, cuatro, cinco, seis, siete, ocho, nueve, saltar, reversa, masDos, cambiaColor, masCuatro }

class Carta {
  final CartaColor color;
  final CartaValor valor;
  final String id;

  Carta({required this.color, required this.valor, required this.id});

  bool get esEspecial => color == CartaColor.especial || valor.index > 9;
}