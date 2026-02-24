class Jugador {
  final String nombre;
  final int coins;

  final String avatarId;
  final String skinId;

  // ✅ Amigos del jugador (ids) y solicitudes pendientes (ids)
  final List<String> friendIds;
  final List<String> requestIds;

  const Jugador({
    required this.nombre,
    required this.coins,
    this.avatarId = 'a0',
    this.skinId = 's1',
    this.friendIds = const [],
    this.requestIds = const [],
  });

  Jugador copyWith({
    String? nombre,
    int? coins,
    String? avatarId,
    String? skinId,
    List<String>? friendIds,
    List<String>? requestIds,
  }) {
    return Jugador(
      nombre: nombre ?? this.nombre,
      coins: coins ?? this.coins,
      avatarId: avatarId ?? this.avatarId,
      skinId: skinId ?? this.skinId,
      friendIds: friendIds ?? this.friendIds,
      requestIds: requestIds ?? this.requestIds,
    );
  }
}