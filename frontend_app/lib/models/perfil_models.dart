class AvatarItem {
  final String id;
  final String emoji;
  final String nombre;
  final String? assetPath;

  const AvatarItem({
    required this.id,
    required this.emoji,
    required this.nombre,
    this.assetPath,
  });
}

class CardSkinItem {
  final String id;
  final String nombre;
  final String emoji;
  final String? assetPath;

  const CardSkinItem({
    required this.id,
    required this.nombre,
    required this.emoji,
    this.assetPath,
  });
}
