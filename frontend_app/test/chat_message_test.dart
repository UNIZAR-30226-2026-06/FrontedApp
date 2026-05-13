import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_app/models/chat_message_model.dart';

void main() {
  group('ChatMessage.fromSocket', () {
    test('parsea un payload bien formado (remitente, texto, hora ISO)', () {
      final msg = ChatMessage.fromSocket({
        'remitente': 'santiago',
        'texto': 'hola UNO!',
        'hora': '2026-05-13T05:33:21.123Z',
        'partidaId': 'abc-123',
      });

      expect(msg.remitente, 'santiago');
      expect(msg.texto, 'hola UNO!');
      expect(msg.hora.isUtc, isFalse,
          reason: 'el constructor convierte a hora local');
      expect(msg.partidaId, 'abc-123');
    });

    test(
      'usa "partidaID" (mayúscula) si el backend lo envía con esa key '
      '(el chat handler usa la segunda variante)',
      () {
        final msg = ChatMessage.fromSocket({
          'remitente': 'a',
          'texto': 'b',
          'hora': '2026-05-13T05:33:21.000Z',
          'partidaID': 'XYZ',
        });
        expect(msg.partidaId, 'XYZ');
      },
    );

    test(
      'tolera hora ausente / null / malformada → cae a DateTime.now()',
      () {
        final antes = DateTime.now();
        final sinHora = ChatMessage.fromSocket({
          'remitente': 'x',
          'texto': 'hola',
        });
        final nullHora = ChatMessage.fromSocket({
          'remitente': 'x',
          'texto': 'hola',
          'hora': null,
        });
        final malformada = ChatMessage.fromSocket({
          'remitente': 'x',
          'texto': 'hola',
          'hora': 'no-es-una-fecha',
        });
        final despues = DateTime.now();

        for (final m in [sinHora, nullHora, malformada]) {
          expect(
            m.hora.isAfter(antes.subtract(const Duration(seconds: 1))) &&
                m.hora.isBefore(despues.add(const Duration(seconds: 1))),
            isTrue,
            reason: 'hora debe caer en el rango de "ahora" como fallback',
          );
        }
      },
    );

    test(
      'campos faltantes → valores por defecto seguros (no lanza)',
      () {
        final msg = ChatMessage.fromSocket({});
        expect(msg.remitente, 'Jugador');
        expect(msg.texto, '');
        expect(msg.partidaId, isNull);
        expect(msg.hora, isA<DateTime>());
      },
    );

    test('horaCorta formatea como HH:mm con padding 0', () {
      final msg = ChatMessage(
        remitente: 'x',
        texto: 'hola',
        hora: DateTime(2026, 5, 13, 7, 4),
      );
      expect(msg.horaCorta, '07:04');
    });

    test('horaCorta funciona con horas de dos dígitos', () {
      final msg = ChatMessage(
        remitente: 'x',
        texto: 'hola',
        hora: DateTime(2026, 5, 13, 23, 59),
      );
      expect(msg.horaCorta, '23:59');
    });
  });
}
