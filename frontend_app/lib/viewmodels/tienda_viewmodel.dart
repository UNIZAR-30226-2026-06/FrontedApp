import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../models/tienda_item_model.dart';

enum TiendaFiltro { todos, avatares, disenos }

class TiendaViewModel extends ChangeNotifier {
  final Jugador jugador;

  TiendaViewModel({required this.jugador}) {
    _items = _seedItems();
  }

  late final List<TiendaItem> _items;

  TiendaFiltro _filtro = TiendaFiltro.todos;
  TiendaFiltro get filtro => _filtro;

  void setFiltro(TiendaFiltro nuevo) {
    _filtro = nuevo;
    notifyListeners();
  }

  List<TiendaItem> get itemsFiltrados {
    switch (_filtro) {
      case TiendaFiltro.todos:
        return _items;
      case TiendaFiltro.avatares:
        return _items.where((i) => i.tipo == TiendaItemTipo.avatar).toList();
      case TiendaFiltro.disenos:
        return _items.where((i) => i.tipo == TiendaItemTipo.diseno).toList();
    }
  }

  // Acción abierta: comprar (de momento solo placeholder)
  void comprar(BuildContext context, TiendaItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Comprar: ${item.titulo} (pendiente)')),
    );
  }

  // 4 avatares + 4 diseños
  List<TiendaItem> _seedItems() {
    return const [
      TiendaItem(
        id: 'a1',
        titulo: 'Avatar Robot',
        precio: 100,
        tipo: TiendaItemTipo.avatar,
        assetPath: 'assets/images/shop/robot.png',
      ),
      TiendaItem(
        id: 'a2',
        titulo: 'Avatar Alien',
        precio: 300,
        tipo: TiendaItemTipo.avatar,
        assetPath: 'assets/images/shop/alien.png',
      ),
      TiendaItem(
        id: 'a3',
        titulo: 'Avatar Ninja',
        precio: 200,
        tipo: TiendaItemTipo.avatar,
        assetPath: 'assets/images/shop/ninja.png',
      ),
      TiendaItem(
        id: 'a4',
        titulo: 'Avatar Caballero',
        precio: 250,
        tipo: TiendaItemTipo.avatar,
        assetPath: 'assets/images/shop/knight.png',
      ),
      TiendaItem(
        id: 'd1',
        titulo: 'Diseño Dorado',
        precio: 400,
        tipo: TiendaItemTipo.diseno,
        assetPath: 'assets/images/shop/gold.png',
      ),
      TiendaItem(
        id: 'd2',
        titulo: 'Diseño Espacial',
        precio: 500,
        tipo: TiendaItemTipo.diseno,
        assetPath: 'assets/images/shop/space.png',
      ),
      TiendaItem(
        id: 'd3',
        titulo: 'Diseño Neón',
        precio: 350,
        tipo: TiendaItemTipo.diseno,
        assetPath: 'assets/images/shop/neon.png',
      ),
      TiendaItem(
        id: 'd4',
        titulo: 'Diseño Retro',
        precio: 150,
        tipo: TiendaItemTipo.diseno,
        assetPath: 'assets/images/shop/retro.png',
      ),
    ];
  }
}