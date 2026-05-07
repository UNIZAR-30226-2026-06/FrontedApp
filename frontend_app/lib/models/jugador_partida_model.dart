class JugadorPartidaModel {
  final String id;
  final List<dynamic> hand;
  final String? rol;
  final int rolUses;
  final bool connected;
  final bool isBot;
  final bool saidUno;

  JugadorPartidaModel({
    required this.id,
    this.hand = const [],
    this.rol,
    this.rolUses = 0,
    this.connected = true,
    this.isBot = false,
    this.saidUno = false,
  });

  factory JugadorPartidaModel.fromJson(Map<String, dynamic> json) {
    final rawHand = json['hand'];
    return JugadorPartidaModel(
      id: json['id']?.toString() ?? '',
      hand: rawHand is List
          ? rawHand
          : List.filled((rawHand as int?) ?? 0, null),
      rol: json['rol']?.toString(),
      rolUses: json['rolUses'] ?? 0,
      connected: json['connected'] ?? true,
      isBot: json['isBot'] ?? false,
      saidUno: json['saidUno'] ?? false,
    );
  }

  JugadorPartidaModel copyWith({
    String? id,
    List<dynamic>? hand,
    String? rol,
    int? rolUses,
    bool? connected,
    bool? isBot,
    bool? saidUno,
  }) {
    return JugadorPartidaModel(
      id: id ?? this.id,
      hand: hand ?? this.hand,
      rol: rol ?? this.rol,
      rolUses: rolUses ?? this.rolUses,
      connected: connected ?? this.connected,
      isBot: isBot ?? this.isBot,
      saidUno: saidUno ?? this.saidUno,
    );
  }
}
