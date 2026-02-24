class Jugador {
  final String nombre;
  final int coins;

  // ✅ Nuevos campos persistentes
  final String avatarId;
  final String skinId;

  const Jugador({
    required this.nombre,
    required this.coins,
    this.avatarId = 'a0',
    this.skinId = 's1',
  });

  Jugador copyWith({
    String? nombre,
    int? coins,
    String? avatarId,
    String? skinId,
  }) {
    return Jugador(
      nombre: nombre ?? this.nombre,
      coins: coins ?? this.coins,
      avatarId: avatarId ?? this.avatarId,
      skinId: skinId ?? this.skinId,
    );
  }
}