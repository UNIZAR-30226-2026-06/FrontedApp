enum CartaColor { rojo, azul, verde, amarillo, especial }
enum CartaValor { cero, uno, dos, tres, cuatro, cinco, seis, siete, ocho, nueve, saltar, reversa, masDos, cambiaColor, masCuatro }

class Carta {
  final CartaColor color;
  final CartaValor valor;
  final String id;

  Carta({required this.color, required this.valor, required this.id});

  bool get esEspecial => color == CartaColor.especial || valor.index > 9;

  // --- TRADUCTOR DE JSON DEL SERVIDOR A ENUMS LOCALES ---
  factory Carta.fromJson(Map<String, dynamic> json) {
    return Carta(
      id: json['id']?.toString() ?? 'carta_desconocida',
      color: _parseColor(json['color']),
      valor: _parseValor(json['valor'] ?? json['value']),
    );
  }

  static CartaColor _parseColor(dynamic colorData) {
    if (colorData == null) return CartaColor.especial;
    final str = colorData.toString().toLowerCase();

    if (str.contains('roj') || str.contains('red')) return CartaColor.rojo;
    if (str.contains('azul') || str.contains('blue')) return CartaColor.azul;
    if (str.contains('verd') || str.contains('green')) return CartaColor.verde;
    if (str.contains('amarill') || str.contains('yellow')) return CartaColor.amarillo;

    return CartaColor.especial;
  }

  static CartaValor _parseValor(dynamic valorData) {
    if (valorData == null) return CartaValor.cero;
    final str = valorData.toString().toLowerCase().trim();

    switch (str) {
      case '0': case 'cero': return CartaValor.cero;
      case '1': case 'uno': return CartaValor.uno;
      case '2': case 'dos': return CartaValor.dos;
      case '3': case 'tres': return CartaValor.tres;
      case '4': case 'cuatro': return CartaValor.cuatro;
      case '5': case 'cinco': return CartaValor.cinco;
      case '6': case 'seis': return CartaValor.seis;
      case '7': case 'siete': return CartaValor.siete;
      case '8': case 'ocho': return CartaValor.ocho;
      case '9': case 'nueve': return CartaValor.nueve;
      case 'saltar': case 'skip': case 'bloqueo': return CartaValor.saltar;
      case 'reversa': case 'reverse': case 'cambio_sentido': return CartaValor.reversa;
      case '+2': case 'masdos': case 'draw2': return CartaValor.masDos;
      case '+4': case 'mascuatro': case 'draw4': return CartaValor.masCuatro;
      case 'cambiacolor': case 'color': case 'wild': return CartaValor.cambiaColor;
      default: return CartaValor.cero; // Fallback seguro
    }
  }
}