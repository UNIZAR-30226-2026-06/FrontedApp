/// Mensaje del chat de partida. NO persiste en BD: solo viaja por sockets
/// (`mensajeMostrar` al remitente, `nuevoMensajeChat` al resto de la sala).
///
/// Payload típico desde el backend:
/// `{ remitente: 'santiago', texto: 'hola', hora: '2026-05-13T05:33:21.123Z', partidaId: 'abc' }`
class ChatMessage {
  final String remitente;
  final String texto;
  final DateTime hora;
  final String? partidaId;

  ChatMessage({
    required this.remitente,
    required this.texto,
    required this.hora,
    this.partidaId,
  });

  /// Parsea un mensaje que viene por socket. Tolera:
  ///  - `hora` ausente, null, o malformada → usa `DateTime.now()`.
  ///  - `partidaId` o `partidaID` (el backend usa la segunda variante).
  ///  - Campos faltantes → strings vacíos / defaults seguros.
  factory ChatMessage.fromSocket(Map data) {
    final rawHora = data['hora'];
    DateTime hora;
    if (rawHora is String && rawHora.isNotEmpty) {
      hora = DateTime.tryParse(rawHora)?.toLocal() ?? DateTime.now();
    } else {
      hora = DateTime.now();
    }
    return ChatMessage(
      remitente: data['remitente']?.toString() ?? 'Jugador',
      texto: data['texto']?.toString() ?? '',
      hora: hora,
      partidaId: (data['partidaId'] ?? data['partidaID'])?.toString(),
    );
  }

  /// Hora en formato `HH:mm` (24 h) para mostrar bajo el mensaje.
  String get horaCorta {
    final h = hora.hour.toString().padLeft(2, '0');
    final m = hora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
