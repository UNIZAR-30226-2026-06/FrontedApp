class PartidaModel {
  final String gameId;
  final String? code;
  final bool isPrivate;
  final String? status;
  final String? jugadorLocal;

  PartidaModel({
    required this.gameId,
    this.code,
    required this.isPrivate,
    this.status,
    this.jugadorLocal,
  });

  factory PartidaModel.fromJson(Map<String, dynamic> json) {
    return PartidaModel(
      gameId: (json['gameId'] ?? json['id'] ?? '').toString(),
      code: json['code']?.toString(),
      isPrivate: json['isPrivate'] == true ||
          json['private'] == true ||
          json['visibility'] == 'private',
      status: json['status']?.toString(),
      jugadorLocal: json['jugadorLocal']?.toString(),
    );
  }

  PartidaModel copyWith({
    String? gameId,
    String? code,
    bool? isPrivate,
    String? status,
    String? jugadorLocal,
  }) {
    return PartidaModel(
      gameId: gameId ?? this.gameId,
      code: code ?? this.code,
      isPrivate: isPrivate ?? this.isPrivate,
      status: status ?? this.status,
      jugadorLocal: jugadorLocal ?? this.jugadorLocal,
    );
  }
}