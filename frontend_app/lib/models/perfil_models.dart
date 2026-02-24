class AvatarItem {
  final String id;
  final String emoji; // por ahora emoji (luego puedes cambiar a assetPath)
  final String nombre;

  const AvatarItem({
    required this.id,
    required this.emoji,
    required this.nombre,
  });
}

class CardSkinItem {
  final String id;
  final String nombre;
  final String emoji; // placeholder visual

  const CardSkinItem({
    required this.id,
    required this.nombre,
    required this.emoji,
  });
}