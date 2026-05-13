/// Modelos para el modo "con roles".
///
/// Contrato del backend:
/// - `GET /roles/{gameId}/me` → `MiRolResponse`
/// - `POST /roles/{gameId}/use` body `UsarRolPayload`, respuesta `UsarRolResponse`
///
/// El backend usa nombres en español/snake_case (`nombre`, `num_usos_max`,
/// `descripcion`). Aquí los normalizamos a campos Dart idiomáticos pero
/// el parser tolera ambas variantes por si el contrato evoluciona.

class RolInfo {
  final int? idRol;
  final String nombre;
  final String? descripcion;
  final int? maxUsos;
  final String? imagen;

  const RolInfo({
    this.idRol,
    required this.nombre,
    this.descripcion,
    this.maxUsos,
    this.imagen,
  });

  factory RolInfo.fromJson(Map<String, dynamic> json) {
    return RolInfo(
      idRol: (json['id_rol'] ?? json['idRol']) as int?,
      nombre: (json['nombre'] ?? json['name'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? json['description'])?.toString(),
      maxUsos: (json['num_usos_max'] ?? json['maxUses'] ?? json['numUsosMax']) as int?,
      imagen: (json['imagen'] ?? json['image'])?.toString(),
    );
  }

  /// Clave normalizada (sin acentos, minúsculas, snake_case) para hacer
  /// switch en el UI sobre el tipo de rol sin depender del idioma del backend.
  String get key {
    final n = nombre.toLowerCase().trim();
    // quitamos acentos comunes manualmente para evitar dependencia extra
    final sinAcentos = n
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
    if (sinAcentos == 'espia') return 'espia';
    if (sinAcentos == 'ladron') return 'ladron';
    if (sinAcentos == 'anular cartas') return 'anular_cartas';
    if (sinAcentos == 'transformar carta') return 'transformar_carta';
    if (sinAcentos == 'mirar la siguiente carta del mazo') {
      return 'mirar_siguiente_carta';
    }
    if (sinAcentos == 'bloquear habilidades') return 'bloquear_habilidades';
    return sinAcentos.replaceAll(' ', '_');
  }
}

class MiRolResponse {
  final String gameId;
  final String playerId;
  final RolInfo? rol;
  final int uses;
  final int? maxUses;
  final int? lastUsedTurn;
  final bool canUseNow;

  const MiRolResponse({
    required this.gameId,
    required this.playerId,
    required this.rol,
    required this.uses,
    required this.maxUses,
    required this.lastUsedTurn,
    required this.canUseNow,
  });

  factory MiRolResponse.fromJson(Map<String, dynamic> json) {
    final rawRol = json['role'] ?? json['rol'];
    return MiRolResponse(
      gameId: (json['gameId'] ?? json['id_partida'] ?? '').toString(),
      playerId: (json['playerId'] ?? json['id_usuario'] ?? '').toString(),
      rol: rawRol is Map<String, dynamic> ? RolInfo.fromJson(rawRol) : null,
      uses: (json['uses'] as num?)?.toInt() ?? 0,
      maxUses: (json['maxUses'] as num?)?.toInt(),
      lastUsedTurn: (json['lastUsedTurn'] as num?)?.toInt(),
      canUseNow: json['canUseNow'] == true,
    );
  }

  int get remainingUses {
    final max = maxUses ?? rol?.maxUsos;
    if (max == null) return 0;
    final r = max - uses;
    return r < 0 ? 0 : r;
  }
}

/// Body para `POST /roles/{gameId}/use`. Todos los campos son opcionales —
/// cada rol usa un subconjunto distinto:
///   espia              → targetPlayerId
///   ladron             → targetPlayerId + ownCardId
///   anular_cartas      → ownCardId
///   transformar_carta  → ownCardId + (newColor o newNumber)
///   mirar_siguiente / bloquear → (vacío)
class UsarRolPayload {
  final String? targetPlayerId;
  final String? ownCardId;
  final String? newColor;
  final int? newNumber;

  const UsarRolPayload({
    this.targetPlayerId,
    this.ownCardId,
    this.newColor,
    this.newNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      if (targetPlayerId != null) 'targetPlayerId': targetPlayerId,
      // El backend acepta ambos nombres; mandamos ambos para máxima
      // compatibilidad con versiones del backend.
      if (ownCardId != null) 'ownCardId': ownCardId,
      if (ownCardId != null) 'cardId': ownCardId,
      if (newColor != null) 'newColor': newColor,
      if (newNumber != null) 'newNumber': newNumber,
    };
  }
}

/// Respuesta de `POST /roles/{gameId}/use`. Contiene el rol que se acaba de
/// usar y un `result` cuyo contenido varía según el tipo de rol:
///   espia → `result.targetHand: [carta]`
///   mirar_siguiente → `result.nextCard: carta | null`
///   otros → result puede ser `{}` o info adicional
class UsarRolResponse {
  final bool success;
  final RolInfo? rol;
  final Map<String, dynamic> result;

  const UsarRolResponse({
    required this.success,
    required this.rol,
    required this.result,
  });

  factory UsarRolResponse.fromJson(Map<String, dynamic> json) {
    final rawRol = json['role'] ?? json['rol'];
    final rawResult = json['result'];
    return UsarRolResponse(
      success: json['success'] == true,
      rol: rawRol is Map<String, dynamic> ? RolInfo.fromJson(rawRol) : null,
      result: rawResult is Map<String, dynamic>
          ? Map<String, dynamic>.from(rawResult)
          : <String, dynamic>{},
    );
  }

  /// Mano del jugador objetivo cuando el rol es "espía".
  List<dynamic> get targetHand {
    final h = result['targetHand'];
    return h is List ? h : const [];
  }

  /// Carta siguiente del mazo (sólo "mirar la siguiente carta").
  dynamic get nextCard => result['nextCard'];
}
