import '../models/jugador_partida_model.dart';

class PartidaModel {
  final String gameId;
  final String? code;
  final bool isPrivate;
  final String? jugadorLocal;

  final String phase;
  final List<JugadorPartidaModel> jugadores;
  final int currentTurn;
  final int direction;
  final dynamic currentCard;
  final bool rolesMode;
  final bool specialCardsMode;
  final int maxJugadores;

  PartidaModel({
    required this.gameId,
    this.code,
    required this.isPrivate,
    this.jugadorLocal,
    this.phase = 'waiting',
    this.jugadores = const [],
    this.currentTurn = 0,
    this.direction = 1,
    this.currentCard,
    this.rolesMode = false,
    this.specialCardsMode = false,
    this.maxJugadores = 4,
  });

  factory PartidaModel.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'] ?? json['jugadores'];
    final players =
        (rawPlayers as List?)
            ?.map(
              (p) => p is Map<String, dynamic>
                  ? JugadorPartidaModel.fromJson(p)
                  : JugadorPartidaModel(id: p.toString()),
            )
            .toList() ??
        [];

    final rawTurn = json['currentTurn'];
    int currentTurnIndex = 0;
    if (rawTurn is int) {
      currentTurnIndex = rawTurn;
    } else if (rawTurn != null) {
      final idx = players.indexWhere((p) => p.id == rawTurn.toString());
      currentTurnIndex = idx < 0 ? 0 : idx;
    }

    return PartidaModel(
      gameId: (json['id_partida'] ?? json['gameId'] ?? json['id'] ?? '')
          .toString(),
      code: (json['codigo'] ?? json['code'])?.toString(),

      isPrivate:
          json['partida_publica'] == false ||
          json['isPrivate'] == true ||
          json['private'] == true ||
          json['visibility'] == 'private',

      jugadorLocal: json['jugadorLocal']?.toString(),

      phase:
          json['phase']?.toString() ?? json['estado']?.toString() ?? 'waiting',

      jugadores: players,
      currentTurn: currentTurnIndex,
      direction: json['direction'] ?? 1,
      currentCard: json['currentCard'] ?? json['discardTop'],
      rolesMode: json['modo_roles'] ?? json['rolesMode'] ?? false,
      specialCardsMode:
          json['modo_cartas_especiales'] ?? json['specialCardsMode'] ?? false,
      maxJugadores:
          (json['maxJugadores'] ?? json['max_jugadores'] ?? 4) as int,
    );
  }

  PartidaModel copyWith({
    String? gameId,
    String? code,
    bool? isPrivate,
    String? jugadorLocal,
    String? phase,
    List<JugadorPartidaModel>? jugadores,
    int? currentTurn,
    int? direction,
    dynamic currentCard,
    bool? rolesMode,
    bool? specialCardsMode,
    int? maxJugadores,
  }) {
    return PartidaModel(
      gameId: gameId ?? this.gameId,
      code: code ?? this.code,
      isPrivate: isPrivate ?? this.isPrivate,
      jugadorLocal: jugadorLocal ?? this.jugadorLocal,
      phase: phase ?? this.phase,
      jugadores: jugadores ?? this.jugadores,
      currentTurn: currentTurn ?? this.currentTurn,
      direction: direction ?? this.direction,
      currentCard: currentCard ?? this.currentCard,
      rolesMode: rolesMode ?? this.rolesMode,
      specialCardsMode: specialCardsMode ?? this.specialCardsMode,
      maxJugadores: maxJugadores ?? this.maxJugadores,
    );
  }

  bool esMiTurno(String miIdUsuario) {
    if (jugadores.isEmpty) return false;
    final jugadorActual = jugadores[currentTurn % jugadores.length];
    return jugadorActual.id == miIdUsuario;
  }
}
