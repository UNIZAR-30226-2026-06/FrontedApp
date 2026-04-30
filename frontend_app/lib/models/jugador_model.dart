class Jugador {
  final String nombre;
  final String correo;
  final int coins;

  final String avatarId;
  final String skinId;

  // ✅ Amigos del jugador (ids) y solicitudes pendientes (ids)
  final List<String> friendIds;
  final List<String> requestIds;

  const Jugador({
    required this.nombre,
    this.correo = '',
    required this.coins,
    this.avatarId = 'a0',
    this.skinId = 's1',
    this.friendIds = const [],
    this.requestIds = const [],
  });

  Jugador copyWith({
    String? nombre,
    String? correo,
    int? coins,
    String? avatarId,
    String? skinId,
    List<String>? friendIds,
    List<String>? requestIds,
  }) {
    return Jugador(
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      coins: coins ?? this.coins,
      avatarId: avatarId ?? this.avatarId,
      skinId: skinId ?? this.skinId,
      friendIds: friendIds ?? this.friendIds,
      requestIds: requestIds ?? this.requestIds,
    );
  }

  // Convierte un JSON del servidor a un objeto Dart
  factory Jugador.fromJson(Map<String, dynamic> json) {
    return Jugador(
      nombre: json['nombre_usuario'] ?? json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      coins: json['monedas'] ?? json['coins'] ?? 0,
      avatarId: (json['id_avatar_seleccionado'] ?? json['avatar'] ?? json['avatarId'])?.toString() ?? 'a0',
      skinId: (json['id_estilo_seleccionado'] ?? json['estilo'] ?? json['skinId'])?.toString() ?? 's1',
      friendIds: (json['friendIds'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      requestIds: (json['requestIds'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  // Convierte el objeto Dart a JSON para mandarlo al Back
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correo': correo,
      'coins': coins,
      'avatarId': avatarId,
      'skinId': skinId,
    };
  }
}
