enum TiendaItemTipo { avatar, diseno }

class TiendaItem {
  final String id;
  final String titulo;
  final int precio;
  final TiendaItemTipo tipo;
  final String? assetPath;

  const TiendaItem({
    required this.id,
    required this.titulo,
    required this.precio,
    required this.tipo,
    this.assetPath,
  });

  String get tipoLabel => tipo == TiendaItemTipo.avatar ? 'Avatar' : 'Diseño';
}