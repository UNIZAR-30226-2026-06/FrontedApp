import '../models/jugador_partida_model.dart';

class PartidaModel {
  final String gameId;
  final String? code;
  final bool isPrivate;
  final String? jugadorLocal;

  final String phase;
  final List<JugadorPartidaModel> jugadores;

  final String? currentTurn;

  final int direction;
  final dynamic currentCard;
  final bool rolesMode;
  final bool specialCardsMode;
  final int maxJugadores;
  final int drawCount;
  final List<String> resumeVoters;
  final List<String> pauseVoters;

  PartidaModel({
    required this.gameId,
    this.code,
    required this.isPrivate,
    this.jugadorLocal,
    this.phase = 'waiting',
    this.jugadores = const [],
    this.currentTurn,
    this.direction = 1,
    this.currentCard,
    this.rolesMode = false,
    this.specialCardsMode = false,
    this.maxJugadores = 4,
    this.drawCount = 0,
    this.resumeVoters = const [],
    this.pauseVoters = const [],
  });

  factory PartidaModel.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'] ?? json['jugadores'];
    final players = (rawPlayers as List?)?.map((p) {
      if (p is Map<String, dynamic>) return JugadorPartidaModel.fromJson(p);
      return JugadorPartidaModel(id: p.toString());
    }).toList() ?? [];

    final rawTurn = json['currentTurn']?.toString();

    dynamic rawCard = json['discardTop'] ?? json['currentCard'];
    dynamic processedCard;

    if (rawCard is String && rawCard.contains('_')) {
      final partes = rawCard.split('_');
      processedCard = {
        'id': rawCard,
        'color': partes[0],
        'valor': partes[1],
      };
    } else {
      processedCard = rawCard;
    }

    final bool modoRolesActivo =
        json['rolesMode'] == true ||
            json['modo_roles'] == true ||
            json['mode'] == 'roles';

    final bool modoCartasActivo =
        json['specialCardsMode'] == true ||
            json['modo_cartas_especiales'] == true ||
            json['mode'] == 'cards';

    return PartidaModel(
      gameId: (json['gameId'] ?? json['id_partida'] ?? '').toString(),
      code: (json['codigo'] ?? json['code'])?.toString(),
      isPrivate: json['codigo'] != null || json['isPrivate'] == true,
      jugadorLocal: json['jugadorLocal']?.toString(),
      phase: _normalizarFase(json['phase']?.toString() ?? json['estado']?.toString() ?? 'waiting'),
      jugadores: players,

      currentTurn: rawTurn,

      currentCard: processedCard,
      maxJugadores: (json['maxJugadores'] ?? json['max_jugadores'] ?? json['max_jugadores_partida'] ?? 4) as int,
      drawCount: (json['drawCount'] as int?) ?? 0,
      rolesMode: modoRolesActivo,
      specialCardsMode: modoCartasActivo,
      resumeVoters: json['resumeVoters'] is List ? List<String>.from(json['resumeVoters']) : const [],
      pauseVoters: json['pauseVoters'] is List ? List<String>.from(json['pauseVoters']) : const [],
    );
  }


  PartidaModel copyWith({
    String? gameId, String? code, bool? isPrivate, String? jugadorLocal,
    String? phase, List<JugadorPartidaModel>? jugadores, String? currentTurn,
    int? direction, dynamic currentCard, bool? rolesMode, bool? specialCardsMode,
    int? maxJugadores, int? drawCount, List<String>? resumeVoters, List<String>? pauseVoters,
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
      drawCount: drawCount ?? this.drawCount,
      resumeVoters: resumeVoters ?? this.resumeVoters,
      pauseVoters: pauseVoters ?? this.pauseVoters,
    );
  }

  bool esMiTurno(String miIdUsuario) {
    if (currentTurn == null) return false;
    return currentTurn == miIdUsuario;
  }

  static String _normalizarFase(String raw) {
    switch (raw.toLowerCase()) {
      case 'esperando_jugadores':
      case 'waiting':
        return 'waiting';
      case 'en_curso':
      case 'playing':
        return 'playing';
      case 'pausada':
      case 'paused':
        return 'paused';
      case 'finalizada':
      case 'finished':
        return 'finished';
      default:
        return raw;
    }
  }
}