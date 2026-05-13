/// Resultado individual de un jugador al terminar una partida.
class ResultadoJugador {
  final String id;
  final bool isBot;
  final bool isWinner;
  final int monedasGanadas;
  final int? monedasTotales;
  final int? totalGanadas;
  final int? totalPartidas;

  const ResultadoJugador({
    required this.id,
    required this.isBot,
    required this.isWinner,
    required this.monedasGanadas,
    this.monedasTotales,
    this.totalGanadas,
    this.totalPartidas,
  });

  factory ResultadoJugador.fromJson(Map<String, dynamic> json) {
    return ResultadoJugador(
      id: json['id']?.toString() ?? '',
      isBot: json['isBot'] == true,
      isWinner: json['isWinner'] == true,
      monedasGanadas: (json['monedasGanadas'] as num?)?.toInt() ?? 0,
      monedasTotales: (json['monedasTotales'] as num?)?.toInt(),
      totalGanadas: (json['totalGanadas'] as num?)?.toInt(),
      totalPartidas: (json['totalPartidas'] as num?)?.toInt(),
    );
  }
}

/// Payload completo del evento `game_finished` que emite el backend cuando
/// se detecta un ganador.
class ResultadoPartida {
  final String winner;
  final bool winnerIsBot;
  final int recompensaGanador;
  final int recompensaPerdedor;
  final List<ResultadoJugador> jugadores;

  const ResultadoPartida({
    required this.winner,
    required this.winnerIsBot,
    required this.recompensaGanador,
    required this.recompensaPerdedor,
    required this.jugadores,
  });

  factory ResultadoPartida.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'];
    final List<ResultadoJugador> jugadores = rawPlayers is List
        ? rawPlayers
            .whereType<Map>()
            .map((e) => ResultadoJugador.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <ResultadoJugador>[];

    return ResultadoPartida(
      winner: json['winner']?.toString() ?? '',
      winnerIsBot: json['isBot'] == true,
      recompensaGanador: (json['recompensaGanador'] as num?)?.toInt() ??
          (json['recompensa'] as num?)?.toInt() ??
          50,
      recompensaPerdedor: (json['recompensaPerdedor'] as num?)?.toInt() ?? 10,
      jugadores: jugadores,
    );
  }

  /// Devuelve el resultado del jugador local si está presente, null si no.
  ResultadoJugador? resultadoDe(String? jugadorId) {
    if (jugadorId == null) return null;
    for (final r in jugadores) {
      if (r.id == jugadorId) return r;
    }
    return null;
  }
}
